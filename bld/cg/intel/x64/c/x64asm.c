/*
 * x64asm.c — x86-64 Instruction Encoding for wasm x64
 *
 * Low-level instruction encoding functions for the x86-64 target.
 * Used by both wasm (assembler) and x64obj.c (code generator).
 *
 * Each function encodes ONE instruction into a byte buffer.
 * Returns the number of bytes written.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "x64asm.h"

/* ====================================================================
 * Instruction Encoding Functions
 *
 * Pattern: encode_<mnemonic>(buf, operands...) → bytes written
 * All functions write to buf[] and return length.
 * Caller manages buf position.
 * ==================================================================== */

/*
 * Encode REX prefix if needed.
 * Returns 0 or 1 byte written.
 */
int x64_encode_rex(uint8_t *buf, bool w, x64_reg_t reg, x64_reg_t rm)
{
    bool r = reg_needs_rex(reg);
    bool b = reg_needs_rex(rm);

    if (w || r || b) {
        buf[0] = make_rex(w, r, false, b);
        return 1;
    }
    return 0;  /* No REX needed */
}

/*
 * MOV reg, reg — register to register move
 * 89 /r (32-bit) or REX.W 89 /r (64-bit)
 */
int x64_encode_mov_rr(uint8_t *buf, x64_reg_t dst, x64_reg_t src, x64_opsz_t size)
{
    int n = 0;
    if (size == OPSZ_16) buf[n++] = 0x66;  /* Operand size prefix */
    n += x64_encode_rex(buf + n, size == OPSZ_64, src, dst);
    buf[n++] = (size == OPSZ_8) ? 0x88 : 0x89;
    buf[n++] = make_modrm(3, reg_encoding(src), reg_encoding(dst));
    return n;
}

/*
 * MOV reg, imm — immediate to register
 * B8+rd (32-bit) or REX.W B8+rd (64-bit, 8-byte immediate)
 */
int x64_encode_mov_ri(uint8_t *buf, x64_reg_t dst, uint64_t imm, x64_opsz_t size)
{
    int n = 0;
    if (size == OPSZ_16) buf[n++] = 0x66;
    n += x64_encode_rex(buf + n, size == OPSZ_64, REG_RAX, dst);
    buf[n++] = 0xB8 + reg_encoding(dst);  /* B8+rd */
    if (size == OPSZ_64) {
        memcpy(buf + n, &imm, 8);  /* 8-byte immediate */
        n += 8;
    } else if (size == OPSZ_32) {
        uint32_t imm32 = (uint32_t)imm;
        memcpy(buf + n, &imm32, 4);
        n += 4;
    } else if (size == OPSZ_16) {
        uint16_t imm16 = (uint16_t)imm;
        memcpy(buf + n, &imm16, 2);
        n += 2;
    } else {
        buf[n++] = (uint8_t)imm;
    }
    return n;
}

/*
 * MOV reg, [RIP+disp32] — RIP-relative memory load
 * REX.W 8B /05 disp32
 */
int x64_encode_mov_rip(uint8_t *buf, x64_reg_t dst, int32_t disp, x64_opsz_t size)
{
    int n = 0;
    n += x64_encode_rex(buf + n, size == OPSZ_64, dst, REG_RBP);
    buf[n++] = 0x8B;
    buf[n++] = make_modrm(0, reg_encoding(dst), 5);  /* mod=00, rm=101 = RIP */
    memcpy(buf + n, &disp, 4);
    n += 4;
    return n;
}

/*
 * PUSH reg
 * 50+rd (no REX.W needed — PUSH is always 64-bit in x64 mode)
 */
int x64_encode_push(uint8_t *buf, x64_reg_t reg)
{
    int n = 0;
    if (reg_needs_rex(reg)) {
        buf[n++] = make_rex(false, false, false, true);
    }
    buf[n++] = 0x50 + reg_encoding(reg);
    return n;
}

