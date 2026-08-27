# wpp64 Builder Control file
set PROJNAME=wpp64
set BINTOOL=0
set PROJDIR=<CWD>
[ INCLUDE "<OWROOT>/build/prolog.ctl" ]
[ INCLUDE "<OWROOT>/build/defrule.ctl" ]
[ BLOCK <BLDRULE> rel ]
    cdsay "<PROJDIR>"
[ BLOCK <BINTOOL> build ]
    cdsay "<PROJDIR>"
    <CPCMD> <OWOBJDIR>/bwppx64.exe "<OWROOT>/build/<OWOBJDIR>/bwppx64<CMDEXT>"
[ BLOCK <BINTOOL> clean ]
    rm -f "<OWROOT>/build/<OWOBJDIR>/bwppx64<CMDEXT>"
[ BLOCK . . ]
[ INCLUDE "<OWROOT>/build/epilog.ctl" ]
