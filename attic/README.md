# attic/ — removed x64 post-processor code

These files contain the post-processor heuristics that were used
in r0.6.0 to make the 386 CG output run on x64. They worked
(62/62 test battery) but were fragile — 17 separate hacks sharing
one linear scan loop, each with edge cases that interacted.

Replaced in r0.6.1 by MinGW-w64 CRT port + cleanup.

## Files
- x64obj_postprocessor.c — full x64obj.c with all 17 heuristics
- x86enc_skip.patch — G_UNKNOWN skip (restored to Zoiks)

## the crew 4free
