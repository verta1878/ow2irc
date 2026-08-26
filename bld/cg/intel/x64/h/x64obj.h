/* x64obj.h — x64 ELF64 object output via OWL
 * Extern declarations for functions in x64obj.c
 * Called by x86obj.c when X64IsActive() is true. */

#ifndef X64OBJ_H
#define X64OBJ_H

extern void X64ObjInit( void );
extern void X64ObjFini( void );
extern void X64GenObject( void );

/* Output redirectors — called from x86obj.c Out* functions */
extern void X64OutDBytes( unsigned len, const byte *src );
extern void X64OutDataByte( byte value );
extern void X64OutDataShort( unsigned short value );
extern void X64OutDataLong( unsigned long value );
extern void X64OutIBytes( byte pattern, unsigned long len );
extern void X64OutLabel( const char *name );
extern void X64ObjLabel( const char *name, bool is_global );

extern void X64SetCodeMode( bool is_code );

#endif /* X64OBJ_H */

/* Import/relocation support */
extern void X64TrackBytes( unsigned len );
extern void X64OutImport( const char *sym_name );
extern void X64OutPatchImport( const char *sym_name );
