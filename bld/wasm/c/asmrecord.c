/*
 * asmrecord.c — RECORD, UNION, TYPEDEF for wasm
 * GPLv3 — the crew 4free — sysop/0
 */

#include "asmglob.h"
#include "clibext.h"
extern bool StructDef( token_buffer *tokbuf, token_idx i );
#include "asmalloc.h"

/* RECORD bit-field type */
#define MAX_RECORD_FIELDS 32
typedef struct { char name[64]; int width; int position; int defval; } record_field_t;
typedef struct { char name[64]; int total_bits; int num_fields; record_field_t fields[MAX_RECORD_FIELDS]; } record_def_t;

#define MAX_RECORDS 64
static record_def_t records[MAX_RECORDS];
static int num_records = 0;

record_def_t *FindRecord(const char *name) {
    int i;
    for (i = 0; i < num_records; i++)
        if (stricmp(records[i].name, name) == 0) return &records[i];
    return NULL;
}

int AsmRecord(token_buffer *tokbuf, int i) {
    record_def_t *rec; int pos = 0;
    if (num_records >= MAX_RECORDS) return RC_ERROR;
    rec = &records[num_records]; memset(rec, 0, sizeof(*rec));
    if (i > 0) strncpy(rec->name, tokbuf->tokens[i-1].string_ptr, 63);
    i++;
    while (i < tokbuf->count && rec->num_fields < MAX_RECORD_FIELDS) {
        record_field_t *fld = &rec->fields[rec->num_fields];
        strncpy(fld->name, tokbuf->tokens[i].string_ptr, 63); i++;
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == ':') i++;
        if (i < tokbuf->count) { fld->width = atoi(tokbuf->tokens[i].string_ptr); i++; }
        fld->defval = 0;
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == '=') {
            i++; if (i < tokbuf->count) { fld->defval = atoi(tokbuf->tokens[i].string_ptr); i++; }
        }
        fld->position = pos; pos += fld->width; rec->num_fields++;
        if (i < tokbuf->count && tokbuf->tokens[i].string_ptr[0] == ',') i++;
    }
    rec->total_bits = pos; num_records++;
    return RC_OK;
}

unsigned long RecordMask(const char *recname, const char *fieldname) {
    record_def_t *rec = FindRecord(recname); int i;
    if (!rec) return 0;
    for (i = 0; i < rec->num_fields; i++)
        if (stricmp(rec->fields[i].name, fieldname) == 0)
            return ((1UL << rec->fields[i].width) - 1) << rec->fields[i].position;
    return 0;
}

int RecordWidth(const char *recname, const char *fieldname) {
    record_def_t *rec = FindRecord(recname); int i;
    if (!rec) return 0;
    for (i = 0; i < rec->num_fields; i++)
        if (stricmp(rec->fields[i].name, fieldname) == 0) return rec->fields[i].width;
    return 0;
}

int AsmUnion(token_buffer *tokbuf, int i) {
    return StructDef(tokbuf, i);
}

int AsmTypedef(token_buffer *tokbuf, int i) {
    (void)tokbuf; (void)i;
    return RC_OK;
}

void AsmRecordInit(void) { num_records = 0; }
void AsmRecordFini(void) { num_records = 0; }
