# x64 CG Builder Control file
set PROJNAME=cgx64
set BINTOOL=0
set PROJDIR=<CWD>
[ INCLUDE "<OWROOT>/build/prolog.ctl" ]
[ INCLUDE "<OWROOT>/build/deflib.ctl" ]
[ BLOCK <BLDRULE> rel ]
    cdsay "<PROJDIR>"
[ BLOCK <BINTOOL> build ]
    cdsay "<PROJDIR>"
    <CPCMD> <OWOBJDIR>/cgx64.lib "<OWROOT>/build/<OWOBJDIR>/cgx64.lib"
    <CPCMD> <OWOBJDIR>/cgx64lnx.lib "<OWROOT>/build/<OWOBJDIR>/cgx64lnx.lib"
[ BLOCK <BINTOOL> clean ]
    rm -f "<OWROOT>/build/<OWOBJDIR>/cgx64.lib"
    rm -f "<OWROOT>/build/<OWOBJDIR>/cgx64lnx.lib"
[ BLOCK . . ]
[ INCLUDE "<OWROOT>/build/epilog.ctl" ]
