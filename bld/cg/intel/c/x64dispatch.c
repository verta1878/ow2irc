#include "_cgstd.h"
#include "coderep.h"
#include "model.h"
#include "cgswitch.h"
#include "feprotos.h"
#include <string.h>

static bool x64_elf_active = false;

/* Prototypes — suppress W131 */
void X64SetActive( bool active );
bool X64CheckDispatch( void );
bool X64IsActive( void );

void X64SetActive( bool active ) { x64_elf_active = active; }

bool X64CheckDispatch( void )
{
    /* Check if the output filename ends in .o (ELF convention)
     * vs .obj (OMF convention). Set by -bt=linux64 → TS_DOS + -fo=xxx.o */
    if( !x64_elf_active ) {
        const char *name = FEAuxInfo( NULL, FEINF_OBJECT_FILE_NAME );
        if( name != NULL ) {
            int len = strlen(name);
            /* Exactly a ".o" suffix means ELF output. Testing the character
             * before the dot was wrong: it rejected any name ending "b.o"
             * (e.g. "glob.o") while ".obj" is already excluded by the final
             * character test. */
            if( len > 2 && name[len-2] == '.' && name[len-1] == 'o' ) {
                x64_elf_active = true;
            }
        }
    }
    return( x64_elf_active );
}

bool X64IsActive( void ) { return( x64_elf_active ); }
