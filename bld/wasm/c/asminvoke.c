/*
 * asminvoke.c — PROTO and INVOKE for wasm
 * MASM high-level call/prototype support.
 * GPLv3 — the crew 4free — sysop/0
 */

#include "asmglob.h"
#include "asmalloc.h"

/* Forward: submit a generated instruction line to the assembler */
extern int AsmLine( const char *line );

static void AsmCodeGenLine(const char *inst)
{
    /* Feed generated instruction text back into the main parser.
     * This is how INVOKE expands to real instructions. */
    AsmLine(inst);
}

/*
 * PROTO — Function prototype declaration
 *
 * Syntax:
 *   funcname PROTO [convention] [:type1] [,:type2] ...
 *
 * Example:
 *   MessageBoxA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD
 *   myprintf    PROTO C :DWORD, :VARARG
 *
 * Used by INVOKE to check argument count and generate proper CALL.
 */

#define MAX_PROTOS 128
#define MAX_PROTO_PARAMS 16

typedef enum {
    CONV_C,         /* Caller cleans stack, right-to-left push */
    CONV_STDCALL,   /* Callee cleans stack, right-to-left push */
    CONV_PASCAL,    /* Callee cleans stack, left-to-right push */
    CONV_SYSCALL,   /* Like C */
    CONV_WATCOM_C,  /* Watcom register convention */
    CONV_FASTCALL   /* First 2 in ECX/EDX, rest on stack */
} calling_conv_t;

typedef struct {
    char    type_name[32];
    int     size;       /* Bytes: 1,2,4,8 */
    bool    is_vararg;
} proto_param_t;

typedef struct {
    char            name[64];
    calling_conv_t  conv;
    int             num_params;
    proto_param_t   params[MAX_PROTO_PARAMS];
    bool            is_extern;
} proto_def_t;

static proto_def_t protos[MAX_PROTOS];
static int num_protos = 0;

/* Find a PROTO by name */
proto_def_t *FindProto(const char *name)
{
    int i;
    for (i = 0; i < num_protos; i++) {
        if (stricmp(protos[i].name, name) == 0)
            return &protos[i];
    }
    return NULL;
}

/* Parse calling convention keyword */
static calling_conv_t ParseConvention(const char *s)
{
    if (stricmp(s, "C") == 0) return CONV_C;
    if (stricmp(s, "STDCALL") == 0) return CONV_STDCALL;
    if (stricmp(s, "PASCAL") == 0) return CONV_PASCAL;
    if (stricmp(s, "SYSCALL") == 0) return CONV_SYSCALL;
    if (stricmp(s, "WATCOM_C") == 0) return CONV_WATCOM_C;
    if (stricmp(s, "FASTCALL") == 0) return CONV_FASTCALL;
    return CONV_C;  /* Default */
}

/* Get parameter size from type name */
static int ParamSize(const char *type)
{
    if (stricmp(type, "BYTE") == 0) return 1;
    if (stricmp(type, "WORD") == 0) return 2;
    if (stricmp(type, "DWORD") == 0 || stricmp(type, "PTR") == 0) return 4;
    if (stricmp(type, "QWORD") == 0) return 8;
    if (stricmp(type, "REAL4") == 0) return 4;
    if (stricmp(type, "REAL8") == 0) return 8;
    return 4;  /* Default DWORD */
}

/* Parse: funcname PROTO [convention] [:type, :type, ...] */
int AsmProto(token_buffer *tokbuf, int i)
{
    proto_def_t *proto;
    const char *tok;

    if (num_protos >= MAX_PROTOS) return RC_ERROR;

    proto = &protos[num_protos];
    memset(proto, 0, sizeof(*proto));
    proto->conv = CONV_C;

    /* Name is token before PROTO */
    if (i > 0)
        strncpy(proto->name, tokbuf->tokens[i-1].string_ptr, 63);

    i++;  /* Skip PROTO */

    /* Check for calling convention */
    if (i < tokbuf->count) {
        tok = tokbuf->tokens[i].string_ptr;
        if (stricmp(tok, "C") == 0 || stricmp(tok, "STDCALL") == 0 ||
            stricmp(tok, "PASCAL") == 0 || stricmp(tok, "FASTCALL") == 0 ||
            stricmp(tok, "SYSCALL") == 0 || stricmp(tok, "WATCOM_C") == 0) {
            proto->conv = ParseConvention(tok);
            i++;
        }
    }

    /* Parse parameter types: :TYPE, :TYPE, ... */
    while (i < tokbuf->count && proto->num_params < MAX_PROTO_PARAMS) {
        tok = tokbuf->tokens[i].string_ptr;

        if (tok[0] == ':') {
            i++;
            if (i < tokbuf->count) {
                tok = tokbuf->tokens[i].string_ptr;
                if (stricmp(tok, "VARARG") == 0) {
                    proto->params[proto->num_params].is_vararg = true;
                    strncpy(proto->params[proto->num_params].type_name, "VARARG", 31);
                    proto->params[proto->num_params].size = 4;
                } else {
                    strncpy(proto->params[proto->num_params].type_name, tok, 31);
                    proto->params[proto->num_params].size = ParamSize(tok);
                    proto->params[proto->num_params].is_vararg = false;
                }
                proto->num_params++;
            }
        }
        i++;
    }

    num_protos++;
    return RC_OK;
}

