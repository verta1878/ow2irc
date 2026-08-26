# wcc64 Builder Control file
# ===========================

set PROJNAME=wcc64

set BINTOOL=0

set PROJDIR=<CWD>

[ INCLUDE "<OWROOT>/build/prolog.ctl" ]

[ INCLUDE "<OWROOT>/build/defrule.ctl" ]

[ BLOCK <BLDRULE> rel ]
#======================
    cdsay "<PROJDIR>"

[ BLOCK <BINTOOL> build ]
#========================
    cdsay "<PROJDIR>"
    <CPCMD> <OWOBJDIR>/bwcc64.exe     "<OWROOT>/build/<OWOBJDIR>/bwcc64<CMDEXT>"

[ BLOCK <BINTOOL> clean ]
#========================
    echo rm -f "<OWROOT>/build/<OWOBJDIR>/bwcc64<CMDEXT>"
    rm -f "<OWROOT>/build/<OWOBJDIR>/bwcc64<CMDEXT>"

[ BLOCK <BLDRULE> rel cprel ]
#============================
    <CCCMD> linuxx64/<OWOBJDIR>/wcc64.exe      "<OWRELROOT>/binl64/wcc64"
    <CCCMD> linuxx64/<OWOBJDIR>/wcc6401.int     "<OWRELROOT>/binl64/"

[ BLOCK . . ]

[ INCLUDE "<OWROOT>/build/epilog.ctl" ]
