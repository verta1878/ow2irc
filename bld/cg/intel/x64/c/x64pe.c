/*
 * x64pe.c — PE32+ (Win64) COFF Object File Writer
 *
 * Generates COFF .obj files for Win64 targets (-bt=nt64).
 * Called from x64obj.c when targeting Windows instead of ELF64.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>

/* COFF Machine Type */
#define IMAGE_FILE_MACHINE_AMD64  0x8664

/* COFF Section Flags */
#define IMAGE_SCN_CNT_CODE            0x00000020
#define IMAGE_SCN_CNT_INITIALIZED     0x00000040
#define IMAGE_SCN_CNT_UNINITIALIZED   0x00000080
#define IMAGE_SCN_ALIGN_8BYTES        0x00400000
#define IMAGE_SCN_ALIGN_16BYTES       0x00500000
#define IMAGE_SCN_MEM_EXECUTE         0x20000000
#define IMAGE_SCN_MEM_READ            0x40000000
#define IMAGE_SCN_MEM_WRITE           0x80000000
#define IMAGE_SCN_MEM_DISCARDABLE     0x02000000
#define IMAGE_SCN_LNK_INFO           0x00000200

/* COFF Relocation Types */
#define IMAGE_REL_AMD64_ABSOLUTE  0x0000
#define IMAGE_REL_AMD64_ADDR64    0x0001
#define IMAGE_REL_AMD64_ADDR32    0x0002
#define IMAGE_REL_AMD64_ADDR32NB  0x0003
#define IMAGE_REL_AMD64_REL32     0x0004
#define IMAGE_REL_AMD64_REL32_1   0x0005
#define IMAGE_REL_AMD64_REL32_2   0x0006
#define IMAGE_REL_AMD64_REL32_3   0x0007
#define IMAGE_REL_AMD64_REL32_4   0x0008
#define IMAGE_REL_AMD64_REL32_5   0x0009
#define IMAGE_REL_AMD64_SECTION   0x000A
#define IMAGE_REL_AMD64_SECREL    0x000B

/* COFF Symbol Storage Classes */
#define IMAGE_SYM_CLASS_EXTERNAL  2
#define IMAGE_SYM_CLASS_STATIC    3
#define IMAGE_SYM_CLASS_FILE      103
#define IMAGE_SYM_CLASS_SECTION   104

/* COFF Symbol Types */
#define IMAGE_SYM_DTYPE_FUNCTION  0x20

#pragma pack(push, 1)

typedef struct {
    uint16_t Machine;
    uint16_t NumberOfSections;
    uint32_t TimeDateStamp;
    uint32_t PointerToSymbolTable;
    uint32_t NumberOfSymbols;
    uint16_t SizeOfOptionalHeader;
    uint16_t Characteristics;
} COFF_FILE_HEADER;

typedef struct {
    char     Name[8];
    uint32_t VirtualSize;
    uint32_t VirtualAddress;
    uint32_t SizeOfRawData;
    uint32_t PointerToRawData;
    uint32_t PointerToRelocations;
    uint32_t PointerToLinenumbers;
    uint16_t NumberOfRelocations;
    uint16_t NumberOfLinenumbers;
    uint32_t Characteristics;
} COFF_SECTION_HEADER;

typedef struct {
    union {
        char ShortName[8];
        struct { uint32_t Zeroes; uint32_t Offset; };
    };
    uint32_t Value;
    int16_t  SectionNumber;
    uint16_t Type;
    uint8_t  StorageClass;
    uint8_t  NumberOfAuxSymbols;
} COFF_SYMBOL;

typedef struct {
    uint32_t VirtualAddress;
    uint32_t SymbolTableIndex;
    uint16_t Type;
} COFF_RELOCATION;

#pragma pack(pop)