/*
 * INVOKE — High-level function call
 *
 * Syntax:
 *   INVOKE funcname [,arg1] [,arg2] ...
 *
 * Generates:
 *   PUSH arg_n   (right-to-left for C/STDCALL)
 *   PUSH arg_n-1
 *   ...
 *   PUSH arg_1
 *   CALL funcname
 *   ADD ESP, n   (only for C convention — caller cleanup)
 *
 * If ADDR prefix: push address (LEA+PUSH) instead of value.
 */
int AsmInvoke(token_buffer *tokbuf, int i)
{
    proto_def_t *proto;
    const char *funcname;
    int args[MAX_PROTO_PARAMS];
    int arg_is_addr[MAX_PROTO_PARAMS];
    int num_args = 0;
    int stack_bytes = 0;
    int j;

    i++;  /* Skip INVOKE */
    if (i >= tokbuf->count) return RC_ERROR;

    funcname = tokbuf->tokens[i].string_ptr;
    proto = FindProto(funcname);
    i++;

    /* Collect arguments */
    while (i < tokbuf->count && num_args < MAX_PROTO_PARAMS) {
        if (tokbuf->tokens[i].string_ptr[0] == ',') {
            i++;
            continue;
        }
        /* Check for ADDR prefix */
        if (stricmp(tokbuf->tokens[i].string_ptr, "ADDR") == 0) {
            arg_is_addr[num_args] = 1;
            i++;
        } else {
            arg_is_addr[num_args] = 0;
        }
        args[num_args] = i;
        num_args++;
        i++;
    }

    /* Generate code: push args right-to-left (C/STDCALL convention) */
    /*
     * For actual code generation, we would emit:
     *   For each arg (reverse order):
     *     If ADDR: LEA EAX, [arg]; PUSH EAX
     *     If immediate: PUSH imm32
     *     If register: PUSH reg
     *     If memory: PUSH [mem]
     *   CALL funcname
     *   If C convention: ADD ESP, stack_bytes
     *
     * This requires integration with asmins.c's instruction emitter.
     * For now, we build the instruction text and feed it back to
     * the main parser loop.
     */

    /* Calculate stack cleanup size */
    if (proto) {
        for (j = 0; j < proto->num_params; j++)
            stack_bytes += proto->params[j].size;
    } else {
        stack_bytes = num_args * 4;  /* Assume DWORD params */
    }

    /* Generate instruction text and feed back to parser.
     * We build strings like "PUSH arg" and "CALL func"
     * and submit them to AsmLine() for assembly. */

    /* Push args right-to-left (C/STDCALL) */
    for (j = num_args - 1; j >= 0; j--) {
        char inst[256];
        const char *argtext = tokbuf->tokens[args[j]].string_ptr;

        if (arg_is_addr[j]) {
            /* ADDR prefix: LEA EAX, [arg] then PUSH EAX */
            snprintf(inst, sizeof(inst), "LEA EAX, [%s]", argtext);
            AsmCodeGenLine(inst);
            AsmCodeGenLine("PUSH EAX");
        } else {
            snprintf(inst, sizeof(inst), "PUSH %s", argtext);
            AsmCodeGenLine(inst);
        }
    }

    /* CALL funcname */
    {
        char inst[256];
        snprintf(inst, sizeof(inst), "CALL %s", funcname);
        AsmCodeGenLine(inst);
    }

    /* Caller cleanup for C convention */
    if (!proto || proto->conv == CONV_C) {
        if (stack_bytes > 0) {
            char inst[256];
            snprintf(inst, sizeof(inst), "ADD ESP, %d", stack_bytes);
            AsmCodeGenLine(inst);
        }
    }

    return RC_OK;
}

void AsmInvokeInit(void) { num_protos = 0; }
void AsmInvokeFini(void) { num_protos = 0; }
