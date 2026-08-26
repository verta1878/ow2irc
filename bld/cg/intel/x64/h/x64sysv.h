/*
 * openwatcomirc Phase 18 — SysV AMD64 ABI Calling Convention
 *
 * Implements the System V AMD64 ABI for Linux/FreeBSD/macOS targets.
 * This replaces the Watcom register calling convention used by the 386 backend.
 *
 * Reference: System V Application Binary Interface
 *            AMD64 Architecture Processor Supplement
 *            (https://gitlab.com/x86-psABIs/x86-64-ABI)
 *
 * === SysV AMD64 ABI Summary ===
 *
 * Integer args:  RDI, RSI, RDX, RCX, R8, R9  (6 registers)
 * Float args:    XMM0-XMM7                    (8 registers)
 * Return:        RAX (integer), RAX:RDX (128-bit), XMM0 (float), XMM0:XMM1 (complex)
 * Callee-saved:  RBX, RBP, R12-R15
 * Caller-saved:  RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15
 * Stack:         16-byte aligned at CALL instruction
 * Red zone:      128 bytes below RSP (leaf functions can use without adjusting RSP)
 * Varargs:       AL = number of XMM registers used for variable args
 *
 * === Struct Classification ===
 *
 * Structs ≤ 16 bytes are classified field-by-field into INTEGER or SSE classes.
 * Structs > 16 bytes are passed by invisible reference (pointer in integer reg).
 * The classification determines whether a struct is passed in registers or on stack.
 *
 * Build: gcc -I$OWLH -I$WATCOMH x64sysv.c x64codegen_p18.c $OWLLIB -o p18test
 */

#ifndef X64_SYSV_H
#define X64_SYSV_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

/* ====================================================================
 * Register Assignments
 * ==================================================================== */

/* Integer parameter registers (in order) */
typedef enum {
    SYSV_ARG_RDI = 0,
    SYSV_ARG_RSI,
    SYSV_ARG_RDX,
    SYSV_ARG_RCX,
    SYSV_ARG_R8,
    SYSV_ARG_R9,
    SYSV_NUM_INT_ARGS = 6
} sysv_int_arg_t;

/* x86_64 register encoding for each integer arg register */
static const struct {
    int     encoding;   /* 3-bit ModRM encoding */
    bool    extended;   /* needs REX.B/REX.R */
} sysv_int_arg_regs[SYSV_NUM_INT_ARGS] = {
    { 7, false },   /* RDI = encoding 7 */
    { 6, false },   /* RSI = encoding 6 */
    { 2, false },   /* RDX = encoding 2 */
    { 1, false },   /* RCX = encoding 1 */
    { 0, true  },   /* R8  = encoding 0 + REX.B */
    { 1, true  },   /* R9  = encoding 1 + REX.B */
};

/* Float parameter registers: XMM0-XMM7 (encoding 0-7) */
#define SYSV_NUM_FLOAT_ARGS 8

/* Return registers */
#define SYSV_RET_INT    0   /* RAX = encoding 0 */
#define SYSV_RET_INT2   2   /* RDX = encoding 2 (for 128-bit returns) */
#define SYSV_RET_FLOAT  0   /* XMM0 = encoding 0 */
#define SYSV_RET_FLOAT2 1   /* XMM1 = encoding 1 (for complex returns) */

/* Callee-saved registers */
static const struct {
    int     encoding;
    bool    extended;
    const char *name;
} sysv_callee_saved[] = {
    { 3, false, "RBX" },
    { 5, false, "RBP" },
    { 4, true,  "R12" },
    { 5, true,  "R13" },
    { 6, true,  "R14" },
    { 7, true,  "R15" },
};
#define SYSV_NUM_CALLEE_SAVED 6

/* ====================================================================
 * Parameter Classification (for struct passing)
 * ==================================================================== */

typedef enum {
    CLASS_NO_CLASS = 0,     /* not yet classified */
    CLASS_INTEGER,          /* passed in integer register */
    CLASS_SSE,              /* passed in XMM register */
    CLASS_SSEUP,            /* upper half of SSE value */
    CLASS_X87,              /* passed in x87 FPU */
    CLASS_X87UP,            /* upper half of x87 value */
    CLASS_COMPLEX_X87,      /* complex x87 */
    CLASS_MEMORY,           /* passed on stack */
} sysv_class_t;

/* Struct field descriptor */
typedef struct {
    int         offset;     /* byte offset within struct */
    int         size;       /* field size in bytes */
    bool        is_float;   /* true if float/double type */
} sysv_field_t;

