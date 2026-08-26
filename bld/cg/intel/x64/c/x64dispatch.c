#include "_cgstd.h"
#include "coderep.h"
#include "model.h"
#include "cgswitch.h"

static bool x64_elf_active = false;

bool X64CheckDispatch( void )
{
    /* Check custom flag set by -bt=linux64 in cmdlnx86.c */
    if( (TargetModel & 0x80000000u) ) {
        x64_elf_active = true;
        return( true );
    }
    x64_elf_active = false;
    return( false );
}

bool X64IsActive( void )
{
    return( x64_elf_active );
}