/*
 * POP reg
 * 58+rd
 */
int x64_encode_pop(uint8_t *buf, x64_reg_t reg)
{
    int n = 0;
    if (reg_needs_rex(reg)) {
        buf[n++] = make_rex(false, false, false, true);
    }
    buf[n++] = 0x58 + reg_encoding(reg);
    return n;
}

/*
 * SUB reg, imm32
 * REX.W 81 /5 imm32
 */
int x64_encode_sub_ri(uint8_t *buf, x64_reg_t reg, int32_t imm)
{
    int n = 0;
    n += x64_encode_rex(buf + n, true, REG_RBP, reg);  /* /5 = RBP encoding */

    if (imm >= -128 && imm <= 127) {
        buf[n++] = 0x83;  /* SUB r/m64, imm8 */
        buf[n++] = make_modrm(3, 5, reg_encoding(reg));
        buf[n++] = (uint8_t)(int8_t)imm;
    } else {
        buf[n++] = 0x81;  /* SUB r/m64, imm32 */
        buf[n++] = make_modrm(3, 5, reg_encoding(reg));
        memcpy(buf + n, &imm, 4);
        n += 4;
    }
    return n;
}

/*
 * ADD reg, imm32
 * REX.W 81 /0 imm32
 */
int x64_encode_add_ri(uint8_t *buf, x64_reg_t reg, int32_t imm)
{
    int n = 0;
    n += x64_encode_rex(buf + n, true, REG_RAX, reg);

    if (imm >= -128 && imm <= 127) {
        buf[n++] = 0x83;
        buf[n++] = make_modrm(3, 0, reg_encoding(reg));
        buf[n++] = (uint8_t)(int8_t)imm;
    } else {
        buf[n++] = 0x81;
        buf[n++] = make_modrm(3, 0, reg_encoding(reg));
        memcpy(buf + n, &imm, 4);
        n += 4;
    }
    return n;
}

/*
 * CALL rel32 — near call with 32-bit relative displacement
 * E8 rel32
 */
int x64_encode_call_rel32(uint8_t *buf, int32_t rel)
{
    buf[0] = 0xE8;
    memcpy(buf + 1, &rel, 4);
    return 5;
}

/*
 * RET — near return
 * C3
 */
int x64_encode_ret(uint8_t *buf)
{
    buf[0] = 0xC3;
    return 1;
}

/*
 * NOP
 * 90
 */
int x64_encode_nop(uint8_t *buf)
{
    buf[0] = 0x90;
    return 1;
}

/*
 * SYSCALL — Linux system call
 * 0F 05
 */
int x64_encode_syscall(uint8_t *buf)
{
    buf[0] = 0x0F;
    buf[1] = 0x05;
    return 2;
}

/*
 * XOR reg, reg — zero a register (common idiom)
 * 31 /r (32-bit XOR zero-extends to 64-bit)
 */
int x64_encode_xor_rr(uint8_t *buf, x64_reg_t dst, x64_reg_t src)
{
    int n = 0;
    /* Use 32-bit XOR (no REX.W) — zero-extends, saves a byte */
    if (reg_needs_rex(dst) || reg_needs_rex(src)) {
        n += x64_encode_rex(buf + n, false, src, dst);
    }
    buf[n++] = 0x31;
    buf[n++] = make_modrm(3, reg_encoding(src), reg_encoding(dst));
    return n;
}

/*
 * LEA reg, [RIP+disp32] — load effective address, RIP-relative
 * REX.W 8D /05 disp32
 */
int x64_encode_lea_rip(uint8_t *buf, x64_reg_t dst, int32_t disp)
{
    int n = 0;
    n += x64_encode_rex(buf + n, true, dst, REG_RBP);
    buf[n++] = 0x8D;
    buf[n++] = make_modrm(0, reg_encoding(dst), 5);
    memcpy(buf + n, &disp, 4);
    n += 4;
    return n;
}