/*
 * Classify a struct for parameter/return passing.
 *
 * Rules (simplified):
 * 1. Structs > 16 bytes → MEMORY (passed by invisible reference)
 * 2. Structs ≤ 8 bytes → one eightbyte, classified by field types
 * 3. Structs 9-16 bytes → two eightbytes, each classified independently
 * 4. If any eightbyte is MEMORY → entire struct is MEMORY
 * 5. INTEGER class wins over NO_CLASS
 * 6. SSE class wins over NO_CLASS
 * 7. If both INTEGER and SSE → MEMORY (post-merge rule)
 *
 * Returns the class for each eightbyte (up to 2).
 */
static void sysv_classify_struct(
    const sysv_field_t *fields, int num_fields,
    int struct_size,
    sysv_class_t *class_lo, sysv_class_t *class_hi)
{
    *class_lo = CLASS_NO_CLASS;
    *class_hi = CLASS_NO_CLASS;

    /* Rule 1: structs > 16 bytes go to memory */
    if (struct_size > 16) {
        *class_lo = CLASS_MEMORY;
        *class_hi = CLASS_MEMORY;
        return;
    }

    /* Classify each field into its eightbyte */
    for (int i = 0; i < num_fields; i++) {
        sysv_class_t field_class = fields[i].is_float ? CLASS_SSE : CLASS_INTEGER;
        sysv_class_t *target;

        if (fields[i].offset < 8) {
            target = class_lo;
        } else {
            target = class_hi;
        }

        /* Merge: higher class wins, MEMORY beats everything */
        if (*target == CLASS_NO_CLASS) {
            *target = field_class;
        } else if (*target != field_class) {
            /* Mixed integer/float in same eightbyte → MEMORY */
            *target = CLASS_MEMORY;
        }
    }

    /* If any eightbyte is MEMORY, entire struct is MEMORY */
    if (*class_lo == CLASS_MEMORY || *class_hi == CLASS_MEMORY) {
        *class_lo = CLASS_MEMORY;
        *class_hi = CLASS_MEMORY;
    }

    /* If struct ≤ 8 bytes, hi class stays NO_CLASS */
    if (struct_size <= 8) {
        *class_hi = CLASS_NO_CLASS;
    }
}

/* ====================================================================
 * Call State — tracks register allocation during arg passing
 * ==================================================================== */

typedef struct {
    int     next_int_reg;       /* next integer arg register index (0-5) */
    int     next_float_reg;     /* next float arg register index (0-7) */
    int     stack_offset;       /* current stack arg offset (from RSP at call) */
    int     num_stack_args;     /* count of args passed on stack */
    bool    is_varargs;         /* true if function is variadic */
} sysv_call_state_t;

static void sysv_call_init(sysv_call_state_t *state, bool is_varargs) {
    state->next_int_reg = 0;
    state->next_float_reg = 0;
    state->stack_offset = 0;
    state->num_stack_args = 0;
    state->is_varargs = is_varargs;
}

/* Result of parameter allocation */
typedef enum {
    PARM_IN_INT_REG,    /* passed in integer register */
    PARM_IN_FLOAT_REG,  /* passed in XMM register */
    PARM_ON_STACK,      /* passed on stack */
    PARM_BY_REFERENCE,  /* struct passed by invisible reference (pointer in int reg) */
} sysv_parm_loc_t;

typedef struct {
    sysv_parm_loc_t location;
    int             reg_index;      /* register index (if in register) */
    int             stack_offset;   /* stack offset (if on stack) */
    int             size;           /* actual size in bytes */
} sysv_parm_info_t;

/*
 * Allocate a parameter — determines where it goes (register or stack).
 *
 * For integer/pointer types ≤ 8 bytes: next integer register, or stack.
 * For float/double types: next XMM register, or stack.
 * For structs: classify, then allocate eightbytes to appropriate registers.
 * For structs > 16 bytes: pass by invisible reference.
 */
