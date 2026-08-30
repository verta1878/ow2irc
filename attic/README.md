# attic/ — x64 post-processor snapshots

Full working copies of the x64 post-processor files.
These contain the 17 heuristics that make bwccx64 work
until the native x64 CG replaces them.

## Files
- x64obj_postprocessor.c — x64obj.c with REX pass, branch fixup,
  jump table rewrite, struct patterns, omap, is_branch
- x86enc_with_skip.c — x86enc.c with G_UNKNOWN skip

DO NOT strip these fixes from the live code until the
native x64 CG is wired in and passes bob's battery.

## the crew 4free
