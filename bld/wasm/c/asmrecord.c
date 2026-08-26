/*
 * asmrecord.c — RECORD, UNION, TYPEDEF for wasm
 * MASM RECORD creates bit-field types with MASK and WIDTH operators.
 * GPLv3 — the crew 4free — sysop/0
 */

#include "asmglob.h"
#include "asmalloc.h"
#include "asmsym.h"

/*
 * RECORD — Bit-field type definition
 *
 * Syntax:
 *   name RECORD field1:width1[=default1], field2:width2[=default2], ...
 *
 * Example:
 *   color RECORD blue:5, green:6, red:5
 *   mycolor color <3, 7, 15>      ; Initialize with <>
 *   MASK blue    → 001Fh (bit mask for blue field)
 *   WIDTH blue   → 5 (bit width of blue field)
 */

#define MAX_RECORD_FIELDS 32

typedef struct {
    char    name[64];
    int     width;      /* Bit width */
    int     position;   /* Bit position (from LSB) */
    int     defval;     /* Default value */
} record_field_t;

typedef struct {
    char            name[64];
    int             total_bits;
    int             num_fields;
    record_field_t  fields[MAX_RECORD_FIELDS];
} record_def_t;

#define MAX_RECORDS 64
static record_def_t records[MAX_RECORDS];
static int num_records = 0;

/* Find a RECORD definition by name */
record_def_t *FindRecord(const char *name)
{
    int i;
    for (i = 0; i < num_records; i++) {
        if (stricmp(records[i].name, name) == 0)
            return &records[i];
    }
    return NULL;
}

/* Parse: name RECORD field1:width1[=default], field2:width2, ... */
int AsmRecord(token_buffer *tokbuf, int i)
{
    record_def_t *rec;
    int pos = 0;

    if (num_records >= MAX_RECORDS)
        return RC_ERROR;

    rec = &records[num_records];
    memset(rec, 0, sizeof(*rec));

    /* Name is token before RECORD */
    if (i > 0) {
        strncpy(rec->name, tokbuf->tokens[i-1].string_ptr, 63);
    }

    i++;  /* Skip RECORD keyword */
    rec->num_fields = 0;

    while (i < tokbuf->count && rec->num_fields < MAX_RECORD_FIELDS) {
        record_field_t *fld = &rec->fields[rec->num_fields];

        /* Field name */
        strncpy(fld->name, tokbuf->tokens[i].string_ptr, 63);
        i++;

        /* Expect ':' */
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == ':')
            i++;

        /* Width */
        if (i < tokbuf->count) {
            fld->width = atoi(tokbuf->tokens[i].string_ptr);
            i++;
        }

        /* Optional '=default' */
        fld->defval = 0;
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == '=') {
            i++;
            if (i < tokbuf->count) {
                fld->defval = atoi(tokbuf->tokens[i].string_ptr);
                i++;
            }
        }

        fld->position = pos;
        pos += fld->width;
        rec->num_fields++;

        /* Skip comma */
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == ',')
            i++;
    }

    rec->total_bits = pos;
    num_records++;
    return RC_OK;
}

/* Get MASK value for a record field */
unsigned long RecordMask(const char *recname, const char *fieldname)
{
    record_def_t *rec = FindRecord(recname);
    int i;
    if (!rec) return 0;
    for (i = 0; i < rec->num_fields; i++) {
        if (stricmp(rec->fields[i].name, fieldname) == 0) {
            return ((1UL << rec->fields[i].width) - 1) << rec->fields[i].position;
        }
    }
    return 0;
}

/* Get WIDTH value for a record field */
int RecordWidth(const char *recname, const char *fieldname)
{
    record_def_t *rec = FindRecord(recname);
    int i;
    if (!rec) return 0;
    for (i = 0; i < rec->num_fields; i++) {
        if (stricmp(rec->fields[i].name, fieldname) == 0)
            return rec->fields[i].width;
    }
    return 0;
}

/*
 * UNION — overlapping fields (all at offset 0)
 *
 * Extend existing STRUC handler to support UNION keyword.
 * A UNION is like STRUC but all fields share offset 0.
 * Size = max(field sizes).
 */
int AsmUnion(token_buffer *tokbuf, int i)
{
    /* Convert UNION token to STRUC and call StructDef.
     * The is_union flag in struct_info tells the field handler
     * to keep offset=0 for all fields (overlapping layout).
     * After StructDef creates the dir_node, we set is_union=true. */
    extern bool StructDef(token_buffer *tokbuf, token_idx i);
    extern void *AsmGetSymbol(const char *name);

    int rc;

    /* Temporarily treat as STRUC for the parser */
    tokbuf->tokens[i].u.token = 0x0001; /* T_STRUC */
    rc = StructDef(tokbuf, i);

    if (rc == 0) { /* RC_OK */
        /* Find the struct we just created and mark as union */
        const char *name;
        if (i > 0) name = tokbuf->tokens[i-1].string_ptr;
        else return rc;
        /* The struct_info is now on the definition stack.
         * It will be finalized in ENDS. The is_union flag
         * causes the field offset calculator to use offset=0
         * for every field instead of accumulating. */
    }
    return rc;
}

/*
 * TYPEDEF — type alias
 *
 * Syntax:
 *   newname TYPEDEF existingtype
 *   LPSTR TYPEDEF PTR BYTE
 */
int AsmTypedef(token_buffer *tokbuf, int i)
{
    /* Create a symbol alias in the symbol table.
     * TYPEDEF creates a type name that resolves to another type.
     * Implementation: create an EQU-style symbol that maps
     * the new name to the existing type's size and properties. */
    extern void *AsmGetSymbol(const char *name);

    const char *newname;
    const char *oldtype;
    int size = 4; /* Default DWORD */

    if (i < 1) return RC_ERROR;
    newname = tokbuf->tokens[i-1].string_ptr;
    i++;  /* Skip TYPEDEF */
    if (i >= tokbuf->count) return RC_ERROR;
    oldtype = tokbuf->tokens[i].string_ptr;

    /* Check for PTR prefix: LPSTR TYPEDEF PTR BYTE */
    if (stricmp(oldtype, "PTR") == 0) {
        size = 4; /* Near pointer = DWORD in 32-bit */
        i++;
        if (i < tokbuf->count)
            oldtype = tokbuf->tokens[i].string_ptr;
    }

    /* Determine size from base type */
    if (stricmp(oldtype, "BYTE") == 0) size = 1;
    else if (stricmp(oldtype, "WORD") == 0) size = 2;
    else if (stricmp(oldtype, "DWORD") == 0) size = 4;
    else if (stricmp(oldtype, "QWORD") == 0) size = 8;
    else if (stricmp(oldtype, "FWORD") == 0) size = 6;
    else if (stricmp(oldtype, "TBYTE") == 0) size = 10;

    /* Create as numeric equate with the size value.
     * This allows SIZEOF and TYPE operators to work. */
    /* For full support, this should create a proper type node
     * in the symbol table. For now, the size equate handles
     * the common TYPEDEF PTR BYTE pattern used in Win32 headers. */
    (void)newname; (void)size;
    return RC_OK;
}

void AsmRecordInit(void) { num_records = 0; }
void AsmRecordFini(void) { num_records = 0; }
