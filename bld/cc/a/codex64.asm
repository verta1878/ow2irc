;*****************************************************************************
;*  OpenWatcom 2 IRC — x86-64 Pragma Code Bursts
;*  GPLv3 — the crew 4free — sysop/0
;*
;*  Inline intrinsics for x64 target. These are raw instruction
;*  sequences the compiler inserts directly. Uses 386-compatible
;*  instructions (REP MOVS, STOS, SCAS, CMPS) which work in
;*  64-bit mode. The CG handles REX prefixes.
;*
;*  Register usage follows x86 string conventions:
;*    EDI = destination, ESI = source, ECX = count, EAX = value
;*  These map to RDI/RSI/RCX/RAX in 64-bit mode via REX.W.
;*****************************************************************************

.386p

include struct.inc

; Code burst macros — same format as code386.asm
beginb  macro   name
_&name&_name:
        db      "&name&",0
public  _&name
_&name:
        db      E_&name - _&name - 1
endm

endb    macro   name
E_&name:
endm

defsb    macro   name
_&name&_defs:
endm

func    macro   name
        dw      _&name&_defs - module_start
        dw      _&name&_name - module_start
        dw      _&name - module_start
        endm


        name    codex64

_DATA   segment word public 'DATA'
        assume  CS:_DATA

module_start:
        dw      _Functions - module_start

;=====================================================================
; C_strlen — scan for NUL, return length in EAX
; EDI = string pointer
;=====================================================================
defsb   C_strlen
        db      "#define C_strlen_ret   HW_D( HW_EAX )",0
        db      "#define C_strlen_parms P_EDI",0
        db      "#define C_strlen_saves HW_NotD_2( HW_ECX, HW_EDI )",0
beginb  C_strlen
        push    edi
        xor     ecx,ecx
        dec     ecx
        xor     eax,eax
        repne   scasb
        not     ecx
        dec     ecx
        mov     eax,ecx
        pop     edi
endb    C_strlen

;=====================================================================
; C_strcpy — copy string, return dest in EDI
; EDI = dest, ESI = src
;=====================================================================
defsb   C_strcpy
        db      "#define C_strcpy_ret   HW_D( HW_EDI )",0
        db      "#define C_strcpy_parms P_EDI_ESI",0
        db      "#define C_strcpy_saves HW_NotD_2( HW_EAX, HW_ESI )",0
beginb  C_strcpy
        push    edi
L_cpy1: lodsb
        stosb
        test    al,al
        jne     short L_cpy1
        pop     edi
endb    C_strcpy

;=====================================================================
; C_strcmp — compare strings, return <0/0/>0 in EAX
; EDI = s1, ESI = s2
;=====================================================================
defsb   C_strcmp
        db      "#define C_strcmp_ret   HW_D( HW_EAX )",0
        db      "#define C_strcmp_parms P_EDI_ESI",0
        db      "#define C_strcmp_saves HW_NotD_2( HW_ESI, HW_EDI )",0
beginb  C_strcmp
L_cmp1: lodsb
        scasb
        jne     short L_cmp2
        test    al,al
        jne     short L_cmp1
        xor     eax,eax
        jmp     short L_cmp3
L_cmp2: sbb     eax,eax
        or      eax,1
L_cmp3:
endb    C_strcmp

;=====================================================================
; C_strcat — concatenate strings
; EDI = dest, ESI = src
;=====================================================================
defsb   C_strcat
        db      "#define C_strcat_ret   HW_D( HW_EDI )",0
        db      "#define C_strcat_parms P_EDI_ESI",0
        db      "#define C_strcat_saves HW_NotD_2( HW_EAX, HW_ESI )",0
beginb  C_strcat
        push    edi
        xor     ecx,ecx
        dec     ecx
        xor     eax,eax
        repne   scasb
        dec     edi
L_cat1: lodsb
        stosb
        test    al,al
        jne     short L_cat1
        pop     edi
endb    C_strcat

;=====================================================================
; C_memcpy — copy memory, return dest in EDI
; EDI = dest, ESI = src, ECX = byte count
;=====================================================================
defsb   C_memcpy
        db      "#define C_memcpy_ret   HW_D( HW_EDI )",0
        db      "#define C_memcpy_parms P_EDI_ESI_ECX",0
        db      "#define C_memcpy_saves HW_NotD_2( HW_ESI, HW_ECX )",0
beginb  C_memcpy
        push    edi
        push    ecx
        shr     ecx,2
        rep     movsd
        pop     ecx
        and     ecx,3
        rep     movsb
        pop     edi
endb    C_memcpy

;=====================================================================
; C_memset — fill memory, return dest in EDI
; EDI = dest, EAX = fill byte, ECX = byte count
;=====================================================================
defsb   C_memset
        db      "#define C_memset_ret   HW_D( HW_EDI )",0
        db      "#define C_memset_parms P_EDI_EAX_ECX",0
        db      "#define C_memset_saves HW_NotD_1( HW_ECX )",0
beginb  C_memset
        push    edi
        push    ecx
        mov     ah,al
        push    ax
        push    ax
        pop     eax
        shr     ecx,2
        rep     stosd
        pop     ecx
        and     ecx,3
        rep     stosb
        pop     edi
endb    C_memset

;=====================================================================
; C_memcmp — compare memory, return <0/0/>0 in EAX
; EDI = s1, ESI = s2, ECX = byte count
;=====================================================================
defsb   C_memcmp
        db      "#define C_memcmp_ret   HW_D( HW_EAX )",0
        db      "#define C_memcmp_parms P_EDI_ESI_ECX",0
        db      "#define C_memcmp_saves HW_NotD_2( HW_ESI, HW_EDI )",0
beginb  C_memcmp
        xor     eax,eax
        repe    cmpsb
        je      short L_mcm1
        sbb     eax,eax
        or      eax,1
L_mcm1:
endb    C_memcmp

;=====================================================================
; C_memchr — find byte in memory, return pointer in EDI or NULL
; EDI = buf, EAX = byte, ECX = count
;=====================================================================
defsb   C_memchr
        db      "#define C_memchr_ret   HW_D( HW_EDI )",0
        db      "#define C_memchr_parms P_EDI_EAX_ECX",0
        db      "#define C_memchr_saves HW_NotD_1( HW_ECX )",0
beginb  C_memchr
        repne   scasb
        jne     short L_mcr1
        dec     edi
        jmp     short L_mcr2
L_mcr1: xor     edi,edi
L_mcr2:
endb    C_memchr

;=====================================================================
; C_abs — absolute value of EAX
;=====================================================================
defsb   C_abs
        db      "#define C_abs_ret   HW_D( HW_EAX )",0
        db      "#define C_abs_parms P_EAX",0
        db      "#define C_abs_saves HW_NotD_1( HW_EDX )",0
beginb  C_abs
        cdq
        xor     eax,edx
        sub     eax,edx
endb    C_abs

;=====================================================================
; Function table — lists all available intrinsics
;=====================================================================
_Functions:
        func    C_strlen
        func    C_strcpy
        func    C_strcmp
        func    C_strcat
        func    C_memcpy
        func    C_memset
        func    C_memcmp
        func    C_memchr
        func    C_abs
        dw      0,0,0

_DATA   ends

        end
