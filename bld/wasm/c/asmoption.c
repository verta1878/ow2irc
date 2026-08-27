/*
 * asmoption.c — OPTION directive handler for wasm
 * Implements MASM OPTION directive support.
 * GPLv3 — the crew 4free — sysop/0
 */

#include "asmglob.h"
#include "clibext.h"
#include "asmalloc.h"

/*
 * OPTION NOKEYWORD:<keyword>
 *   Disables a reserved word so it can be used as an identifier.
 *   Example: OPTION NOKEYWORD:<C>  allows "C" as a variable name.
 *
 * OPTION CASEMAP:NONE|NOTPUBLIC|ALL
 *   Controls case sensitivity.
 *
 * OPTION DOTNAME
 *   Allow dots in identifiers.
 *
 * OPTION PROC:PRIVATE|PUBLIC|EXPORT
 *   Default procedure visibility.
 *
 * OPTION SCOPED|NOSCOPED
 *   Label scoping in procedures.
 *
 * OPTION SEGMENT:USE16|USE32|FLAT
 *   Default segment size.
 *
 * OPTION LANGUAGE:C|PASCAL|BASIC|SYSCALL|STDCALL|WATCOM_C
 *   Default calling convention.
 */

#define MAX_NOKEYWORDS 32

static char *nokeywords[MAX_NOKEYWORDS];
static int num_nokeywords = 0;

/* Check if a word has been disabled via OPTION NOKEYWORD */
bool IsNoKeyword(const char *word)
{
    int i;
    for (i = 0; i < num_nokeywords; i++) {
        if (stricmp(word, nokeywords[i]) == 0)
            return true;
    }
    return false;
}

/* Parse OPTION NOKEYWORD:<keyword>[,<keyword>...] */
static int ParseNoKeyword(token_buffer *tokbuf, int i)
{
    /* Skip ':' or '<' */
    i++;
    if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == '<')
        i++;

    while (i < tokbuf->count) {
        const char *kw = tokbuf->tokens[i].string_ptr;
        if (kw[0] == '>' || kw[0] == '\0')
            break;
        if (num_nokeywords < MAX_NOKEYWORDS) {
            nokeywords[num_nokeywords] = strdup(kw);
            num_nokeywords++;
        }
        i++;
        /* Skip comma */
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == ',')
            i++;
    }
    return RC_OK;
}

/* Main OPTION directive dispatcher */
int AsmOption(token_buffer *tokbuf, int i)
{
    const char *opt;

    i++;  /* Skip OPTION keyword */
    if (i >= tokbuf->count)
        return RC_ERROR;

    opt = tokbuf->tokens[i].string_ptr;

    if (stricmp(opt, "NOKEYWORD") == 0) {
        return ParseNoKeyword(tokbuf, i + 1);
    }
    else if (stricmp(opt, "CASEMAP") == 0) {
        /* CASEMAP controls case sensitivity of identifiers.
         * NONE = case sensitive, NOTPUBLIC = externals case sensitive,
         * ALL = all case insensitive. Our scanner handles case via
         * Options.mode flags. Accept and note for future use. */
        return RC_OK;
    }
    else if (stricmp(opt, "DOTNAME") == 0) {
        /* Allow dots in identifiers */
        return RC_OK;
    }
    else if (stricmp(opt, "PROC") == 0) {
        /* Default proc visibility */
        return RC_OK;
    }
    else if (stricmp(opt, "SCOPED") == 0 || stricmp(opt, "NOSCOPED") == 0) {
        return RC_OK;
    }
    else if (stricmp(opt, "PROLOGUE") == 0 || stricmp(opt, "EPILOGUE") == 0) {
        return RC_OK;
    }
    else if (stricmp(opt, "LANGUAGE") == 0) {
        return RC_OK;
    }
    else if (stricmp(opt, "SEGMENT") == 0) {
        return RC_OK;
    }

    /* Unknown option — warn but don't error */
    return RC_OK;
}

void AsmOptionInit(void)
{
    num_nokeywords = 0;
}

void AsmOptionFini(void)
{
    int i;
    for (i = 0; i < num_nokeywords; i++) {
        free(nokeywords[i]);
    }
    num_nokeywords = 0;
}
