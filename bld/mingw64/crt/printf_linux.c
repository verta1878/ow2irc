/*
 * printf_linux.c — printf for OW2IRC Linux x64 runtime
 * OW cdecl: all args on stack (including fmt).
 * After CALL: [RSP] = return addr, [RSP+8] = fmt, [RSP+16..] = args
 *
 * the crew 4free
 */

static long _sys_write(int fd, const void *buf, long len) {
    long ret;
    __asm__ volatile("syscall" : "=a"(ret) : "a"(1), "D"(fd), "S"(buf), "d"(len) : "rcx","r11","memory");
    return ret;
}

static void _out(char c) { _sys_write(1, &c, 1); }
static void _outs(const char *s) { if(!s){_outs("(null)");return;} while(*s) _out(*s++); }

static void _outint(long long v, int base, int is_signed) {
    char buf[24]; int i = 0; int neg = 0;
    unsigned long long u;
    if (is_signed && v < 0) { neg = 1; u = -v; } else { u = v; }
    if (u == 0) buf[i++] = '0';
    else while (u) { int d = u % base; buf[i++] = d<10?'0'+d:'a'+d-10; u /= base; }
    if (neg) _out('-');
    while (i--) _out(buf[i]);
}

/*
 * Entry: OW pushes all args on stack (cdecl for variadics).
 * The asm wrapper grabs RSP, skips return address, passes arg pointer.
 */
__asm__(
    ".global printf\n"
    ".type printf, @function\n"
    "printf:\n"
    "    push %rbp\n"
    "    mov  %rsp, %rbp\n"
    "    lea  16(%rbp), %rdi\n"    /* RDI = &fmt (skip saved RBP + return addr) */
    "    mov  (%rdi), %rdi\n"      /* RDI = fmt string pointer */
    "    lea  24(%rbp), %rsi\n"    /* RSI = &args[0] (first vararg) */
    "    call _printf_core\n"
    "    pop  %rbp\n"
    "    ret\n"
);

void _printf_core(const char *fmt, long *args) {
    int ai = 0;
    while (*fmt) {
        if (*fmt != '%') { _out(*fmt++); continue; }
        fmt++;
        int is_long = 0;
        if (*fmt == 'l') { is_long++; fmt++; }
        if (*fmt == 'l') { is_long++; fmt++; }
        switch (*fmt) {
        case 'd': case 'i': _outint(args[ai++], 10, 1); break;
        case 'u': _outint(args[ai++], 10, 0); break;
        case 'x': case 'X': _outint(args[ai++], 16, 0); break;
        case 's': _outs((const char *)args[ai++]); break;
        case 'c': _out((char)args[ai++]); break;
        case '%': _out('%'); break;
        default: _out('%'); _out(*fmt); break;
        }
        fmt++;
    }
}
