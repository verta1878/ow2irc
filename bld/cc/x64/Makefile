# bwccx64 Makefile — standalone build for Linux x64
# Run: make OWROOT=/path/to/openwatcom2irc-r0.6.0
# Requires: gcc, OW build already run (for .obj files and libs)
# GPLv3 — the crew 4free — sysop/0

OWROOT ?= $(shell cd ../../.. && pwd)
BLDDIR = $(OWROOT)/bld

CC = gcc
CFLAGS = -g -O2 -w \
  -I$(BLDDIR)/cc/h \
  -I$(BLDDIR)/cc/x64 \
  -I$(BLDDIR)/cg/h \
  -I$(BLDDIR)/cg/intel/h \
  -I$(BLDDIR)/cg/intel/386/h \
  -I$(BLDDIR)/cg/intel/x64/h \
  -I$(BLDDIR)/watcom/h \
  -I$(BLDDIR)/dwarf/dw/h \
  -I$(BLDDIR)/wasm/h \
  -I$(BLDDIR)/fe_misc/h \
  -I$(BLDDIR)/owl/h \
  -Ibinbuild \
  -D_CPU=386 -DBOOTSTRAP -D__UNIX__ -D__LINUX__

# Libraries (built during build.sh)
LIBS = \
  $(BLDDIR)/cg/intel/x64/binbuild/cgx64.lib \
  $(BLDDIR)/cg/intel/x64/binbuild/cgx64lnx.lib \
  $(BLDDIR)/watcom/binbuild/clibext.lib \
  $(BLDDIR)/dwarf/dw/binbuild/dwarfw.lib \
  $(BLDDIR)/cfloat/binbuild/cf.lib

LDFLAGS = -lm -no-pie

# CC front-end sources
CC_SRCS = $(wildcard $(BLDDIR)/cc/c/*.c)

# Inline assembler sources (compiled WITHOUT _STANDALONE_)
ASM_SRCS = $(addprefix $(BLDDIR)/wasm/c/, \
  asmins.c asmscan.c asmline.c asmsym.c tbyte.c \
  asmlabel.c asmfixup.c asmmatch.c asmdata.c \
  asmjump.c asmexpnd.c asmeval.c asmoption.c)

# Target-specific sources
X64_SRCS = $(BLDDIR)/cc/c/cmdlnx86.c \
           $(BLDDIR)/cc/c/cpragx86.c \
           $(BLDDIR)/cc/c/prag386.c

CC_OBJS = $(patsubst $(BLDDIR)/cc/c/%.c,binbuild/%.obj,$(CC_SRCS))
ASM_OBJS = $(patsubst $(BLDDIR)/wasm/c/%.c,binbuild/%.obj,$(ASM_SRCS))

ALL_OBJS = $(wildcard binbuild/*.obj)

.PHONY: all link clean

all: binbuild/bwccx64
	@echo "=== bwccx64 built ==="
	@ls -lh binbuild/bwccx64

# Link using whatever .obj files exist (from build.sh + our extras)
binbuild/bwccx64: asm_objs
	$(CC) -o $@ binbuild/*.obj $(LIBS) $(LDFLAGS)
	chmod +x $@
	cp $@ $(OWROOT)/build/binbuild/bwccx64

# Compile inline asm objects without _STANDALONE_
asm_objs:
	@mkdir -p binbuild
	@for src in $(ASM_SRCS); do \
	  obj=binbuild/$$(basename $$src .c).obj; \
	  if [ ! -f "$$obj" ] || [ "$$src" -nt "$$obj" ]; then \
	    echo "  CC $$src"; \
	    $(CC) -c $(CFLAGS) -Ibinbuild $$src -o $$obj; \
	  fi; \
	done

# Link only (objects already compiled by build.sh)
link:
	$(CC) -o binbuild/bwccx64 binbuild/*.obj $(LIBS) $(LDFLAGS)
	chmod +x binbuild/bwccx64
	cp binbuild/bwccx64 $(OWROOT)/build/binbuild/bwccx64
	@echo "=== bwccx64 linked ==="

clean:
	rm -f binbuild/bwccx64 binbuild/asm*.obj binbuild/tbyte.obj