static sysv_parm_info_t sysv_alloc_parm(
    sysv_call_state_t *state,
    bool is_float,
    int size,
    bool is_struct,
    const sysv_field_t *fields, int num_fields)
{
    sysv_parm_info_t info;
    info.size = size;

    if (is_struct && size > 16) {
        /* Large struct: pass by invisible reference */
        if (state->next_int_reg < SYSV_NUM_INT_ARGS) {
            info.location = PARM_BY_REFERENCE;
            info.reg_index = state->next_int_reg++;
        } else {
            info.location = PARM_ON_STACK;
            info.stack_offset = state->stack_offset;
            state->stack_offset += 8; /* pointer size */
            state->num_stack_args++;
        }
        return info;
    }

    if (is_struct) {
        /* Small struct: classify and allocate */
        sysv_class_t lo, hi;
        sysv_classify_struct(fields, num_fields, size, &lo, &hi);

        if (lo == CLASS_MEMORY) {
            /* Struct doesn't fit in registers */
            info.location = PARM_ON_STACK;
            info.stack_offset = state->stack_offset;
            state->stack_offset += ((size + 7) & ~7); /* 8-byte aligned */
            state->num_stack_args++;
            return info;
        }

        /* Allocate eightbytes to registers */
        int needed_int = (lo == CLASS_INTEGER ? 1 : 0) + (hi == CLASS_INTEGER ? 1 : 0);
        int needed_sse = (lo == CLASS_SSE ? 1 : 0) + (hi == CLASS_SSE ? 1 : 0);

        if (state->next_int_reg + needed_int > SYSV_NUM_INT_ARGS ||
            state->next_float_reg + needed_sse > SYSV_NUM_FLOAT_ARGS) {
            /* Not enough registers — spill to stack */
            info.location = PARM_ON_STACK;
            info.stack_offset = state->stack_offset;
            state->stack_offset += ((size + 7) & ~7);
            state->num_stack_args++;
            return info;
        }

        /* Allocate to registers */
        if (lo == CLASS_INTEGER) {
            info.location = PARM_IN_INT_REG;
            info.reg_index = state->next_int_reg++;
        } else {
            info.location = PARM_IN_FLOAT_REG;
            info.reg_index = state->next_float_reg++;
        }
        /* hi eightbyte would need a second register — tracked separately in real impl */
        if (hi == CLASS_INTEGER) state->next_int_reg++;
        else if (hi == CLASS_SSE) state->next_float_reg++;

        return info;
    }

    /* Scalar types */
    if (is_float) {
        if (state->next_float_reg < SYSV_NUM_FLOAT_ARGS) {
            info.location = PARM_IN_FLOAT_REG;
            info.reg_index = state->next_float_reg++;
        } else {
            info.location = PARM_ON_STACK;
            info.stack_offset = state->stack_offset;
            state->stack_offset += 8;
            state->num_stack_args++;
        }
    } else {
        if (state->next_int_reg < SYSV_NUM_INT_ARGS) {
            info.location = PARM_IN_INT_REG;
            info.reg_index = state->next_int_reg++;
        } else {
            info.location = PARM_ON_STACK;
            info.stack_offset = state->stack_offset;
            state->stack_offset += 8;
            state->num_stack_args++;
        }
    }
    return info;
}

/* ====================================================================
 * Stack Frame Layout
 * ==================================================================== */

/*
 * SysV AMD64 stack frame (after prologue):
 *
 *   Higher addresses
 *   +-------------------+
 *   | caller's frame    |
 *   +-------------------+
 *   | return address    |  ← RSP at function entry
 *   +-------------------+
 *   | saved RBP         |  ← RBP after "mov rbp, rsp"
 *   +-------------------+
 *   | callee-saved regs |  (RBX, R12-R15 as needed)
 *   +-------------------+
 *   | local variables   |
 *   +-------------------+
 *   | alignment padding |  (ensure 16-byte alignment before CALL)
 *   +-------------------+
 *   | outgoing args     |  (args 7+ passed on stack)
 *   +-------------------+  ← RSP (16-byte aligned before CALL)
 *   | red zone (128b)   |  (usable by leaf functions without SUB RSP)
 *   +-------------------+
 *   Lower addresses
 *
 * Rules:
 * 1. RSP must be 16-byte aligned BEFORE the CALL instruction
 *    (CALL pushes 8 bytes, so RSP is 8-mod-16 at function entry)
 * 2. RBP typically points to saved RBP (if frame pointer used)
 * 3. Red zone: 128 bytes below RSP that leaf functions can use
 *    without adjusting RSP. Signal handlers must not clobber it.
 */

typedef struct {
    int     locals_size;        /* total local variable space */
    int     callee_save_size;   /* space for callee-saved registers */
    int     outgoing_args_size; /* space for outgoing stack arguments */
    int     frame_size;         /* total frame adjustment (SUB RSP, frame_size) */
    int     num_callee_saved;   /* number of callee-saved regs pushed */
    bool    use_frame_pointer;  /* true if using RBP as frame pointer */
    bool    is_leaf;            /* true if function makes no calls */
} sysv_frame_t;

