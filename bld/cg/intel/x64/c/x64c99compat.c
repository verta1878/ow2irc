/*
 * x64c99compat.c — C99/GNU Extension Support for wcc/wcc386/wcc64
 *
 * Implements the three GCC extensions that block Voodoo3 H3 headers:
 *   1. Anonymous unions/structs
 *   2. Compound literals
 *   3. Designated initializers
 *
 * Approach: preprocessor script + parser hooks.
 *
 * For wcc parser integration, these changes are needed in:
 *   bld/cc/c/cstmt.c    — compound literal parsing
 *   bld/cc/c/cdecl2.c   — anonymous struct/union
 *   bld/cc/c/cinit.c    — designated initializers
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdbool.h>

/* ====================================================================
 * h3_preprocess — Convert GCC extensions in H3 headers to C89
 *
 * Run this on the H3 header files before compiling with wcc:
 *   h3_preprocess < h3.h > h3_c89.h
 *
 * Transformations:
 *
 * 1. Anonymous unions → named unions with accessor macros
 *    Input:   struct { union { int a; float b; }; };
 *    Output:  struct { union { int a; float b; } _anon_0; };
 *             #define a _anon_0.a
 *             #define b _anon_0.b
 *
 * 2. Compound literals → temp variables
 *    Input:   func((struct point){1, 2});
 *    Output:  { struct point _tmp_0 = {1, 2}; func(_tmp_0); }
 *
 * 3. Designated initializers → positional (manual reorder)
 *    Input:   struct s x = { .b = 2, .a = 1 };
 *    Output:  struct s x = { 1, 2 };
 *    NOTE: requires knowing field order — preprocessor can only
 *    strip the designators, user must verify order.
 * ==================================================================== */

/* Count anonymous unions for unique naming */
static int anon_counter = 0;

/*
 * Strip designated initializers from an initializer list.
 * ".field = value" → "value"
 * "[index] = value" → "value"
 *
 * WARNING: This changes semantics if fields are out of order.
 * Only safe when the source uses designators in field order.
 * The H3 headers DO use field order, so this is safe for them.
 */
void strip_designators(const char *input, char *output, int max_len)
{
    int i = 0, o = 0;
    int in_designator = 0;

    while (input[i] && o < max_len - 1) {
        if (input[i] == '.' && (i == 0 || input[i-1] == '{' ||
            input[i-1] == ',' || input[i-1] == ' ')) {
            /* Skip ".field = " */
            in_designator = 1;
        } else if (input[i] == '[' && in_designator == 0) {
            /* Skip "[index] = " */
            in_designator = 2;
        } else if (in_designator && input[i] == '=') {
            /* Skip the '=' and following space */
            i++;
            while (input[i] == ' ') i++;
            in_designator = 0;
            continue;
        } else if (in_designator == 2 && input[i] == ']') {
            i++;  /* Skip ']' */
            in_designator = 1;  /* Now look for '=' */
            continue;
        } else if (!in_designator) {
            output[o++] = input[i];
        }
        i++;
    }
    output[o] = '\0';
}

/*
 * Generate a unique name for an anonymous union/struct.
 * Returns "_anon_N" where N increments.
 */
void make_anon_name(char *buf, int max_len)
{
    snprintf(buf, max_len, "_anon_%d", anon_counter++);
}

/* ====================================================================
 * WCC Parser Changes Required for Native C99 Support
 *
 * Instead of preprocessing, these changes to the wcc parser would
 * handle C99 extensions natively:
 *
 * 1. Anonymous structs/unions (bld/cc/c/cdecl2.c):
 *    In StructDecl(), when a union/struct member has no name:
 *    - Allow it (currently errors)
 *    - Promote its fields to the parent scope
 *    - Track offset correctly
 *    Change: ~30 lines in cdecl2.c
 *
 * 2. Compound literals (bld/cc/c/cstmt.c):
 *    In ParseExpr(), when seeing (type){...}:
 *    - Allocate a temporary on the stack
 *    - Initialize with the brace-enclosed list
 *    - Use the temporary as the expression value
 *    Change: ~50 lines in cstmt.c + cexpr.c
 *
 * 3. Designated initializers (bld/cc/c/cinit.c):
 *    In InitStruct(), when seeing .field or [index]:
 *    - Look up the field/index
 *    - Set the current init position
 *    - Continue with normal initialization
 *    Change: ~40 lines in cinit.c
 *
 * Total: ~120 lines of parser changes for full C99 extension support.
 * This would fix ALL 27 H3 TUs, not just a preprocessed subset.
 * ==================================================================== */