/* ====================================================================
 * PE32+ COFF Object Writer
 *
 * Layout:
 *   COFF_FILE_HEADER
 *   COFF_SECTION_HEADER[num_sections]
 *   .text raw data
 *   .rdata raw data (.rodata equivalent)
 *   .data raw data
 *   .pdata raw data (RUNTIME_FUNCTION array)
 *   .xdata raw data (UNWIND_INFO structures)
 *   .text relocations
 *   .rdata relocations
 *   .data relocations
 *   Symbol table
 *   String table
 * ==================================================================== */

bool x64_emit_pe(FILE *fp,
                 const uint8_t *code, int code_len,
                 const uint8_t *rdata, int rdata_len,
                 const uint8_t *data, int data_len,
                 int bss_size,
                 const uint8_t *pdata, int pdata_len,
                 const uint8_t *xdata, int xdata_len,
                 const char *src_filename)
{
    int num_sections = 3;  /* .text, .rdata, .data minimum */
    if (bss_size > 0) num_sections++;
    if (pdata_len > 0) num_sections++;
    if (xdata_len > 0) num_sections++;

    /* Compute file layout offsets */
    uint32_t headers_size = sizeof(COFF_FILE_HEADER) +
                            num_sections * sizeof(COFF_SECTION_HEADER);
    uint32_t text_off = headers_size;
    uint32_t text_pad = (16 - (text_off + code_len) % 16) % 16;
    uint32_t rdata_off = text_off + code_len + text_pad;
    uint32_t rdata_pad = (16 - (rdata_off + rdata_len) % 16) % 16;
    uint32_t data_off = rdata_off + rdata_len + rdata_pad;
    uint32_t data_pad = (16 - (data_off + data_len) % 16) % 16;
    uint32_t pdata_off = data_off + data_len + data_pad;
    uint32_t xdata_off = pdata_off + pdata_len;
    uint32_t symtab_off = xdata_off + xdata_len;

    /* Symbols: .file + 3 section syms + externals */
    int num_symbols = 1 + num_sections;  /* At minimum */

    /* Write COFF file header */
    COFF_FILE_HEADER fhdr;
    memset(&fhdr, 0, sizeof(fhdr));
    fhdr.Machine = IMAGE_FILE_MACHINE_AMD64;
    fhdr.NumberOfSections = num_sections;
    fhdr.TimeDateStamp = (uint32_t)time(NULL);
    fhdr.PointerToSymbolTable = symtab_off;
    fhdr.NumberOfSymbols = num_symbols;
    fhdr.SizeOfOptionalHeader = 0;
    fhdr.Characteristics = 0;
    fwrite(&fhdr, sizeof(fhdr), 1, fp);

    /* Write section headers */
    COFF_SECTION_HEADER shdr;

    /* .text */
    memset(&shdr, 0, sizeof(shdr));
    memcpy(shdr.Name, ".text", 5);
    shdr.SizeOfRawData = code_len;
    shdr.PointerToRawData = text_off;
    shdr.Characteristics = IMAGE_SCN_CNT_CODE |
                           IMAGE_SCN_MEM_EXECUTE |
                           IMAGE_SCN_MEM_READ |
                           IMAGE_SCN_ALIGN_16BYTES;
    fwrite(&shdr, sizeof(shdr), 1, fp);

    /* .rdata */
    memset(&shdr, 0, sizeof(shdr));
    memcpy(shdr.Name, ".rdata", 6);
    shdr.SizeOfRawData = rdata_len;
    shdr.PointerToRawData = rdata_off;
    shdr.Characteristics = IMAGE_SCN_CNT_INITIALIZED |
                           IMAGE_SCN_MEM_READ |
                           IMAGE_SCN_ALIGN_8BYTES;
    fwrite(&shdr, sizeof(shdr), 1, fp);

    /* .data */
    memset(&shdr, 0, sizeof(shdr));
    memcpy(shdr.Name, ".data", 5);
    shdr.SizeOfRawData = data_len;
    shdr.PointerToRawData = data_off;
    shdr.Characteristics = IMAGE_SCN_CNT_INITIALIZED |
                           IMAGE_SCN_MEM_READ |
                           IMAGE_SCN_MEM_WRITE |
                           IMAGE_SCN_ALIGN_8BYTES;
    fwrite(&shdr, sizeof(shdr), 1, fp);

    /* .bss (if needed) */
    if (bss_size > 0) {
        memset(&shdr, 0, sizeof(shdr));
        memcpy(shdr.Name, ".bss", 4);
        shdr.SizeOfRawData = 0;
        shdr.VirtualSize = bss_size;
        shdr.Characteristics = IMAGE_SCN_CNT_UNINITIALIZED |
                               IMAGE_SCN_MEM_READ |
                               IMAGE_SCN_MEM_WRITE;
        fwrite(&shdr, sizeof(shdr), 1, fp);
    }

    /* .pdata (if SEH data exists) */
    if (pdata_len > 0) {
        memset(&shdr, 0, sizeof(shdr));
        memcpy(shdr.Name, ".pdata", 6);
        shdr.SizeOfRawData = pdata_len;
        shdr.PointerToRawData = pdata_off;
        shdr.Characteristics = IMAGE_SCN_CNT_INITIALIZED |
                               IMAGE_SCN_MEM_READ |
                               IMAGE_SCN_ALIGN_8BYTES;
        fwrite(&shdr, sizeof(shdr), 1, fp);
    }

    /* .xdata */
    if (xdata_len > 0) {
        memset(&shdr, 0, sizeof(shdr));
        memcpy(shdr.Name, ".xdata", 6);
        shdr.SizeOfRawData = xdata_len;
        shdr.PointerToRawData = xdata_off;
        shdr.Characteristics = IMAGE_SCN_CNT_INITIALIZED |
                               IMAGE_SCN_MEM_READ |
                               IMAGE_SCN_ALIGN_8BYTES;
        fwrite(&shdr, sizeof(shdr), 1, fp);
    }

    /* Write raw section data */
    fwrite(code, 1, code_len, fp);
    { char pad[16] = {0}; fwrite(pad, 1, text_pad, fp); }
    if (rdata_len > 0) fwrite(rdata, 1, rdata_len, fp);
    { char pad[16] = {0}; fwrite(pad, 1, rdata_pad, fp); }
    if (data_len > 0) fwrite(data, 1, data_len, fp);
    { char pad[16] = {0}; fwrite(pad, 1, data_pad, fp); }
    if (pdata_len > 0) fwrite(pdata, 1, pdata_len, fp);
    if (xdata_len > 0) fwrite(xdata, 1, xdata_len, fp);

    /* Write symbol table */
    COFF_SYMBOL sym;

    /* [0] .file symbol */
    memset(&sym, 0, sizeof(sym));
    memcpy(sym.ShortName, ".file", 5);
    sym.SectionNumber = -2;  /* IMAGE_SYM_DEBUG */
    sym.StorageClass = IMAGE_SYM_CLASS_FILE;
    sym.NumberOfAuxSymbols = 1;
    fwrite(&sym, sizeof(sym), 1, fp);

    /* Aux: filename (18 bytes, padded) */
    char aux[18];
    memset(aux, 0, 18);
    if (src_filename) {
        int slen = strlen(src_filename);
        if (slen > 18) slen = 18;
        memcpy(aux, src_filename, slen);
    }
    fwrite(aux, 18, 1, fp);

    /* Section symbols */
    const char *sect_names[] = {".text", ".rdata", ".data", ".bss", ".pdata", ".xdata"};
    for (int i = 0; i < num_sections; i++) {
        memset(&sym, 0, sizeof(sym));
        memcpy(sym.ShortName, sect_names[i], strlen(sect_names[i]));
        sym.SectionNumber = i + 1;
        sym.StorageClass = IMAGE_SYM_CLASS_STATIC;
        fwrite(&sym, sizeof(sym), 1, fp);
    }

    /* String table (4 bytes = length, then strings) */
    uint32_t strtab_size = 4;  /* Empty string table = just the size field */
    fwrite(&strtab_size, 4, 1, fp);

    return true;
}