/*
 * Compute the stack frame layout for a function.
 *
 * frame_size must be chosen so that RSP is 16-byte aligned before any CALL.
 * At function entry, RSP ≡ 8 (mod 16) because the CALL pushed the return address.
 * After PUSH RBP, RSP ≡ 0 (mod 16).
 * After pushing N callee-saved regs, RSP ≡ (N * 8) (mod 16) relative to aligned.
 * The SUB RSP must compensate to restore 16-byte alignment before outgoing CALLs.
 */
static void sysv_compute_frame(
    sysv_frame_t *frame,
    int locals_size,
    int max_outgoing_stack_args,
    int num_callee_saved_used,
    bool has_calls)
{
    frame->use_frame_pointer = true; /* always use for now */
    frame->is_leaf = !has_calls;
    frame->num_callee_saved = num_callee_saved_used;
    frame->locals_size = locals_size;
    frame->outgoing_args_size = max_outgoing_stack_args * 8;
    frame->callee_save_size = num_callee_saved_used * 8;

    /* After push rbp: RSP is 16-byte aligned.
     * After pushing N callee-saved regs: need to account for parity.
     * Total frame = locals + outgoing, rounded up to maintain alignment.
     */
    int raw_size = frame->locals_size + frame->outgoing_args_size;

    /* After push rbp + N callee-saves: RSP ≡ ((1 + N) * 8) mod 16 relative to entry.
     * Entry RSP ≡ 8 mod 16 (return address pushed by caller's CALL).
     * So after push rbp + N saves: RSP ≡ (2 + N) * 8 mod 16.
     * If (2 + N) is even → RSP is 16-aligned → raw_size must be multiple of 16.
     * If (2 + N) is odd → RSP is 8 off → raw_size must be 8 mod 16. */
    int pushes = 1 + num_callee_saved_used; /* rbp + callee-saved */
    if ((pushes % 2) == 0) {
        /* Even pushes: RSP already aligned, frame must be multiple of 16 */
        frame->frame_size = (raw_size + 15) & ~15;
    } else {
        /* Odd pushes: RSP is 8 off, frame must be 8 mod 16 */
        frame->frame_size = ((raw_size + 15) & ~15) + 8;
        if (frame->frame_size - raw_size > 15) {
            frame->frame_size -= 16;
        }
    }

    /* Leaf functions with no locals can skip the SUB RSP (use red zone) */
    if (frame->is_leaf && raw_size <= 128 && raw_size > 0) {
        frame->frame_size = 0; /* use red zone */
    }
}

/* ====================================================================
 * Prologue / Epilogue Generation
 * ==================================================================== */

/* Callback interface for code emission — matches Phase 17 pattern */
typedef struct codebuf codebuf_t;
typedef void (*emit_fn)(codebuf_t *c, const uint8_t *bytes, int len);

/*
 * Emit function prologue.
 *
 * Standard prologue:
 *   push rbp
 *   mov rbp, rsp
 *   push <callee-saved regs>     ; as needed
 *   sub rsp, frame_size          ; if non-zero
 *
 * Leaf with red zone:
 *   push rbp
 *   mov rbp, rsp
 *   ; no sub rsp — locals live in red zone
 */

/*
 * Emit function epilogue.
 *
 * Standard epilogue:
 *   add rsp, frame_size          ; if non-zero
 *   pop <callee-saved regs>      ; in reverse order
 *   pop rbp
 *   ret
 *
 * Or with leave:
 *   leave                        ; mov rsp, rbp; pop rbp
 *   ret
 */

/* ====================================================================
 * Varargs Support
 * ==================================================================== */

/*
 * For variadic functions (printf, etc.):
 *
 * Caller:
 *   - Pass args normally (first 6 int in regs, first 8 float in XMM)
 *   - Set AL = number of XMM registers used for variable arguments
 *   - AL is in the range 0-8
 *
 * Callee (va_start):
 *   - Save all 6 integer arg registers to the "register save area"
 *   - Save all 8 XMM registers to the save area (conditional on AL)
 *   - va_list points to the save area
 *
 * The register save area is typically at the bottom of the frame:
 *   6 * 8 = 48 bytes for integer regs
 *   8 * 16 = 128 bytes for XMM regs
 *   Total: 176 bytes
 *
 * For the caller side (which is what the code generator handles),
 * the key rule is: set AL before CALL for varargs functions.
 */

/*
 * Count the number of XMM registers used in a variadic call.
 * This value goes into AL before the CALL instruction.
 */
static int sysv_count_vararg_xmm(sysv_call_state_t *state) {
    return state->next_float_reg;
}

#endif /* X64_SYSV_H */
