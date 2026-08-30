#include <winbase.h>

#ifndef __LIBMSVCRT_OS__

#endif

static inline HANDLE __mingw_get_msvcrt_handle(void)
{
    return GetModuleHandleW(L"msvcrt.dll");
}
