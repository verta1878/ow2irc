;****************************************************************************
;***                                                                      ***
;*** WINGLUE.ASM - windows glue functions                                 ***
;***               This set of functions encompasses all possible types   ***
;***               of calls.  Each API call has a little                  ***
;***               stub which generates the appropriate call into these   ***
;***               functions.                                             ***
;***                                                                      ***
;*** By:  Craig Eisler                                                    ***
;***      December 1990-November 1992                                     ***
;*** By:  F.W.Crigger May 1993                                            ***
;***                                                                      ***
;****************************************************************************

.386p

extrn        __DLLPatch:far
extrn PASCAL AbortDoc:FAR ; t=0 i=0
extrn PASCAL AccessResource:FAR ; t=1 i=1
extrn PASCAL AddAtom:FAR ; t=2 i=2
extrn PASCAL AddFontResource:FAR ; t=2 i=3
extrn PASCAL AllocDStoCSAlias:FAR ; t=0 i=4
extrn PASCAL AllocResource:FAR ; t=3 i=5
extrn PASCAL AllocSelector:FAR ; t=0 i=6
extrn PASCAL AnsiLower:FAR ; t=2 i=7
extrn PASCAL AnsiLowerBuff:FAR ; t=4 i=8
extrn PASCAL __AnsiNext:FAR ; t=5 i=9
extrn PASCAL __AnsiPrev:FAR ; t=6 i=10
extrn PASCAL AnsiUpper:FAR ; t=2 i=11
extrn PASCAL AnsiUpperBuff:FAR ; t=4 i=12
extrn PASCAL AnyPopup:FAR ; t=7 i=13
extrn PASCAL __AppendMenu:FAR ; t=8 i=14
extrn PASCAL Arc:FAR ; t=9 i=15
extrn PASCAL ArrangeIconicWindows:FAR ; t=0 i=16
extrn PASCAL BeginDeferWindowPos:FAR ; t=0 i=17
extrn PASCAL BeginPaint:FAR ; t=10 i=18
extrn PASCAL BitBlt:FAR ; t=11 i=19
extrn PASCAL BringWindowToTop:FAR ; t=0 i=20
extrn PASCAL BuildCommDCB:FAR ; t=12 i=21
extrn PASCAL CallMsgFilter:FAR ; t=4 i=22
extrn PASCAL CallNextHookEx:FAR ; t=13 i=23
extrn PASCAL CallWindowProc:FAR ; t=14 i=24
extrn PASCAL Catch:FAR ; t=2 i=25
extrn PASCAL ChangeClipboardChain:FAR ; t=1 i=26
extrn PASCAL ChangeMenu:FAR ; t=15 i=27
extrn PASCAL CheckMenuItem:FAR ; t=16 i=28
extrn PASCAL ChildWindowFromPoint:FAR ; t=17 i=29
extrn PASCAL Chord:FAR ; t=9 i=30
extrn PASCAL ClearCommBreak:FAR ; t=0 i=31
extrn PASCAL CloseClipboard:FAR ; t=7 i=32
extrn PASCAL CloseComm:FAR ; t=0 i=33
extrn PASCAL CloseDriver:FAR ; t=18 i=34
extrn PASCAL CloseMetaFile:FAR ; t=0 i=35
extrn PASCAL CombineRgn:FAR ; t=19 i=36
extrn PASCAL ConvertOutlineFontFile:FAR ; t=20 i=37
extrn PASCAL CopyCursor:FAR ; t=1 i=38
extrn PASCAL CopyIcon:FAR ; t=1 i=39
extrn PASCAL CopyMetaFile:FAR ; t=10 i=40
extrn PASCAL CountClipboardFormats:FAR ; t=7 i=41
extrn PASCAL CountVoiceNotes:FAR ; t=0 i=42
extrn PASCAL __CreateBitmap:FAR ; t=21 i=43
extrn PASCAL __CreateBitmapIndirect:FAR ; t=2 i=44
extrn PASCAL CreateBrushIndirect:FAR ; t=2 i=45
extrn PASCAL CreateCompatibleBitmap:FAR ; t=16 i=46
extrn PASCAL CreateCompatibleDC:FAR ; t=0 i=47
extrn PASCAL CreateCursor:FAR ; t=22 i=48
extrn PASCAL CreateDC:FAR ; t=23 i=49
extrn PASCAL CreateDialog:FAR ; t=24 i=50
extrn PASCAL CreateDialogIndirect:FAR ; t=24 i=51
extrn PASCAL CreateDialogIndirectParam:FAR ; t=25 i=52
extrn PASCAL CreateDialogParam:FAR ; t=25 i=53
extrn PASCAL __CreateDIBitmap:FAR ; t=26 i=54
extrn PASCAL CreateDIBPatternBrush:FAR ; t=1 i=55
extrn PASCAL CreateDiscardableBitmap:FAR ; t=16 i=56
extrn PASCAL CreateEllipticRgn:FAR ; t=19 i=57
extrn PASCAL CreateEllipticRgnIndirect:FAR ; t=2 i=58
extrn PASCAL CreateFont:FAR ; t=27 i=59
extrn PASCAL CreateFontIndirect:FAR ; t=2 i=60
extrn PASCAL CreateHatchBrush:FAR ; t=17 i=61
extrn PASCAL CreateIC:FAR ; t=23 i=62
extrn PASCAL CreateIcon:FAR ; t=22 i=63
extrn PASCAL CreateMenu:FAR ; t=7 i=64
extrn PASCAL CreateMetaFile:FAR ; t=2 i=65
extrn PASCAL CreatePalette:FAR ; t=2 i=66
extrn PASCAL CreatePatternBrush:FAR ; t=0 i=67
extrn PASCAL CreatePen:FAR ; t=3 i=68
extrn PASCAL CreatePenIndirect:FAR ; t=2 i=69
extrn PASCAL CreatePolygonRgn:FAR ; t=28 i=70
extrn PASCAL CreatePolyPolygonRgn:FAR ; t=29 i=71
extrn PASCAL CreatePopupMenu:FAR ; t=7 i=72
extrn PASCAL CreateRectRgn:FAR ; t=19 i=73
extrn PASCAL CreateRectRgnIndirect:FAR ; t=2 i=74
extrn PASCAL CreateRoundRectRgn:FAR ; t=30 i=75
extrn PASCAL CreateScalableFontResource:FAR ; t=31 i=76
extrn PASCAL CreateSolidBrush:FAR ; t=5 i=77
extrn PASCAL CreateWindow:FAR ; t=32 i=78
extrn PASCAL CreateWindowEx:FAR ; t=33 i=79
extrn PASCAL DefDlgProc:FAR ; t=8 i=80
extrn PASCAL DefDriverProc:FAR ; t=34 i=81
extrn PASCAL DeferWindowPos:FAR ; t=35 i=82
extrn PASCAL DefFrameProc:FAR ; t=21 i=83
extrn PASCAL DefHookProc:FAR ; t=36 i=84
extrn PASCAL DefMDIChildProc:FAR ; t=8 i=85
extrn PASCAL DefWindowProc:FAR ; t=8 i=86
extrn PASCAL DeleteAtom:FAR ; t=0 i=87
extrn PASCAL DeleteDC:FAR ; t=0 i=88
extrn PASCAL DeleteMenu:FAR ; t=16 i=89
extrn PASCAL DeleteMetaFile:FAR ; t=0 i=90
extrn PASCAL DeleteObject:FAR ; t=0 i=91
extrn PASCAL DestroyCursor:FAR ; t=0 i=92
extrn PASCAL DestroyIcon:FAR ; t=0 i=93
extrn PASCAL DestroyMenu:FAR ; t=0 i=94
extrn PASCAL DestroyWindow:FAR ; t=0 i=95
extrn PASCAL DialogBox:FAR ; t=24 i=96
extrn PASCAL DialogBoxIndirect:FAR ; t=8 i=97
extrn PASCAL DialogBoxIndirectParam:FAR ; t=37 i=98
extrn PASCAL DialogBoxParam:FAR ; t=25 i=99
extrn PASCAL DispatchMessage:FAR ; t=2 i=100
extrn PASCAL DlgDirList:FAR ; t=38 i=101
extrn PASCAL DlgDirListComboBox:FAR ; t=38 i=102
extrn PASCAL DlgDirSelect:FAR ; t=39 i=103
extrn PASCAL DlgDirSelectComboBox:FAR ; t=39 i=104
extrn PASCAL DlgDirSelectComboBoxEx:FAR ; t=40 i=105
extrn PASCAL DlgDirSelectEx:FAR ; t=40 i=106
extrn PASCAL DPtoLP:FAR ; t=39 i=107
extrn PASCAL DrawIcon:FAR ; t=19 i=108
extrn PASCAL DrawText:FAR ; t=41 i=109
extrn PASCAL Ellipse:FAR ; t=42 i=110
extrn PASCAL EmptyClipboard:FAR ; t=7 i=111
extrn PASCAL EnableCommNotification:FAR ; t=19 i=112
extrn PASCAL EnableHardwareInput:FAR ; t=0 i=113
extrn PASCAL EnableMenuItem:FAR ; t=16 i=114
extrn PASCAL EnableScrollBar:FAR ; t=16 i=115
extrn PASCAL EnableWindow:FAR ; t=1 i=116
extrn PASCAL EndDeferWindowPos:FAR ; t=0 i=117
extrn PASCAL EndDoc:FAR ; t=0 i=118
extrn PASCAL EndPage:FAR ; t=0 i=119
extrn PASCAL EngineMakeFontDir:FAR ; t=43 i=120
extrn PASCAL EnumChildWindows:FAR ; t=18 i=121
extrn PASCAL EnumClipboardFormats:FAR ; t=0 i=122
extrn PASCAL EnumFontFamilies:FAR ; t=44 i=123
extrn PASCAL EnumFonts:FAR ; t=44 i=124
extrn PASCAL EnumMetaFile:FAR ; t=45 i=125
extrn PASCAL EnumObjects:FAR ; t=45 i=126
extrn PASCAL EnumProps:FAR ; t=17 i=127
extrn PASCAL EnumTaskWindows:FAR ; t=18 i=128
extrn PASCAL EnumWindows:FAR ; t=6 i=129
extrn PASCAL EqualRect:FAR ; t=12 i=130
extrn PASCAL EqualRgn:FAR ; t=1 i=131
extrn PASCAL __Escape:FAR ; t=46 i=132
extrn PASCAL EscapeCommFunction:FAR ; t=1 i=133
extrn PASCAL ExcludeClipRect:FAR ; t=42 i=134
extrn PASCAL ExcludeUpdateRgn:FAR ; t=1 i=135
extrn PASCAL ExitWindows:FAR ; t=47 i=136
extrn PASCAL ExitWindowsExec:FAR ; t=12 i=137
extrn PASCAL ExtFloodFill:FAR ; t=48 i=138
extrn PASCAL ExtTextOut:FAR ; t=49 i=139
extrn PASCAL FillRect:FAR ; t=39 i=140
extrn PASCAL FillRgn:FAR ; t=16 i=141
extrn PASCAL FindAtom:FAR ; t=2 i=142
extrn PASCAL FindResource:FAR ; t=43 i=143
extrn PASCAL FindWindow:FAR ; t=12 i=144
extrn PASCAL FlashWindow:FAR ; t=1 i=145
extrn PASCAL FloodFill:FAR ; t=8 i=146
extrn PASCAL FlushComm:FAR ; t=1 i=147
extrn PASCAL FrameRect:FAR ; t=39 i=148
extrn PASCAL FrameRgn:FAR ; t=42 i=149
extrn PASCAL FreeModule:FAR ; t=0 i=150
extrn PASCAL FreeResource:FAR ; t=0 i=151
extrn PASCAL FreeSelector:FAR ; t=0 i=152
extrn PASCAL GetActiveWindow:FAR ; t=7 i=153
extrn PASCAL GetAspectRatioFilter:FAR ; t=0 i=154
extrn PASCAL GetAspectRatioFilterEx:FAR ; t=10 i=155
extrn PASCAL GetAsyncKeyState:FAR ; t=0 i=156
extrn PASCAL GetAtomHandle:FAR ; t=0 i=157
extrn PASCAL GetAtomName:FAR ; t=39 i=158
extrn PASCAL __GetBitmapBits:FAR ; t=18 i=159
extrn PASCAL GetBitmapDimension:FAR ; t=0 i=160
extrn PASCAL GetBitmapDimensionEx:FAR ; t=10 i=161
extrn PASCAL GetBkColor:FAR ; t=0 i=162
extrn PASCAL GetBkMode:FAR ; t=0 i=163
extrn PASCAL GetBoundsRect:FAR ; t=39 i=164
extrn PASCAL GetBrushOrg:FAR ; t=0 i=165
extrn PASCAL GetBrushOrgEx:FAR ; t=10 i=166
extrn PASCAL GetCapture:FAR ; t=7 i=167
extrn PASCAL GetCaretBlinkTime:FAR ; t=7 i=168
extrn PASCAL GetCharABCWidths:FAR ; t=50 i=169
extrn PASCAL GetCharWidth:FAR ; t=50 i=170
extrn PASCAL GetClassInfo:FAR ; t=43 i=171
extrn PASCAL GetClassLong:FAR ; t=1 i=172
extrn PASCAL GetClassName:FAR ; t=39 i=173
extrn PASCAL GetClassWord:FAR ; t=1 i=174
extrn PASCAL GetClipboardData:FAR ; t=0 i=175
extrn PASCAL GetClipboardFormatName:FAR ; t=39 i=176
extrn PASCAL GetClipboardOwner:FAR ; t=7 i=177
extrn PASCAL GetClipboardViewer:FAR ; t=7 i=178
extrn PASCAL GetClipBox:FAR ; t=10 i=179
extrn PASCAL GetCodeHandle:FAR ; t=5 i=180
extrn PASCAL GetCommError:FAR ; t=10 i=181
extrn PASCAL GetCommEventMask:FAR ; t=1 i=182
extrn PASCAL GetCommState:FAR ; t=10 i=183
extrn PASCAL GetCurrentPDB:FAR ; t=7 i=184
extrn PASCAL GetCurrentPosition:FAR ; t=0 i=185
extrn PASCAL GetCurrentPositionEx:FAR ; t=10 i=186
extrn PASCAL GetCurrentTask:FAR ; t=7 i=187
extrn PASCAL GetCurrentTime:FAR ; t=7 i=188
extrn PASCAL GetCursor:FAR ; t=7 i=189
extrn PASCAL GetDC:FAR ; t=0 i=190
extrn PASCAL GetDCEx:FAR ; t=3 i=191
extrn PASCAL GetDCOrg:FAR ; t=0 i=192
extrn PASCAL GetDesktopWindow:FAR ; t=7 i=193
extrn PASCAL GetDeviceCaps:FAR ; t=1 i=194
extrn PASCAL GetDialogBaseUnits:FAR ; t=7 i=195
extrn PASCAL __GetDIBits:FAR ; t=51 i=196
extrn PASCAL GetDlgCtrlID:FAR ; t=0 i=197
extrn PASCAL GetDlgItem:FAR ; t=1 i=198
extrn PASCAL GetDlgItemInt:FAR ; t=52 i=199
extrn PASCAL GetDlgItemText:FAR ; t=52 i=200
extrn PASCAL GetDOSEnvironment:FAR ; t=7 i=201
extrn PASCAL GetDoubleClickTime:FAR ; t=7 i=202
extrn PASCAL GetDriverInfo:FAR ; t=10 i=203
extrn PASCAL GetDriverModuleHandle:FAR ; t=0 i=204
extrn PASCAL GetDriveType:FAR ; t=0 i=205
extrn PASCAL GetEnvironment:FAR ; t=53 i=206
extrn PASCAL GetFocus:FAR ; t=7 i=207
extrn PASCAL GetFontData:FAR ; t=54 i=208
extrn PASCAL GetFreeSpace:FAR ; t=0 i=209
extrn PASCAL GetFreeSystemResources:FAR ; t=0 i=210
extrn PASCAL GetGlyphOutline:FAR ; t=55 i=211
extrn PASCAL GetInputState:FAR ; t=7 i=212
extrn PASCAL __GetInstanceData:FAR ; t=56 i=213
extrn PASCAL GetKBCodePage:FAR ; t=7 i=214
extrn PASCAL GetKeyboardType:FAR ; t=0 i=215
extrn PASCAL GetKeyNameText:FAR ; t=57 i=216
extrn PASCAL GetKeyState:FAR ; t=0 i=217
extrn PASCAL GetLastActivePopup:FAR ; t=0 i=218
extrn PASCAL GetMapMode:FAR ; t=0 i=219
extrn PASCAL GetMenu:FAR ; t=0 i=220
extrn PASCAL GetMenuCheckMarkDimensions:FAR ; t=7 i=221
extrn PASCAL GetMenuItemCount:FAR ; t=0 i=222
extrn PASCAL GetMenuItemID:FAR ; t=1 i=223
extrn PASCAL GetMenuState:FAR ; t=16 i=224
extrn PASCAL GetMenuString:FAR ; t=15 i=225
extrn PASCAL __GetMessage:FAR ; t=58 i=226
extrn PASCAL GetMessageExtraInfo:FAR ; t=7 i=227
extrn PASCAL GetMessagePos:FAR ; t=7 i=228
extrn PASCAL GetMessageTime:FAR ; t=7 i=229
extrn PASCAL GetMetaFile:FAR ; t=2 i=230
extrn PASCAL GetMetaFileBits:FAR ; t=0 i=231
extrn PASCAL GetModuleFileName:FAR ; t=39 i=232
extrn PASCAL GetModuleHandle:FAR ; t=2 i=233
extrn PASCAL GetModuleUsage:FAR ; t=0 i=234
extrn PASCAL GetNearestColor:FAR ; t=17 i=235
extrn PASCAL GetNearestPaletteIndex:FAR ; t=17 i=236
extrn PASCAL GetNextDlgGroupItem:FAR ; t=16 i=237
extrn PASCAL GetNextDlgTabItem:FAR ; t=16 i=238
extrn PASCAL GetNextDriver:FAR ; t=17 i=239
extrn PASCAL GetNextWindow:FAR ; t=1 i=240
extrn PASCAL GetNumTasks:FAR ; t=7 i=241
extrn PASCAL GetObject:FAR ; t=59 i=242
extrn PASCAL GetOpenClipboardWindow:FAR ; t=7 i=243
extrn PASCAL GetOutlineTextMetrics:FAR ; t=59 i=244
extrn PASCAL GetPaletteEntries:FAR ; t=50 i=245
extrn PASCAL GetParent:FAR ; t=0 i=246
extrn PASCAL GetPixel:FAR ; t=16 i=247
extrn PASCAL GetPolyFillMode:FAR ; t=0 i=248
extrn PASCAL GetPriorityClipboardFormat:FAR ; t=4 i=249
extrn PASCAL GetPrivateProfileInt:FAR ; t=60 i=250
extrn PASCAL GetPrivateProfileString:FAR ; t=61 i=251
extrn PASCAL GetProcAddress:FAR ; t=10 i=252
extrn PASCAL GetProfileInt:FAR ; t=53 i=253
extrn PASCAL GetProfileString:FAR ; t=62 i=254
extrn PASCAL GetProp:FAR ; t=10 i=255
extrn PASCAL GetQueueStatus:FAR ; t=0 i=256
extrn PASCAL GetRasterizerCaps:FAR ; t=4 i=257
extrn PASCAL GetRgnBox:FAR ; t=10 i=258
extrn PASCAL GetROP2:FAR ; t=0 i=259
extrn PASCAL GetScrollPos:FAR ; t=1 i=260
extrn PASCAL GetSelectorBase:FAR ; t=0 i=261
extrn PASCAL GetSelectorLimit:FAR ; t=0 i=262
extrn PASCAL GetStockObject:FAR ; t=0 i=263
extrn PASCAL GetStretchBltMode:FAR ; t=0 i=264
extrn PASCAL GetSubMenu:FAR ; t=1 i=265
extrn PASCAL GetSysColor:FAR ; t=0 i=266
extrn PASCAL GetSysModalWindow:FAR ; t=7 i=267
extrn PASCAL GetSystemDebugState:FAR ; t=7 i=268
extrn PASCAL GetSystemDirectory:FAR ; t=4 i=269
extrn PASCAL GetSystemMenu:FAR ; t=1 i=270
extrn PASCAL GetSystemMetrics:FAR ; t=0 i=271
extrn PASCAL GetSystemPaletteEntries:FAR ; t=50 i=272
extrn PASCAL GetSystemPaletteUse:FAR ; t=0 i=273
extrn PASCAL GetTabbedTextExtent:FAR ; t=63 i=274
extrn PASCAL GetTempDrive:FAR ; t=0 i=275
extrn PASCAL GetTempFileName:FAR ; t=64 i=276
extrn PASCAL GetTextAlign:FAR ; t=0 i=277
extrn PASCAL GetTextCharacterExtra:FAR ; t=0 i=278
extrn PASCAL GetTextColor:FAR ; t=0 i=279
extrn PASCAL GetTextExtent:FAR ; t=39 i=280
extrn PASCAL GetTextExtentPoint:FAR ; t=64 i=281
extrn PASCAL GetTextFace:FAR ; t=59 i=282
extrn PASCAL GetTextMetrics:FAR ; t=10 i=283
extrn PASCAL GetThresholdEvent:FAR ; t=7 i=284
extrn PASCAL GetThresholdStatus:FAR ; t=7 i=285
extrn PASCAL GetTickCount:FAR ; t=7 i=286
extrn PASCAL GetTimerResolution:FAR ; t=7 i=287
extrn PASCAL GetTopWindow:FAR ; t=0 i=288
extrn PASCAL GetUpdateRect:FAR ; t=39 i=289
extrn PASCAL GetUpdateRgn:FAR ; t=16 i=290
extrn PASCAL GetVersion:FAR ; t=7 i=291
extrn PASCAL GetViewportExt:FAR ; t=0 i=292
extrn PASCAL GetViewportExtEx:FAR ; t=10 i=293
extrn PASCAL GetViewportOrg:FAR ; t=0 i=294
extrn PASCAL GetViewportOrgEx:FAR ; t=10 i=295
extrn PASCAL GetWindow:FAR ; t=1 i=296
extrn PASCAL GetWindowDC:FAR ; t=0 i=297
extrn PASCAL GetWindowExt:FAR ; t=0 i=298
extrn PASCAL GetWindowExtEx:FAR ; t=10 i=299
extrn PASCAL GetWindowLong:FAR ; t=1 i=300
extrn PASCAL GetWindowOrg:FAR ; t=0 i=301
extrn PASCAL GetWindowOrgEx:FAR ; t=10 i=302
extrn PASCAL GetWindowPlacement:FAR ; t=10 i=303
extrn PASCAL GetWindowsDirectory:FAR ; t=4 i=304
extrn PASCAL GetWindowTask:FAR ; t=0 i=305
extrn PASCAL GetWindowText:FAR ; t=39 i=306
extrn PASCAL GetWindowTextLength:FAR ; t=0 i=307
extrn PASCAL GetWindowWord:FAR ; t=1 i=308
extrn PASCAL GetWinFlags:FAR ; t=7 i=309
extrn PASCAL GlobalAddAtom:FAR ; t=2 i=310
extrn PASCAL GlobalAlloc:FAR ; t=17 i=311
extrn PASCAL GlobalCompact:FAR ; t=5 i=312
extrn PASCAL GlobalDeleteAtom:FAR ; t=0 i=313
extrn PASCAL GlobalDosAlloc:FAR ; t=5 i=314
extrn PASCAL GlobalDosFree:FAR ; t=0 i=315
extrn PASCAL GlobalFindAtom:FAR ; t=2 i=316
extrn PASCAL GlobalFlags:FAR ; t=0 i=317
extrn PASCAL GlobalFree:FAR ; t=0 i=318
extrn PASCAL GlobalGetAtomName:FAR ; t=39 i=319
extrn PASCAL GlobalHandle:FAR ; t=0 i=320
extrn PASCAL GlobalLock:FAR ; t=0 i=321
extrn PASCAL GlobalLRUNewest:FAR ; t=0 i=322
extrn PASCAL GlobalLRUOldest:FAR ; t=0 i=323
extrn PASCAL GlobalPageLock:FAR ; t=0 i=324
extrn PASCAL GlobalPageUnlock:FAR ; t=0 i=325
extrn PASCAL GlobalReAlloc:FAR ; t=56 i=326
extrn PASCAL GlobalSize:FAR ; t=0 i=327
extrn PASCAL GlobalUnfix:FAR ; t=0 i=328
extrn PASCAL GlobalUnlock:FAR ; t=0 i=329
extrn PASCAL GlobalUnWire:FAR ; t=0 i=330
extrn PASCAL GlobalWire:FAR ; t=0 i=331
extrn PASCAL GrayString:FAR ; t=65 i=332
extrn PASCAL HiliteMenuItem:FAR ; t=19 i=333
extrn PASCAL InitAtomTable:FAR ; t=0 i=334
extrn PASCAL InSendMessage:FAR ; t=7 i=335
extrn PASCAL __InsertMenu:FAR ; t=21 i=336
extrn PASCAL IntersectClipRect:FAR ; t=42 i=337
extrn PASCAL IntersectRect:FAR ; t=20 i=338
extrn PASCAL InvertRgn:FAR ; t=1 i=339
extrn PASCAL IsBadCodePtr:FAR ; t=5 i=340
extrn PASCAL IsBadHugeReadPtr:FAR ; t=6 i=341
extrn PASCAL IsBadHugeWritePtr:FAR ; t=6 i=342
extrn PASCAL IsBadReadPtr:FAR ; t=47 i=343
extrn PASCAL IsBadStringPtr:FAR ; t=4 i=344
extrn PASCAL IsBadWritePtr:FAR ; t=47 i=345
extrn PASCAL IsCharAlpha:FAR ; t=0 i=346
extrn PASCAL IsCharAlphaNumeric:FAR ; t=0 i=347
extrn PASCAL IsCharLower:FAR ; t=0 i=348
extrn PASCAL IsCharUpper:FAR ; t=0 i=349
extrn PASCAL IsChild:FAR ; t=1 i=350
extrn PASCAL IsClipboardFormatAvailable:FAR ; t=0 i=351
extrn PASCAL IsDBCSLeadByte:FAR ; t=0 i=352
extrn PASCAL IsDialogMessage:FAR ; t=10 i=353
extrn PASCAL IsDlgButtonChecked:FAR ; t=1 i=354
extrn PASCAL IsGDIObject:FAR ; t=0 i=355
extrn PASCAL IsIconic:FAR ; t=0 i=356
extrn PASCAL IsMenu:FAR ; t=0 i=357
extrn PASCAL IsRectEmpty:FAR ; t=2 i=358
extrn PASCAL IsTask:FAR ; t=0 i=359
extrn PASCAL IsWindow:FAR ; t=0 i=360
extrn PASCAL IsWindowEnabled:FAR ; t=0 i=361
extrn PASCAL IsWindowVisible:FAR ; t=0 i=362
extrn PASCAL IsZoomed:FAR ; t=0 i=363
extrn PASCAL KillTimer:FAR ; t=1 i=364
extrn PASCAL LineTo:FAR ; t=16 i=365
extrn PASCAL LoadAccelerators:FAR ; t=10 i=366
extrn PASCAL LoadBitmap:FAR ; t=10 i=367
extrn PASCAL LoadCursor:FAR ; t=10 i=368
extrn PASCAL LoadIcon:FAR ; t=10 i=369
extrn PASCAL LoadLibrary:FAR ; t=2 i=370
extrn PASCAL LoadMenu:FAR ; t=10 i=371
extrn PASCAL LoadMenuIndirect:FAR ; t=2 i=372
extrn PASCAL LoadModule:FAR ; t=12 i=373
extrn PASCAL LoadResource:FAR ; t=1 i=374
extrn PASCAL LoadString:FAR ; t=52 i=375
extrn PASCAL LocalAlloc:FAR ; t=1 i=376
extrn PASCAL LocalCompact:FAR ; t=0 i=377
extrn PASCAL LocalFlags:FAR ; t=0 i=378
extrn PASCAL LocalFree:FAR ; t=0 i=379
extrn PASCAL LocalHandle:FAR ; t=0 i=380
extrn PASCAL LocalInit:FAR ; t=16 i=381
extrn PASCAL LocalLock:FAR ; t=0 i=382
extrn PASCAL LocalReAlloc:FAR ; t=16 i=383
extrn PASCAL LocalShrink:FAR ; t=1 i=384
extrn PASCAL LocalSize:FAR ; t=0 i=385
extrn PASCAL LocalUnlock:FAR ; t=0 i=386
extrn PASCAL LockInput:FAR ; t=16 i=387
extrn PASCAL LockResource:FAR ; t=0 i=388
extrn PASCAL LockSegment:FAR ; t=0 i=389
extrn PASCAL LockWindowUpdate:FAR ; t=0 i=390
extrn PASCAL LPtoDP:FAR ; t=39 i=391
extrn PASCAL lstrcat:FAR ; t=12 i=392
extrn PASCAL lstrcmp:FAR ; t=12 i=393
extrn PASCAL lstrcmpi:FAR ; t=12 i=394
extrn PASCAL lstrcpy:FAR ; t=12 i=395
extrn PASCAL lstrlen:FAR ; t=2 i=396
extrn PASCAL MakeProcInstance:FAR ; t=47 i=397
extrn PASCAL MapVirtualKey:FAR ; t=1 i=398
extrn PASCAL MessageBox:FAR ; t=66 i=399
extrn PASCAL __ModifyMenu:FAR ; t=21 i=400
extrn PASCAL MoveTo:FAR ; t=16 i=401
extrn PASCAL MoveToEx:FAR ; t=50 i=402
extrn PASCAL MoveWindow:FAR ; t=30 i=403
extrn PASCAL MulDiv:FAR ; t=16 i=404
extrn PASCAL OemKeyScan:FAR ; t=0 i=405
extrn PASCAL OffsetClipRgn:FAR ; t=16 i=406
extrn PASCAL OffsetRgn:FAR ; t=16 i=407
extrn PASCAL OffsetViewportOrg:FAR ; t=16 i=408
extrn PASCAL OffsetViewportOrgEx:FAR ; t=50 i=409
extrn PASCAL OffsetWindowOrg:FAR ; t=16 i=410
extrn PASCAL OffsetWindowOrgEx:FAR ; t=50 i=411
extrn PASCAL OpenClipboard:FAR ; t=0 i=412
extrn PASCAL OpenComm:FAR ; t=28 i=413
extrn PASCAL OpenDriver:FAR ; t=67 i=414
extrn PASCAL OpenFile:FAR ; t=53 i=415
extrn PASCAL OpenIcon:FAR ; t=0 i=416
extrn PASCAL OpenSound:FAR ; t=7 i=417
extrn PASCAL PaintRgn:FAR ; t=1 i=418
extrn PASCAL PatBlt:FAR ; t=68 i=419
extrn PASCAL __PeekMessage:FAR ; t=69 i=420
extrn PASCAL Pie:FAR ; t=9 i=421
extrn PASCAL PlayMetaFile:FAR ; t=1 i=422
extrn PASCAL Polygon:FAR ; t=39 i=423
extrn PASCAL Polyline:FAR ; t=39 i=424
extrn PASCAL PolyPolygon:FAR ; t=66 i=425
extrn PASCAL PostAppMessage:FAR ; t=8 i=426
extrn PASCAL PostMessage:FAR ; t=8 i=427
extrn PASCAL ProfInsChk:FAR ; t=7 i=428
extrn PASCAL PtInRect:FAR ; t=70 i=429
extrn PASCAL PtInRegion:FAR ; t=16 i=430
extrn PASCAL PtVisible:FAR ; t=16 i=431
extrn PASCAL QueryAbort:FAR ; t=1 i=432
extrn PASCAL QueryJob:FAR ; t=1 i=433
extrn PASCAL QuerySendMessage:FAR ; t=50 i=434
extrn PASCAL ReadComm:FAR ; t=39 i=435
extrn PASCAL RealizePalette:FAR ; t=0 i=436
extrn PASCAL Rectangle:FAR ; t=42 i=437
extrn PASCAL RectInRegion:FAR ; t=10 i=438
extrn PASCAL RectVisible:FAR ; t=10 i=439
extrn PASCAL RedrawWindow:FAR ; t=40 i=440
extrn PASCAL RegisterClass:FAR ; t=2 i=441
extrn PASCAL RegisterClipboardFormat:FAR ; t=2 i=442
extrn PASCAL RegisterWindowMessage:FAR ; t=2 i=443
extrn PASCAL ReleaseDC:FAR ; t=1 i=444
extrn PASCAL RemoveFontResource:FAR ; t=2 i=445
extrn PASCAL RemoveMenu:FAR ; t=16 i=446
extrn PASCAL RemoveProp:FAR ; t=10 i=447
extrn PASCAL ResizePalette:FAR ; t=1 i=448
extrn PASCAL RestoreDC:FAR ; t=1 i=449
extrn PASCAL RoundRect:FAR ; t=71 i=450
extrn PASCAL SaveDC:FAR ; t=0 i=451
extrn PASCAL ScaleViewportExt:FAR ; t=42 i=452
extrn PASCAL ScaleViewportExtEx:FAR ; t=72 i=453
extrn PASCAL ScaleWindowExt:FAR ; t=42 i=454
extrn PASCAL ScaleWindowExtEx:FAR ; t=72 i=455
extrn PASCAL ScrollDC:FAR ; t=73 i=456
extrn PASCAL ScrollWindowEx:FAR ; t=74 i=457
extrn PASCAL SelectClipRgn:FAR ; t=1 i=458
extrn PASCAL SelectObject:FAR ; t=1 i=459
extrn PASCAL SelectPalette:FAR ; t=16 i=460
extrn PASCAL SendDlgItemMessage:FAR ; t=21 i=461
extrn PASCAL SendDriverMessage:FAR ; t=45 i=462
extrn PASCAL SendMessage:FAR ; t=8 i=463
extrn PASCAL SetAbortProc:FAR ; t=17 i=464
extrn PASCAL SetActiveWindow:FAR ; t=0 i=465
extrn PASCAL __SetBitmapBits:FAR ; t=18 i=466
extrn PASCAL SetBitmapDimension:FAR ; t=16 i=467
extrn PASCAL SetBitmapDimensionEx:FAR ; t=50 i=468
extrn PASCAL SetBkColor:FAR ; t=17 i=469
extrn PASCAL SetBkMode:FAR ; t=1 i=470
extrn PASCAL SetBoundsRect:FAR ; t=39 i=471
extrn PASCAL SetBrushOrg:FAR ; t=16 i=472
extrn PASCAL SetCapture:FAR ; t=0 i=473
extrn PASCAL SetClassLong:FAR ; t=3 i=474
extrn PASCAL SetClassWord:FAR ; t=16 i=475
extrn PASCAL SetClipboardData:FAR ; t=1 i=476
extrn PASCAL SetClipboardViewer:FAR ; t=0 i=477
extrn PASCAL SetCommBreak:FAR ; t=0 i=478
extrn PASCAL SetCommEventMask:FAR ; t=1 i=479
extrn PASCAL SetCommState:FAR ; t=2 i=480
extrn PASCAL SetCursor:FAR ; t=0 i=481
extrn PASCAL __SetDIBits:FAR ; t=51 i=482
extrn PASCAL __SetDIBitsToDevice:FAR ; t=75 i=483
extrn PASCAL SetEnvironment:FAR ; t=53 i=484
extrn PASCAL SetErrorMode:FAR ; t=0 i=485
extrn PASCAL SetFocus:FAR ; t=0 i=486
extrn PASCAL SetHandleCount:FAR ; t=0 i=487
extrn PASCAL SetMapMode:FAR ; t=1 i=488
extrn PASCAL SetMapperFlags:FAR ; t=17 i=489
extrn PASCAL SetMenu:FAR ; t=1 i=490
extrn PASCAL SetMenuItemBitmaps:FAR ; t=42 i=491
extrn PASCAL SetMessageQueue:FAR ; t=0 i=492
extrn PASCAL SetMetaFileBits:FAR ; t=0 i=493
extrn PASCAL SetMetaFileBitsBetter:FAR ; t=0 i=494
extrn PASCAL SetPaletteEntries:FAR ; t=50 i=495
extrn PASCAL SetParent:FAR ; t=1 i=496
extrn PASCAL SetPixel:FAR ; t=8 i=497
extrn PASCAL SetPolyFillMode:FAR ; t=1 i=498
extrn PASCAL SetProp:FAR ; t=39 i=499
extrn PASCAL SetResourceHandler:FAR ; t=76 i=500
extrn PASCAL SetROP2:FAR ; t=1 i=501
extrn PASCAL SetScrollPos:FAR ; t=19 i=502
extrn PASCAL SetSelectorBase:FAR ; t=17 i=503
extrn PASCAL SetSelectorLimit:FAR ; t=17 i=504
extrn PASCAL SetSoundNoise:FAR ; t=1 i=505
extrn PASCAL SetStretchBltMode:FAR ; t=1 i=506
extrn PASCAL SetSwapAreaSize:FAR ; t=0 i=507
extrn PASCAL SetSysModalWindow:FAR ; t=0 i=508
extrn PASCAL SetSystemPaletteUse:FAR ; t=1 i=509
extrn PASCAL SetTextAlign:FAR ; t=1 i=510
extrn PASCAL SetTextCharacterExtra:FAR ; t=1 i=511
extrn PASCAL SetTextColor:FAR ; t=17 i=512
extrn PASCAL SetTextJustification:FAR ; t=16 i=513
extrn PASCAL SetTimer:FAR ; t=8 i=514
extrn PASCAL SetViewportExt:FAR ; t=16 i=515
extrn PASCAL SetViewportExtEx:FAR ; t=50 i=516
extrn PASCAL SetViewportOrg:FAR ; t=16 i=517
extrn PASCAL SetViewportOrgEx:FAR ; t=50 i=518
extrn PASCAL SetVoiceAccent:FAR ; t=42 i=519
extrn PASCAL SetVoiceEnvelope:FAR ; t=16 i=520
extrn PASCAL SetVoiceNote:FAR ; t=19 i=521
extrn PASCAL SetVoiceQueueSize:FAR ; t=1 i=522
extrn PASCAL SetVoiceSound:FAR ; t=56 i=523
extrn PASCAL SetVoiceThreshold:FAR ; t=1 i=524
extrn PASCAL SetWindowExt:FAR ; t=16 i=525
extrn PASCAL SetWindowExtEx:FAR ; t=50 i=526
extrn PASCAL SetWindowLong:FAR ; t=3 i=527
extrn PASCAL SetWindowOrg:FAR ; t=16 i=528
extrn PASCAL SetWindowOrgEx:FAR ; t=50 i=529
extrn PASCAL SetWindowPlacement:FAR ; t=10 i=530
extrn PASCAL SetWindowPos:FAR ; t=71 i=531
extrn PASCAL SetWindowsHook:FAR ; t=17 i=532
extrn PASCAL SetWindowsHookEx:FAR ; t=77 i=533
extrn PASCAL SetWindowWord:FAR ; t=16 i=534
extrn PASCAL ShowCursor:FAR ; t=0 i=535
extrn PASCAL ShowWindow:FAR ; t=1 i=536
extrn PASCAL SizeofResource:FAR ; t=1 i=537
extrn PASCAL SpoolFile:FAR ; t=23 i=538
extrn PASCAL __StartDoc:FAR ; t=10 i=539
extrn PASCAL StartPage:FAR ; t=0 i=540
extrn PASCAL StartSound:FAR ; t=7 i=541
extrn PASCAL StopSound:FAR ; t=7 i=542
extrn PASCAL StretchBlt:FAR ; t=78 i=543
extrn PASCAL __StretchDIBits:FAR ; t=79 i=544
extrn PASCAL SubtractRect:FAR ; t=20 i=545
extrn PASCAL SwapMouseButton:FAR ; t=0 i=546
extrn PASCAL SyncAllVoices:FAR ; t=7 i=547
extrn PASCAL SystemParametersInfo:FAR ; t=52 i=548
extrn PASCAL TabbedTextOut:FAR ; t=80 i=549
extrn PASCAL TextOut:FAR ; t=81 i=550
extrn PASCAL ToAscii:FAR ; t=82 i=551
extrn PASCAL TrackPopupMenu:FAR ; t=83 i=552
extrn PASCAL TranslateAccelerator:FAR ; t=59 i=553
extrn PASCAL TranslateMDISysAccel:FAR ; t=10 i=554
extrn PASCAL TranslateMessage:FAR ; t=2 i=555
extrn PASCAL TransmitCommChar:FAR ; t=1 i=556
extrn PASCAL UngetCommChar:FAR ; t=1 i=557
extrn PASCAL UnhookWindowsHook:FAR ; t=17 i=558
extrn PASCAL UnhookWindowsHookEx:FAR ; t=5 i=559
extrn PASCAL UnionRect:FAR ; t=20 i=560
extrn PASCAL UnlockSegment:FAR ; t=0 i=561
extrn PASCAL UnrealizeObject:FAR ; t=0 i=562
extrn PASCAL UnregisterClass:FAR ; t=4 i=563
extrn PASCAL UpdateColors:FAR ; t=0 i=564
extrn PASCAL VkKeyScan:FAR ; t=0 i=565
extrn PASCAL WaitSoundState:FAR ; t=0 i=566
extrn PASCAL WindowFromPoint:FAR ; t=5 i=567
extrn PASCAL WinExec:FAR ; t=4 i=568
extrn PASCAL __WinHelp:FAR ; t=24 i=569
extrn PASCAL WNetAddConnection:FAR ; t=20 i=570
extrn PASCAL WNetCancelConnection:FAR ; t=4 i=571
extrn PASCAL WNetGetConnection:FAR ; t=20 i=572
extrn PASCAL WriteComm:FAR ; t=39 i=573
extrn PASCAL WritePrivateProfileString:FAR ; t=23 i=574
extrn PASCAL WriteProfileString:FAR ; t=20 i=575
extrn PASCAL wvsprintf:FAR ; t=20 i=576
extrn PASCAL _lclose:FAR ; t=0 i=577
extrn PASCAL _lcreat:FAR ; t=4 i=578
extrn PASCAL _llseek:FAR ; t=56 i=579
extrn PASCAL _lopen:FAR ; t=4 i=580
extrn PASCAL _lread:FAR ; t=39 i=581
extrn PASCAL _lwrite:FAR ; t=39 i=582
extrn PASCAL GetKerningPairs:FAR ; t=59 i=583
;      PASCAL _16AddAtom ; t=5 i=584
;      PASCAL _16AddFontResource ; t=5 i=585
;      PASCAL _16AnsiLower ; t=5 i=586
;      PASCAL _16AnsiLowerBuff ; t=47 i=587
;      PASCAL _16AnsiUpper ; t=5 i=588
;      PASCAL _16AnsiUpperBuff ; t=47 i=589
;      PASCAL _16BeginPaint ; t=17 i=590
;      PASCAL _16BuildCommDCB ; t=6 i=591
;      PASCAL _16CallMsgFilter ; t=47 i=592
;      PASCAL _16Catch ; t=5 i=593
;      PASCAL _16ChangeMenu ; t=84 i=594
;      PASCAL _16ConvertOutlineFontFile ; t=85 i=595
;      PASCAL _16CopyMetaFile ; t=17 i=596
extrn PASCAL CreateBitmap:FAR ; t=21 i=597
extrn PASCAL CreateBitmapIndirect:FAR ; t=5 i=598
;      PASCAL _16CreateBrushIndirect ; t=5 i=599
;      PASCAL _16CreateCursor ; t=86 i=600
;      PASCAL _16CreateDC ; t=87 i=601
;      PASCAL _16CreateDialog ; t=88 i=602
;      PASCAL _16CreateDialogIndirect ; t=88 i=603
;      PASCAL _16CreateDialogIndirectParam ; t=89 i=604
;      PASCAL _16CreateDialogParam ; t=89 i=605
extrn PASCAL CreateDIBitmap:FAR ; t=90 i=606
;      PASCAL _16CreateEllipticRgnIndirect ; t=5 i=607
;      PASCAL _16CreateFont ; t=91 i=608
;      PASCAL _16CreateFontIndirect ; t=5 i=609
;      PASCAL _16CreateIC ; t=87 i=610
;      PASCAL _16CreateIcon ; t=86 i=611
;      PASCAL _16CreateMetaFile ; t=5 i=612
;      PASCAL _16CreatePalette ; t=5 i=613
;      PASCAL _16CreatePenIndirect ; t=5 i=614
;      PASCAL _16CreatePolygonRgn ; t=92 i=615
;      PASCAL _16CreatePolyPolygonRgn ; t=93 i=616
;      PASCAL _16CreateRectRgnIndirect ; t=5 i=617
;      PASCAL _16CreateScalableFontResource ; t=94 i=618
;      PASCAL _16CreateWindow ; t=95 i=619
;      PASCAL _16CreateWindowEx ; t=96 i=620
;      PASCAL _16DefHookProc ; t=45 i=621
;      PASCAL _16DialogBox ; t=88 i=622
;      PASCAL _16DialogBoxIndirect ; t=8 i=623
;      PASCAL _16DialogBoxIndirectParam ; t=37 i=624
;      PASCAL _16DialogBoxParam ; t=89 i=625
;      PASCAL _16DispatchMessage ; t=5 i=626
;      PASCAL _16DlgDirList ; t=97 i=627
;      PASCAL _16DlgDirListComboBox ; t=97 i=628
;      PASCAL _16DlgDirSelect ; t=56 i=629
;      PASCAL _16DlgDirSelectComboBox ; t=56 i=630
;      PASCAL _16DlgDirSelectComboBoxEx ; t=77 i=631
;      PASCAL _16DlgDirSelectEx ; t=77 i=632
;      PASCAL _16DPtoLP ; t=56 i=633
;      PASCAL _16DrawText ; t=98 i=634
;      PASCAL _16EngineMakeFontDir ; t=18 i=635
;      PASCAL _16EnumFontFamilies ; t=94 i=636
;      PASCAL _16EnumFonts ; t=94 i=637
;      PASCAL _16EnumObjects ; t=45 i=638
;      PASCAL _16EqualRect ; t=6 i=639
extrn PASCAL Escape:FAR ; t=37 i=640
;      PASCAL _16ExitWindowsExec ; t=6 i=641
;      PASCAL _16ExtTextOut ; t=99 i=642
;      PASCAL _16FillRect ; t=56 i=643
;      PASCAL _16FindAtom ; t=5 i=644
;      PASCAL _16FindResource ; t=18 i=645
;      PASCAL _16FindWindow ; t=6 i=646
;      PASCAL _16FrameRect ; t=56 i=647
;      PASCAL _16GetAspectRatioFilterEx ; t=17 i=648
;      PASCAL _16GetAtomName ; t=56 i=649
extrn PASCAL GetBitmapBits:FAR ; t=18 i=650
;      PASCAL _16GetBitmapDimensionEx ; t=17 i=651
;      PASCAL _16GetBoundsRect ; t=56 i=652
;      PASCAL _16GetBrushOrgEx ; t=17 i=653
;      PASCAL _16GetCharABCWidths ; t=8 i=654
;      PASCAL _16GetCharWidth ; t=8 i=655
;      PASCAL _16GetClassInfo ; t=18 i=656
;      PASCAL _16GetClassName ; t=56 i=657
;      PASCAL _16GetClipboardFormatName ; t=56 i=658
;      PASCAL _16GetClipBox ; t=17 i=659
;      PASCAL _16GetCommError ; t=17 i=660
;      PASCAL _16GetCommState ; t=17 i=661
;      PASCAL _16GetCurrentPositionEx ; t=17 i=662
extrn PASCAL GetDIBits:FAR ; t=100 i=663
;      PASCAL _16GetDlgItemInt ; t=101 i=664
;      PASCAL _16GetDlgItemText ; t=101 i=665
;      PASCAL _16GetDriverInfo ; t=17 i=666
;      PASCAL _16GetEnvironment ; t=102 i=667
;      PASCAL _16GetFontData ; t=103 i=668
;      PASCAL _16GetGlyphOutline ; t=104 i=669
;      PASCAL _16GetKeyNameText ; t=102 i=670
;      PASCAL _16GetMenuString ; t=84 i=671
extrn PASCAL GetMessage:FAR ; t=105 i=672
;      PASCAL _16GetMetaFile ; t=5 i=673
;      PASCAL _16GetModuleFileName ; t=56 i=674
;      PASCAL _16GetModuleHandle ; t=5 i=675
;      PASCAL _16GetObject ; t=3 i=676
;      PASCAL _16GetOutlineTextMetrics ; t=3 i=677
;      PASCAL _16GetPaletteEntries ; t=8 i=678
;      PASCAL _16GetPriorityClipboardFormat ; t=47 i=679
;      PASCAL _16GetPrivateProfileInt ; t=106 i=680
;      PASCAL _16GetPrivateProfileString ; t=107 i=681
;      PASCAL _16GetProcAddress ; t=17 i=682
;      PASCAL _16GetProfileInt ; t=102 i=683
;      PASCAL _16GetProfileString ; t=108 i=684
;      PASCAL _16GetProp ; t=17 i=685
;      PASCAL _16GetRasterizerCaps ; t=47 i=686
;      PASCAL _16GetRgnBox ; t=17 i=687
;      PASCAL _16GetSystemDirectory ; t=47 i=688
;      PASCAL _16GetSystemPaletteEntries ; t=8 i=689
;      PASCAL _16GetTabbedTextExtent ; t=109 i=690
;      PASCAL _16GetTempFileName ; t=88 i=691
;      PASCAL _16GetTextExtent ; t=56 i=692
;      PASCAL _16GetTextExtentPoint ; t=88 i=693
;      PASCAL _16GetTextFace ; t=3 i=694
;      PASCAL _16GetTextMetrics ; t=17 i=695
;      PASCAL _16GetUpdateRect ; t=56 i=696
;      PASCAL _16GetViewportExtEx ; t=17 i=697
;      PASCAL _16GetViewportOrgEx ; t=17 i=698
;      PASCAL _16GetWindowExtEx ; t=17 i=699
;      PASCAL _16GetWindowOrgEx ; t=17 i=700
;      PASCAL _16GetWindowPlacement ; t=17 i=701
;      PASCAL _16GetWindowsDirectory ; t=47 i=702
;      PASCAL _16GetWindowText ; t=56 i=703
;      PASCAL _16GlobalAddAtom ; t=5 i=704
;      PASCAL _16GlobalFindAtom ; t=5 i=705
;      PASCAL _16GlobalGetAtomName ; t=56 i=706
;      PASCAL _16EnumChildWindows ; t=18 i=707
;      PASCAL _16EnumMetaFile ; t=45 i=708
;      PASCAL _16EnumProps ; t=17 i=709
;      PASCAL _16EnumTaskWindows ; t=18 i=710
;      PASCAL _16EnumWindows ; t=6 i=711
;      PASCAL _16GrayString ; t=110 i=712
;      PASCAL _16SetAbortProc ; t=17 i=713
;      PASCAL _16SetTimer ; t=8 i=714
;      PASCAL _16UnhookWindowsHook ; t=17 i=715
;      PASCAL _16IntersectRect ; t=85 i=716
;      PASCAL _16IsDialogMessage ; t=17 i=717
;      PASCAL _16IsRectEmpty ; t=5 i=718
;      PASCAL _16LoadAccelerators ; t=17 i=719
;      PASCAL _16LoadBitmap ; t=17 i=720
;      PASCAL _16LoadCursor ; t=17 i=721
;      PASCAL _16LoadIcon ; t=17 i=722
;      PASCAL _16LoadLibrary ; t=5 i=723
;      PASCAL _16LoadMenu ; t=17 i=724
;      PASCAL _16LoadMenuIndirect ; t=5 i=725
;      PASCAL _16LoadModule ; t=6 i=726
;      PASCAL _16LoadString ; t=101 i=727
;      PASCAL _16MakeProcInstance ; t=47 i=728
;      PASCAL _16SetWindowsHook ; t=17 i=729
;      PASCAL _16SetWindowsHookEx ; t=77 i=730
;      PASCAL _16LPtoDP ; t=56 i=731
;      PASCAL _16lstrcat ; t=6 i=732
;      PASCAL _16lstrcmp ; t=6 i=733
;      PASCAL _16lstrcmpi ; t=6 i=734
;      PASCAL _16lstrcpy ; t=6 i=735
;      PASCAL _16lstrlen ; t=5 i=736
;      PASCAL _16MessageBox ; t=111 i=737
;      PASCAL _16MoveToEx ; t=8 i=738
;      PASCAL _16OffsetViewportOrgEx ; t=8 i=739
;      PASCAL _16OffsetWindowOrgEx ; t=8 i=740
;      PASCAL _16OpenComm ; t=92 i=741
;      PASCAL _16OpenDriver ; t=85 i=742
;      PASCAL _16OpenFile ; t=102 i=743
extrn PASCAL PeekMessage:FAR ; t=112 i=744
;      PASCAL _16Polygon ; t=56 i=745
;      PASCAL _16Polyline ; t=56 i=746
;      PASCAL _16PolyPolygon ; t=111 i=747
;      PASCAL _16PtInRect ; t=6 i=748
;      PASCAL _16QuerySendMessage ; t=8 i=749
;      PASCAL _16ReadComm ; t=56 i=750
;      PASCAL _16RectInRegion ; t=17 i=751
;      PASCAL _16RectVisible ; t=17 i=752
;      PASCAL _16RedrawWindow ; t=77 i=753
;      PASCAL _16RegisterClass ; t=5 i=754
;      PASCAL _16RegisterClipboardFormat ; t=5 i=755
;      PASCAL _16RegisterWindowMessage ; t=5 i=756
;      PASCAL _16RemoveFontResource ; t=5 i=757
;      PASCAL _16RemoveProp ; t=17 i=758
;      PASCAL _16ScaleViewportExtEx ; t=68 i=759
;      PASCAL _16ScaleWindowExtEx ; t=68 i=760
;      PASCAL _16ScrollDC ; t=113 i=761
;      PASCAL _16ScrollWindowEx ; t=114 i=762
extrn PASCAL SetBitmapBits:FAR ; t=18 i=763
;      PASCAL _16SetBitmapDimensionEx ; t=8 i=764
;      PASCAL _16SetBoundsRect ; t=56 i=765
;      PASCAL _16SetCommState ; t=5 i=766
extrn PASCAL SetDIBits:FAR ; t=100 i=767
extrn PASCAL SetDIBitsToDevice:FAR ; t=115 i=768
;      PASCAL _16SetEnvironment ; t=102 i=769
;      PASCAL _16SetPaletteEntries ; t=8 i=770
;      PASCAL _16SetProp ; t=56 i=771
;      PASCAL _16SetResourceHandler ; t=18 i=772
;      PASCAL _16SetViewportExtEx ; t=8 i=773
;      PASCAL _16SetViewportOrgEx ; t=8 i=774
;      PASCAL _16SetWindowExtEx ; t=8 i=775
;      PASCAL _16SetWindowOrgEx ; t=8 i=776
;      PASCAL _16SetWindowPlacement ; t=17 i=777
;      PASCAL _16SpoolFile ; t=87 i=778
extrn PASCAL StartDoc:FAR ; t=17 i=779
extrn PASCAL StretchDIBits:FAR ; t=116 i=780
;      PASCAL _16SubtractRect ; t=85 i=781
;      PASCAL _16SystemParametersInfo ; t=101 i=782
;      PASCAL _16TabbedTextOut ; t=117 i=783
;      PASCAL _16TextOut ; t=48 i=784
;      PASCAL _16ToAscii ; t=118 i=785
;      PASCAL _16TrackPopupMenu ; t=119 i=786
;      PASCAL _16TranslateAccelerator ; t=3 i=787
;      PASCAL _16TranslateMDISysAccel ; t=17 i=788
;      PASCAL _16TranslateMessage ; t=5 i=789
;      PASCAL _16UnionRect ; t=85 i=790
;      PASCAL _16UnregisterClass ; t=47 i=791
;      PASCAL _16WinExec ; t=47 i=792
extrn PASCAL WinHelp:FAR ; t=88 i=793
;      PASCAL _16WNetAddConnection ; t=85 i=794
;      PASCAL _16WNetCancelConnection ; t=47 i=795
;      PASCAL _16WNetGetConnection ; t=85 i=796
;      PASCAL _16WriteComm ; t=56 i=797
;      PASCAL _16WritePrivateProfileString ; t=87 i=798
;      PASCAL _16WriteProfileString ; t=85 i=799
;      PASCAL _16wvsprintf ; t=85 i=800
;      PASCAL _16_lcreat ; t=47 i=801
;      PASCAL _16_lopen ; t=47 i=802
;      PASCAL _16_lread ; t=56 i=803
;      PASCAL _16_lwrite ; t=56 i=804
;      PASCAL _16SendMessage ; t=8 i=805
;      PASCAL _16SetWindowLong ; t=3 i=806
;      PASCAL _16GetKerningPairs ; t=3 i=807
extrn PASCAL __WDPMIGetAlias:FAR ; t=120 i=808
extrn PASCAL __WDPMIGetHugeAlias:FAR ; t=121 i=809
extrn PASCAL __WDPMIAlloc:FAR ; t=5 i=810
extrn PASCAL __WDPMIFree:FAR ; t=5 i=811
extrn PASCAL __WDPMIAliasToFlat:FAR ; t=5 i=812
extrn PASCAL _clib_bios_disk:FAR ; t=10 i=813
extrn PASCAL _clib_bios_equiplist:FAR ; t=7 i=814
extrn PASCAL _clib_bios_keybrd:FAR ; t=0 i=815
extrn PASCAL _clib_bios_memsize:FAR ; t=7 i=816
extrn PASCAL _clib_bios_printer:FAR ; t=16 i=817
extrn PASCAL _clib_bios_serialcom:FAR ; t=16 i=818
extrn PASCAL _clib_bios_timeofday:FAR ; t=10 i=819
extrn PASCAL _clib_clock:FAR ; t=7 i=820
extrn PASCAL _clib_dos_findfirst:FAR ; t=122 i=821
extrn PASCAL _clib_dos_findnext:FAR ; t=2 i=822
extrn PASCAL _clib_errno:FAR ; t=7 i=823
extrn PASCAL _clib_int86:FAR ; t=43 i=824
extrn PASCAL _clib_int86x:FAR ; t=31 i=825
extrn PASCAL _clib_intdos:FAR ; t=12 i=826
extrn PASCAL _clib_intdosx:FAR ; t=20 i=827
;extrn PASCAL DdeAbandonTransaction:FAR ; t=85 (ddeml) i=828
;extrn PASCAL DdeAccessData:FAR ; t=120 (ddeml) i=829
;extrn PASCAL DdeAddData:FAR ; t=123 (ddeml) i=830
;extrn PASCAL DdeClientTransaction:FAR ; t=124 (ddeml) i=831
;extrn PASCAL DdeCmpStringHandles:FAR ; t=6 (ddeml) i=832
;extrn PASCAL DdeConnect:FAR ; t=125 (ddeml) i=833
;extrn PASCAL DdeConnectList:FAR ; t=126 (ddeml) i=834
;extrn PASCAL DdeCreateDataHandle:FAR ; t=127 (ddeml) i=835
;extrn PASCAL DdeCreateStringHandle:FAR ; t=57 (ddeml) i=836
;extrn PASCAL DdeDisconnect:FAR ; t=5 (ddeml) i=837
;extrn PASCAL DdeDisconnectList:FAR ; t=5 (ddeml) i=838
;extrn PASCAL DdeEnableCallback:FAR ; t=102 (ddeml) i=839
;extrn PASCAL DdeFreeDataHandle:FAR ; t=5 (ddeml) i=840
;extrn PASCAL DdeFreeStringHandle:FAR ; t=6 (ddeml) i=841
;extrn PASCAL DdeGetData:FAR ; t=123 (ddeml) i=842
;extrn PASCAL DdeGetLastError:FAR ; t=5 (ddeml) i=843
;extrn PASCAL DdeInitialize:FAR ; t=128 (ddeml) i=844
;extrn PASCAL DdeKeepStringHandle:FAR ; t=6 (ddeml) i=845
;extrn PASCAL DdeNameService:FAR ; t=129 (ddeml) i=846
;extrn PASCAL DdePostAdvise:FAR ; t=85 (ddeml) i=847
;extrn PASCAL DdeQueryConvInfo:FAR ; t=130 (ddeml) i=848
;extrn PASCAL DdeQueryNextServer:FAR ; t=6 (ddeml) i=849
;extrn PASCAL DdeQueryString:FAR ; t=131 (ddeml) i=850
;extrn PASCAL DdeReconnect:FAR ; t=5 (ddeml) i=851
;extrn PASCAL DdeSetUserHandle:FAR ; t=85 (ddeml) i=852
;extrn PASCAL DdeUnaccessData:FAR ; t=5 (ddeml) i=853
;extrn PASCAL DdeUninitialize:FAR ; t=5 (ddeml) i=854
;      PASCAL _16DdeAccessData ; t=6 (ddeml) i=855
;      PASCAL _16DdeAddData ; t=87 (ddeml) i=856
;      PASCAL _16DdeClientTransaction ; t=132 (ddeml) i=857
;      PASCAL _16DdeConnect ; t=87 (ddeml) i=858
;      PASCAL _16DdeConnectList ; t=133 (ddeml) i=859
;      PASCAL _16DdeCreateDataHandle ; t=134 (ddeml) i=860
;      PASCAL _16DdeCreateStringHandle ; t=102 (ddeml) i=861
;      PASCAL _16DdeGetData ; t=87 (ddeml) i=862
;      PASCAL _16DdeInitialize ; t=87 (ddeml) i=863
;      PASCAL _16DdeQueryConvInfo ; t=85 (ddeml) i=864
;      PASCAL _16DdeQueryString ; t=108 (ddeml) i=865
;extrn PASCAL ChooseColor:FAR ; t=2 (commdlg) i=866
;extrn PASCAL ChooseFont:FAR ; t=2 (commdlg) i=867
;extrn PASCAL FindText:FAR ; t=2 (commdlg) i=868
;extrn PASCAL GetFileTitle:FAR ; t=53 (commdlg) i=869
;extrn PASCAL GetOpenFileName:FAR ; t=2 (commdlg) i=870
;extrn PASCAL GetSaveFileName:FAR ; t=2 (commdlg) i=871
;extrn PASCAL PrintDlg:FAR ; t=2 (commdlg) i=872
;extrn PASCAL ReplaceText:FAR ; t=2 (commdlg) i=873
;extrn PASCAL CommDlgExtendedError:FAR ; t=7 (commdlg) i=874
;      PASCAL _16ChooseColor ; t=5 (commdlg) i=875
;      PASCAL _16ChooseFont ; t=5 (commdlg) i=876
;      PASCAL _16FindText ; t=5 (commdlg) i=877
;      PASCAL _16GetFileTitle ; t=102 (commdlg) i=878
;      PASCAL _16GetOpenFileName ; t=5 (commdlg) i=879
;      PASCAL _16GetSaveFileName ; t=5 (commdlg) i=880
;      PASCAL _16PrintDlg ; t=5 (commdlg) i=881
;      PASCAL _16ReplaceText ; t=5 (commdlg) i=882
;extrn PASCAL RegOpenKey:FAR ; t=135 (shell) i=883
;extrn PASCAL RegCreateKey:FAR ; t=135 (shell) i=884
;extrn PASCAL RegCloseKey:FAR ; t=5 (shell) i=885
;extrn PASCAL RegDeleteKey:FAR ; t=120 (shell) i=886
;extrn PASCAL RegSetValue:FAR ; t=136 (shell) i=887
;extrn PASCAL RegQueryValue:FAR ; t=137 (shell) i=888
;extrn PASCAL RegEnumKey:FAR ; t=138 (shell) i=889
;extrn PASCAL DragQueryFile:FAR ; t=52 (shell) i=890
;extrn PASCAL DragQueryPoint:FAR ; t=10 (shell) i=891
;extrn PASCAL ExtractIcon:FAR ; t=39 (shell) i=892
;extrn PASCAL ShellExecute:FAR ; t=139 (shell) i=893
;extrn PASCAL FindExecutable:FAR ; t=20 (shell) i=894
;      PASCAL _16RegOpenKey ; t=85 (shell) i=895
;      PASCAL _16RegCreateKey ; t=85 (shell) i=896
;      PASCAL _16RegDeleteKey ; t=6 (shell) i=897
;      PASCAL _16RegSetValue ; t=133 (shell) i=898
;      PASCAL _16RegQueryValue ; t=87 (shell) i=899
;      PASCAL _16RegEnumKey ; t=87 (shell) i=900
;      PASCAL _16DragQueryFile ; t=101 (shell) i=901
;      PASCAL _16DragQueryPoint ; t=17 (shell) i=902
;      PASCAL _16ExtractIcon ; t=56 (shell) i=903
;      PASCAL _16ShellExecute ; t=90 (shell) i=904
;      PASCAL _16FindExecutable ; t=85 (shell) i=905
;extrn PASCAL AddPointsPenData:FAR ; t=31 (penwin) i=906
;extrn PASCAL BeginEnumStrokes:FAR ; t=0 (penwin) i=907
;extrn PASCAL CharacterToSymbol:FAR ; t=122 (penwin) i=908
;extrn PASCAL CompactPenData:FAR ; t=1 (penwin) i=909
;extrn PASCAL CorrectWriting:FAR ; t=140 (penwin) i=910
;extrn PASCAL CreatePenData:FAR ; t=58 (penwin) i=911
;extrn PASCAL DictionarySearch:FAR ; t=141 (penwin) i=912
;extrn PASCAL DPtoTP:FAR ; t=4 (penwin) i=913
;extrn PASCAL DuplicatePenData:FAR ; t=1 (penwin) i=914
;extrn PASCAL EndPenCollection:FAR ; t=0 (penwin) i=915
;extrn PASCAL EnumSymbols:FAR ; t=142 (penwin) i=916
;extrn PASCAL ExecuteGesture:FAR ; t=143 (penwin) i=917
;extrn PASCAL GetGlobalRC:FAR ; t=144 (penwin) i=918
;extrn PASCAL GetPenAsyncState:FAR ; t=0 (penwin) i=919
;extrn PASCAL GetPenDataInfo:FAR ; t=145 (penwin) i=920
;extrn PASCAL GetPenDataStroke:FAR ; t=146 (penwin) i=921
;extrn PASCAL GetPenHwData:FAR ; t=147 (penwin) i=922
;extrn PASCAL GetPenHwEventData:FAR ; t=148 (penwin) i=923
;extrn PASCAL GetPointsFromPenData:FAR ; t=149 (penwin) i=924
;extrn PASCAL GetSymbolCount:FAR ; t=2 (penwin) i=925
;extrn PASCAL GetSymbolMaxLength:FAR ; t=2 (penwin) i=926
;extrn PASCAL GetVersionPenWin:FAR ; t=7 (penwin) i=927
;extrn PASCAL InstallRecognizer:FAR ; t=2 (penwin) i=928
;extrn PASCAL IsPenAware:FAR ; t=7 (penwin) i=929
;extrn PASCAL IsPenEvent:FAR ; t=17 (penwin) i=930
;extrn PASCAL MetricScalePenData:FAR ; t=1 (penwin) i=931
;extrn PASCAL OffsetPenData:FAR ; t=16 (penwin) i=932
;extrn PASCAL ProcessWriting:FAR ; t=10 (penwin) i=933
;extrn PASCAL Recognize:FAR ; t=2 (penwin) i=934
;extrn PASCAL RecognizeData:FAR ; t=4 (penwin) i=935
;extrn PASCAL RedisplayPenData:FAR ; t=150 (penwin) i=936
;extrn PASCAL ResizePenData:FAR ; t=10 (penwin) i=937
;extrn PASCAL SetGlobalRC:FAR ; t=20 (penwin) i=938
;extrn PASCAL SetPenHook:FAR ; t=17 (penwin) i=939
;extrn PASCAL SetRecogHook:FAR ; t=16 (penwin) i=940
;extrn PASCAL ShowKeyboard:FAR ; t=151 (penwin) i=941
;extrn PASCAL SymbolToCharacter:FAR ; t=152 (penwin) i=942
;extrn PASCAL TPtoDP:FAR ; t=4 (penwin) i=943
;extrn PASCAL TrainContext:FAR ; t=141 (penwin) i=944
;extrn PASCAL TrainInk:FAR ; t=122 (penwin) i=945
;      PASCAL _16AddPointsPenData ; t=94 (penwin) i=946
;      PASCAL _16CharacterToSymbol ; t=153 (penwin) i=947
;      PASCAL _16CorrectWriting ; t=154 (penwin) i=948
;      PASCAL _16CreatePenData ; t=105 (penwin) i=949
;      PASCAL _16DictionarySearch ; t=155 (penwin) i=950
;      PASCAL _16DPtoTP ; t=47 (penwin) i=951
;      PASCAL _16EnumSymbols ; t=156 (penwin) i=952
;      PASCAL _16ExecuteGesture ; t=18 (penwin) i=953
;      PASCAL _16GetGlobalRC ; t=129 (penwin) i=954
;      PASCAL _16GetPenDataInfo ; t=94 (penwin) i=955
;      PASCAL _16GetPenDataStroke ; t=157 (penwin) i=956
;      PASCAL _16GetPenHwData ; t=158 (penwin) i=957
;      PASCAL _16GetPenHwEventData ; t=159 (penwin) i=958
;      PASCAL _16GetPointsFromPenData ; t=21 (penwin) i=959
;      PASCAL _16GetSymbolCount ; t=5 (penwin) i=960
;      PASCAL _16GetSymbolMaxLength ; t=5 (penwin) i=961
;      PASCAL _16InstallRecognizer ; t=5 (penwin) i=962
;      PASCAL _16ProcessWriting ; t=17 (penwin) i=963
;      PASCAL _16Recognize ; t=5 (penwin) i=964
;      PASCAL _16RecognizeData ; t=47 (penwin) i=965
;      PASCAL _16RedisplayPenData ; t=159 (penwin) i=966
;      PASCAL _16ResizePenData ; t=17 (penwin) i=967
;      PASCAL _16SetGlobalRC ; t=85 (penwin) i=968
;      PASCAL _16ShowKeyboard ; t=45 (penwin) i=969
;      PASCAL _16SymbolToCharacter ; t=156 (penwin) i=970
;      PASCAL _16TPtoDP ; t=47 (penwin) i=971
;      PASCAL _16TrainContext ; t=155 (penwin) i=972
;      PASCAL _16TrainInk ; t=153 (penwin) i=973
;extrn PASCAL GetFileResource:FAR ; t=160 (ver) i=974
;extrn PASCAL GetFileResourceSize:FAR ; t=23 (ver) i=975
;extrn PASCAL GetFileVersionInfo:FAR ; t=161 (ver) i=976
;extrn PASCAL GetFileVersionInfoSize:FAR ; t=12 (ver) i=977
;extrn PASCAL GetSystemDir:FAR ; t=53 (ver) i=978
;extrn PASCAL GetWindowsDir:FAR ; t=53 (ver) i=979
;extrn PASCAL VerFindFile:FAR ; t=162 (ver) i=980
;extrn PASCAL VerInstallFile:FAR ; t=162 (ver) i=981
;extrn PASCAL VerLanguageName:FAR ; t=39 (ver) i=982
;extrn PASCAL VerQueryValue:FAR ; t=23 (ver) i=983
;      PASCAL _16GetFileResource ; t=163 (ver) i=984
;      PASCAL _16GetFileResourceSize ; t=87 (ver) i=985
;      PASCAL _16GetFileVersionInfo ; t=87 (ver) i=986
;      PASCAL _16GetFileVersionInfoSize ; t=6 (ver) i=987
;      PASCAL _16GetSystemDir ; t=102 (ver) i=988
;      PASCAL _16GetWindowsDir ; t=102 (ver) i=989
;      PASCAL _16VerFindFile ; t=164 (ver) i=990
;      PASCAL _16VerInstallFile ; t=164 (ver) i=991
;      PASCAL _16VerLanguageName ; t=56 (ver) i=992
;      PASCAL _16VerQueryValue ; t=87 (ver) i=993
;extrn PASCAL AllocDiskSpace:FAR ; t=47 (stress) i=994
;extrn PASCAL AllocFileHandles:FAR ; t=0 (stress) i=995
;extrn PASCAL AllocGDIMem:FAR ; t=0 (stress) i=996
;extrn PASCAL AllocMem:FAR ; t=5 (stress) i=997
;extrn PASCAL AllocUserMem:FAR ; t=0 (stress) i=998
;extrn PASCAL GetFreeFileHandles:FAR ; t=7 (stress) i=999
;extrn PASCAL CopyLZFile:FAR ; t=1 (lzexpand) i=1000
;extrn PASCAL GetExpandedName:FAR ; t=12 (lzexpand) i=1001
;extrn PASCAL LZCopy:FAR ; t=1 (lzexpand) i=1002
;extrn PASCAL LZInit:FAR ; t=0 (lzexpand) i=1003
;extrn PASCAL LZOpenFile:FAR ; t=53 (lzexpand) i=1004
;extrn PASCAL LZRead:FAR ; t=39 (lzexpand) i=1005
;extrn PASCAL LZSeek:FAR ; t=56 (lzexpand) i=1006
;extrn PASCAL LZStart:FAR ; t=7 (lzexpand) i=1007
;      PASCAL _16GetExpandedName ; t=6 (lzexpand) i=1008
;      PASCAL _16LZOpenFile ; t=102 (lzexpand) i=1009
;      PASCAL _16LZRead ; t=56 (lzexpand) i=1010
;extrn PASCAL auxGetDevCaps:FAR ; t=39 (mmsystem) i=1011
;extrn PASCAL auxGetNumDevs:FAR ; t=7 (mmsystem) i=1012
;extrn PASCAL auxGetVolume:FAR ; t=10 (mmsystem) i=1013
;extrn PASCAL auxOutMessage:FAR ; t=45 (mmsystem) i=1014
;extrn PASCAL auxSetVolume:FAR ; t=17 (mmsystem) i=1015
;extrn PASCAL joyGetDevCaps:FAR ; t=39 (mmsystem) i=1016
;extrn PASCAL joyGetNumDevs:FAR ; t=7 (mmsystem) i=1017
;extrn PASCAL joyGetPos:FAR ; t=10 (mmsystem) i=1018
;extrn PASCAL joyGetThreshold:FAR ; t=10 (mmsystem) i=1019
;extrn PASCAL joyReleaseCapture:FAR ; t=0 (mmsystem) i=1020
;extrn PASCAL joySetCapture:FAR ; t=19 (mmsystem) i=1021
;extrn PASCAL joySetThreshold:FAR ; t=1 (mmsystem) i=1022
;extrn PASCAL mciGetCreatorTask:FAR ; t=0 (mmsystem) i=1023
;extrn PASCAL mciGetDeviceID:FAR ; t=2 (mmsystem) i=1024
;extrn PASCAL mciGetDeviceIDFromElementID:FAR ; t=120 (mmsystem) i=1025
;extrn PASCAL mciGetErrorString:FAR ; t=57 (mmsystem) i=1026
;extrn PASCAL mciGetYieldProc:FAR ; t=10 (mmsystem) i=1027
;extrn PASCAL mciSendCommand:FAR ; t=45 (mmsystem) i=1028
;extrn PASCAL mciSendString:FAR ; t=29 (mmsystem) i=1029
;extrn PASCAL mciSetYieldProc:FAR ; t=18 (mmsystem) i=1030
;extrn PASCAL midiInAddBuffer:FAR ; t=39 (mmsystem) i=1031
;extrn PASCAL midiInClose:FAR ; t=0 (mmsystem) i=1032
;extrn PASCAL midiInGetDevCaps:FAR ; t=39 (mmsystem) i=1033
;extrn PASCAL midiInGetErrorText:FAR ; t=39 (mmsystem) i=1034
;extrn PASCAL midiInGetID:FAR ; t=10 (mmsystem) i=1035
;extrn PASCAL midiInGetNumDevs:FAR ; t=7 (mmsystem) i=1036
;extrn PASCAL midiInMessage:FAR ; t=45 (mmsystem) i=1037
;extrn PASCAL midiInOpen:FAR ; t=165 (mmsystem) i=1038
;extrn PASCAL midiInPrepareHeader:FAR ; t=39 (mmsystem) i=1039
;extrn PASCAL midiInReset:FAR ; t=0 (mmsystem) i=1040
;extrn PASCAL midiInStart:FAR ; t=0 (mmsystem) i=1041
;extrn PASCAL midiInStop:FAR ; t=0 (mmsystem) i=1042
;extrn PASCAL midiInUnprepareHeader:FAR ; t=39 (mmsystem) i=1043
;extrn PASCAL midiOutCacheDrumPatches:FAR ; t=52 (mmsystem) i=1044
;extrn PASCAL midiOutCachePatches:FAR ; t=52 (mmsystem) i=1045
;extrn PASCAL midiOutClose:FAR ; t=0 (mmsystem) i=1046
;extrn PASCAL midiOutGetDevCaps:FAR ; t=39 (mmsystem) i=1047
;extrn PASCAL midiOutGetErrorText:FAR ; t=39 (mmsystem) i=1048
;extrn PASCAL midiOutGetID:FAR ; t=10 (mmsystem) i=1049
;extrn PASCAL midiOutGetNumDevs:FAR ; t=7 (mmsystem) i=1050
;extrn PASCAL midiOutGetVolume:FAR ; t=10 (mmsystem) i=1051
;extrn PASCAL midiOutLongMsg:FAR ; t=39 (mmsystem) i=1052
;extrn PASCAL midiOutMessage:FAR ; t=45 (mmsystem) i=1053
;extrn PASCAL midiOutOpen:FAR ; t=165 (mmsystem) i=1054
;extrn PASCAL midiOutPrepareHeader:FAR ; t=39 (mmsystem) i=1055
;extrn PASCAL midiOutReset:FAR ; t=0 (mmsystem) i=1056
;extrn PASCAL midiOutSetVolume:FAR ; t=17 (mmsystem) i=1057
;extrn PASCAL midiOutShortMsg:FAR ; t=17 (mmsystem) i=1058
;extrn PASCAL midiOutUnprepareHeader:FAR ; t=39 (mmsystem) i=1059
;extrn PASCAL mmioAdvance:FAR ; t=39 (mmsystem) i=1060
;extrn PASCAL mmioAscend:FAR ; t=39 (mmsystem) i=1061
;extrn PASCAL mmioClose:FAR ; t=1 (mmsystem) i=1062
;extrn PASCAL mmioCreateChunk:FAR ; t=39 (mmsystem) i=1063
;extrn PASCAL mmioDescend:FAR ; t=66 (mmsystem) i=1064
;extrn PASCAL mmioFlush:FAR ; t=1 (mmsystem) i=1065
;extrn PASCAL mmioGetInfo:FAR ; t=39 (mmsystem) i=1066
;extrn PASCAL mmioInstallIOProc:FAR ; t=85 (mmsystem) i=1067
;extrn PASCAL mmioOpen:FAR ; t=67 (mmsystem) i=1068
;extrn PASCAL mmioRead:FAR ; t=18 (mmsystem) i=1069
;extrn PASCAL mmioRename:FAR ; t=166 (mmsystem) i=1070
;extrn PASCAL mmioSeek:FAR ; t=56 (mmsystem) i=1071
;extrn PASCAL mmioSendMessage:FAR ; t=45 (mmsystem) i=1072
;extrn PASCAL mmioSetBuffer:FAR ; t=167 (mmsystem) i=1073
;extrn PASCAL mmioSetInfo:FAR ; t=39 (mmsystem) i=1074
;extrn PASCAL mmioStringToFOURCC:FAR ; t=4 (mmsystem) i=1075
;extrn PASCAL mmioWrite:FAR ; t=18 (mmsystem) i=1076
;extrn PASCAL mmsystemGetVersion:FAR ; t=7 (mmsystem) i=1077
;extrn PASCAL sndPlaySound:FAR ; t=4 (mmsystem) i=1078
;extrn PASCAL timeBeginPeriod:FAR ; t=0 (mmsystem) i=1079
;extrn PASCAL timeEndPeriod:FAR ; t=0 (mmsystem) i=1080
;extrn PASCAL timeGetDevCaps:FAR ; t=4 (mmsystem) i=1081
;extrn PASCAL timeGetSystemTime:FAR ; t=4 (mmsystem) i=1082
;extrn PASCAL timeGetTime:FAR ; t=7 (mmsystem) i=1083
;extrn PASCAL timeKillEvent:FAR ; t=0 (mmsystem) i=1084
;extrn PASCAL timeSetEvent:FAR ; t=118 (mmsystem) i=1085
;extrn PASCAL waveInAddBuffer:FAR ; t=39 (mmsystem) i=1086
;extrn PASCAL waveInClose:FAR ; t=0 (mmsystem) i=1087
;extrn PASCAL waveInGetDevCaps:FAR ; t=39 (mmsystem) i=1088
;extrn PASCAL waveInGetErrorText:FAR ; t=39 (mmsystem) i=1089
;extrn PASCAL waveInGetID:FAR ; t=10 (mmsystem) i=1090
;extrn PASCAL waveInGetNumDevs:FAR ; t=7 (mmsystem) i=1091
;extrn PASCAL waveInGetPosition:FAR ; t=39 (mmsystem) i=1092
;extrn PASCAL waveInMessage:FAR ; t=45 (mmsystem) i=1093
;extrn PASCAL waveInOpen:FAR ; t=168 (mmsystem) i=1094
;extrn PASCAL waveInPrepareHeader:FAR ; t=39 (mmsystem) i=1095
;extrn PASCAL waveInReset:FAR ; t=0 (mmsystem) i=1096
;extrn PASCAL waveInStart:FAR ; t=0 (mmsystem) i=1097
;extrn PASCAL waveInStop:FAR ; t=0 (mmsystem) i=1098
;extrn PASCAL waveInUnprepareHeader:FAR ; t=39 (mmsystem) i=1099
;extrn PASCAL waveOutBreakLoop:FAR ; t=0 (mmsystem) i=1100
;extrn PASCAL waveOutClose:FAR ; t=0 (mmsystem) i=1101
;extrn PASCAL waveOutGetDevCaps:FAR ; t=39 (mmsystem) i=1102
;extrn PASCAL waveOutGetErrorText:FAR ; t=39 (mmsystem) i=1103
;extrn PASCAL waveOutGetID:FAR ; t=10 (mmsystem) i=1104
;extrn PASCAL waveOutGetNumDevs:FAR ; t=7 (mmsystem) i=1105
;extrn PASCAL waveOutGetPitch:FAR ; t=10 (mmsystem) i=1106
;extrn PASCAL waveOutGetPlaybackRate:FAR ; t=10 (mmsystem) i=1107
;extrn PASCAL waveOutGetPosition:FAR ; t=39 (mmsystem) i=1108
;extrn PASCAL waveOutGetVolume:FAR ; t=10 (mmsystem) i=1109
;extrn PASCAL waveOutMessage:FAR ; t=45 (mmsystem) i=1110
;extrn PASCAL waveOutOpen:FAR ; t=168 (mmsystem) i=1111
;extrn PASCAL waveOutPause:FAR ; t=0 (mmsystem) i=1112
;extrn PASCAL waveOutPrepareHeader:FAR ; t=39 (mmsystem) i=1113
;extrn PASCAL waveOutReset:FAR ; t=0 (mmsystem) i=1114
;extrn PASCAL waveOutRestart:FAR ; t=0 (mmsystem) i=1115
;extrn PASCAL waveOutSetPitch:FAR ; t=17 (mmsystem) i=1116
;extrn PASCAL waveOutSetPlaybackRate:FAR ; t=17 (mmsystem) i=1117
;extrn PASCAL waveOutSetVolume:FAR ; t=17 (mmsystem) i=1118
;extrn PASCAL waveOutUnprepareHeader:FAR ; t=39 (mmsystem) i=1119
;extrn PASCAL waveOutWrite:FAR ; t=39 (mmsystem) i=1120
;      PASCAL _16auxGetDevCaps ; t=56 (mmsystem) i=1121
;      PASCAL _16auxGetVolume ; t=17 (mmsystem) i=1122
;      PASCAL _16joyGetDevCaps ; t=56 (mmsystem) i=1123
;      PASCAL _16joyGetPos ; t=17 (mmsystem) i=1124
;      PASCAL _16joyGetThreshold ; t=17 (mmsystem) i=1125
;      PASCAL _16mciGetDeviceID ; t=5 (mmsystem) i=1126
;      PASCAL _16mciGetDeviceIDFromElementID ; t=6 (mmsystem) i=1127
;      PASCAL _16mciGetErrorString ; t=102 (mmsystem) i=1128
;      PASCAL _16mciGetYieldProc ; t=17 (mmsystem) i=1129
;      PASCAL _16mciSendString ; t=93 (mmsystem) i=1130
;      PASCAL _16midiInAddBuffer ; t=56 (mmsystem) i=1131
;      PASCAL _16midiInGetDevCaps ; t=56 (mmsystem) i=1132
;      PASCAL _16midiInGetErrorText ; t=56 (mmsystem) i=1133
;      PASCAL _16midiInGetID ; t=17 (mmsystem) i=1134
;      PASCAL _16midiInOpen ; t=157 (mmsystem) i=1135
;      PASCAL _16midiInPrepareHeader ; t=56 (mmsystem) i=1136
;      PASCAL _16midiInUnprepareHeader ; t=56 (mmsystem) i=1137
;      PASCAL _16midiOutCacheDrumPatches ; t=101 (mmsystem) i=1138
;      PASCAL _16midiOutCachePatches ; t=101 (mmsystem) i=1139
;      PASCAL _16midiOutGetDevCaps ; t=56 (mmsystem) i=1140
;      PASCAL _16midiOutGetErrorText ; t=56 (mmsystem) i=1141
;      PASCAL _16midiOutGetID ; t=17 (mmsystem) i=1142
;      PASCAL _16midiOutGetVolume ; t=17 (mmsystem) i=1143
;      PASCAL _16midiOutLongMsg ; t=56 (mmsystem) i=1144
;      PASCAL _16midiOutOpen ; t=157 (mmsystem) i=1145
;      PASCAL _16midiOutPrepareHeader ; t=56 (mmsystem) i=1146
;      PASCAL _16midiOutUnprepareHeader ; t=56 (mmsystem) i=1147
;      PASCAL _16mmioAdvance ; t=56 (mmsystem) i=1148
;      PASCAL _16mmioAscend ; t=56 (mmsystem) i=1149
;      PASCAL _16mmioCreateChunk ; t=56 (mmsystem) i=1150
;      PASCAL _16mmioDescend ; t=111 (mmsystem) i=1151
;      PASCAL _16mmioGetInfo ; t=56 (mmsystem) i=1152
;      PASCAL _16mmioOpen ; t=85 (mmsystem) i=1153
;      PASCAL _16mmioRename ; t=87 (mmsystem) i=1154
;      PASCAL _16mmioSetBuffer ; t=111 (mmsystem) i=1155
;      PASCAL _16mmioSetInfo ; t=56 (mmsystem) i=1156
;      PASCAL _16mmioStringToFOURCC ; t=47 (mmsystem) i=1157
;      PASCAL _16sndPlaySound ; t=47 (mmsystem) i=1158
;      PASCAL _16timeGetDevCaps ; t=47 (mmsystem) i=1159
;      PASCAL _16timeGetSystemTime ; t=47 (mmsystem) i=1160
;      PASCAL _16waveInAddBuffer ; t=56 (mmsystem) i=1161
;      PASCAL _16waveInGetDevCaps ; t=56 (mmsystem) i=1162
;      PASCAL _16waveInGetErrorText ; t=56 (mmsystem) i=1163
;      PASCAL _16waveInGetID ; t=17 (mmsystem) i=1164
;      PASCAL _16waveInGetPosition ; t=56 (mmsystem) i=1165
;      PASCAL _16waveInOpen ; t=169 (mmsystem) i=1166
;      PASCAL _16waveInPrepareHeader ; t=56 (mmsystem) i=1167
;      PASCAL _16waveInUnprepareHeader ; t=56 (mmsystem) i=1168
;      PASCAL _16waveOutGetDevCaps ; t=56 (mmsystem) i=1169
;      PASCAL _16waveOutGetErrorText ; t=56 (mmsystem) i=1170
;      PASCAL _16waveOutGetID ; t=17 (mmsystem) i=1171
;      PASCAL _16waveOutGetPitch ; t=17 (mmsystem) i=1172
;      PASCAL _16waveOutGetPlaybackRate ; t=17 (mmsystem) i=1173
;      PASCAL _16waveOutGetPosition ; t=56 (mmsystem) i=1174
;      PASCAL _16waveOutGetVolume ; t=17 (mmsystem) i=1175
;      PASCAL _16waveOutOpen ; t=169 (mmsystem) i=1176
;      PASCAL _16waveOutPrepareHeader ; t=56 (mmsystem) i=1177
;      PASCAL _16waveOutUnprepareHeader ; t=56 (mmsystem) i=1178
;      PASCAL _16waveOutWrite ; t=56 (mmsystem) i=1179
;extrn PASCAL ClassFirst:FAR ; t=2 (toolhelp) i=1180
;extrn PASCAL ClassNext:FAR ; t=2 (toolhelp) i=1181
;extrn PASCAL GlobalEntryHandle:FAR ; t=4 (toolhelp) i=1182
;extrn PASCAL GlobalEntryModule:FAR ; t=28 (toolhelp) i=1183
;extrn PASCAL GlobalFirst:FAR ; t=4 (toolhelp) i=1184
;extrn PASCAL GlobalHandleToSel:FAR ; t=0 (toolhelp) i=1185
;extrn PASCAL GlobalInfo:FAR ; t=2 (toolhelp) i=1186
;extrn PASCAL GlobalNext:FAR ; t=4 (toolhelp) i=1187
;extrn PASCAL LocalFirst:FAR ; t=4 (toolhelp) i=1188
;extrn PASCAL LocalInfo:FAR ; t=4 (toolhelp) i=1189
;extrn PASCAL LocalNext:FAR ; t=2 (toolhelp) i=1190
;extrn PASCAL MemManInfo:FAR ; t=2 (toolhelp) i=1191
extrn PASCAL __MemoryRead:FAR ; t=94 i=1192
extrn PASCAL __MemoryWrite:FAR ; t=94 i=1193
;extrn PASCAL ModuleFindHandle:FAR ; t=4 (toolhelp) i=1194
;extrn PASCAL ModuleFindName:FAR ; t=12 (toolhelp) i=1195
;extrn PASCAL ModuleFirst:FAR ; t=2 (toolhelp) i=1196
;extrn PASCAL ModuleNext:FAR ; t=2 (toolhelp) i=1197
;extrn PASCAL NotifyRegister:FAR ; t=56 (toolhelp) i=1198
;extrn PASCAL NotifyUnRegister:FAR ; t=0 (toolhelp) i=1199
;extrn PASCAL StackTraceCSIPFirst:FAR ; t=69 (toolhelp) i=1200
;extrn PASCAL StackTraceFirst:FAR ; t=4 (toolhelp) i=1201
;extrn PASCAL StackTraceNext:FAR ; t=2 (toolhelp) i=1202
;extrn PASCAL SystemHeapInfo:FAR ; t=2 (toolhelp) i=1203
;extrn PASCAL TaskFindHandle:FAR ; t=4 (toolhelp) i=1204
;extrn PASCAL TaskFirst:FAR ; t=2 (toolhelp) i=1205
;extrn PASCAL TaskGetCSIP:FAR ; t=0 (toolhelp) i=1206
;extrn PASCAL TaskNext:FAR ; t=2 (toolhelp) i=1207
;extrn PASCAL TaskSetCSIP:FAR ; t=16 (toolhelp) i=1208
;extrn PASCAL TaskSwitch:FAR ; t=17 (toolhelp) i=1209
;extrn PASCAL TimerCount:FAR ; t=2 (toolhelp) i=1210
;      PASCAL _16ClassFirst ; t=5 (toolhelp) i=1211
;      PASCAL _16ClassNext ; t=5 (toolhelp) i=1212
;      PASCAL _16GlobalEntryHandle ; t=47 (toolhelp) i=1213
;      PASCAL _16GlobalEntryModule ; t=92 (toolhelp) i=1214
;      PASCAL _16GlobalFirst ; t=47 (toolhelp) i=1215
;      PASCAL _16GlobalInfo ; t=5 (toolhelp) i=1216
;      PASCAL _16GlobalNext ; t=47 (toolhelp) i=1217
;      PASCAL _16LocalFirst ; t=47 (toolhelp) i=1218
;      PASCAL _16LocalInfo ; t=47 (toolhelp) i=1219
;      PASCAL _16LocalNext ; t=5 (toolhelp) i=1220
;      PASCAL _16MemManInfo ; t=5 (toolhelp) i=1221
;extrn PASCAL MemoryRead:FAR ; t=94 (toolhelp) i=1222
;extrn PASCAL MemoryWrite:FAR ; t=94 (toolhelp) i=1223
;      PASCAL _16ModuleFindHandle ; t=47 (toolhelp) i=1224
;      PASCAL _16ModuleFindName ; t=6 (toolhelp) i=1225
;      PASCAL _16ModuleFirst ; t=5 (toolhelp) i=1226
;      PASCAL _16ModuleNext ; t=5 (toolhelp) i=1227
;      PASCAL _16StackTraceCSIPFirst ; t=112 (toolhelp) i=1228
;      PASCAL _16StackTraceFirst ; t=47 (toolhelp) i=1229
;      PASCAL _16StackTraceNext ; t=5 (toolhelp) i=1230
;      PASCAL _16SystemHeapInfo ; t=5 (toolhelp) i=1231
;      PASCAL _16TaskFindHandle ; t=47 (toolhelp) i=1232
;      PASCAL _16TaskFirst ; t=5 (toolhelp) i=1233
;      PASCAL _16TaskNext ; t=5 (toolhelp) i=1234
;      PASCAL _16TimerCount ; t=5 (toolhelp) i=1235
;extrn PASCAL SQLAllocConnect:FAR ; t=12 (odbc) i=1236
;extrn PASCAL SQLAllocEnv:FAR ; t=2 (odbc) i=1237
;extrn PASCAL SQLAllocStmt:FAR ; t=12 (odbc) i=1238
;extrn PASCAL SQLBindCol:FAR ; t=170 (odbc) i=1239
;extrn PASCAL SQLBrowseConnect:FAR ; t=171 (odbc) i=1240
;extrn PASCAL SQLCancel:FAR ; t=2 (odbc) i=1241
;extrn PASCAL SQLColAttributes:FAR ; t=172 (odbc) i=1242
;extrn PASCAL SQLColumnPrivileges:FAR ; t=173 (odbc) i=1243
;extrn PASCAL SQLColumns:FAR ; t=173 (odbc) i=1244
;extrn PASCAL SQLConnect:FAR ; t=174 (odbc) i=1245
;extrn PASCAL SQLDataSources:FAR ; t=175 (odbc) i=1246
;extrn PASCAL SQLDescribeCol:FAR ; t=176 (odbc) i=1247
;extrn PASCAL SQLDescribeParam:FAR ; t=177 (odbc) i=1248
;extrn PASCAL SQLDisconnect:FAR ; t=2 (odbc) i=1249
;extrn PASCAL SQLDriverConnect:FAR ; t=178 (odbc) i=1250
;extrn PASCAL SQLError:FAR ; t=179 (odbc) i=1251
;extrn PASCAL SQLExecDirect:FAR ; t=67 (odbc) i=1252
;extrn PASCAL SQLExecute:FAR ; t=2 (odbc) i=1253
;extrn PASCAL SQLExtendedFetch:FAR ; t=180 (odbc) i=1254
;extrn PASCAL SQLFetch:FAR ; t=2 (odbc) i=1255
;extrn PASCAL SQLForeignKeys:FAR ; t=181 (odbc) i=1256
;extrn PASCAL SQLFreeConnect:FAR ; t=2 (odbc) i=1257
;extrn PASCAL SQLFreeEnv:FAR ; t=2 (odbc) i=1258
;extrn PASCAL SQLFreeStmt:FAR ; t=4 (odbc) i=1259
;extrn PASCAL SQLGetConnectOption:FAR ; t=122 (odbc) i=1260
;extrn PASCAL SQLGetCursorName:FAR ; t=60 (odbc) i=1261
;extrn PASCAL SQLGetData:FAR ; t=182 (odbc) i=1262
;extrn PASCAL SQLGetFunctions:FAR ; t=122 (odbc) i=1263
;extrn PASCAL SQLGetInfo:FAR ; t=183 (odbc) i=1264
;extrn PASCAL SQLGetStmtOption:FAR ; t=122 (odbc) i=1265
;extrn PASCAL SQLGetTypeInfo:FAR ; t=4 (odbc) i=1266
;extrn PASCAL SQLMoreResults:FAR ; t=2 (odbc) i=1267
;extrn PASCAL SQLNativeSql:FAR ; t=184 (odbc) i=1268
;extrn PASCAL SQLNumParams:FAR ; t=12 (odbc) i=1269
;extrn PASCAL SQLNumResultCols:FAR ; t=12 (odbc) i=1270
;extrn PASCAL SQLParamData:FAR ; t=12 (odbc) i=1271
;extrn PASCAL SQLParamOptions:FAR ; t=185 (odbc) i=1272
;extrn PASCAL SQLPrepare:FAR ; t=67 (odbc) i=1273
;extrn PASCAL SQLPrimaryKeys:FAR ; t=174 (odbc) i=1274
;extrn PASCAL SQLProcedureColumns:FAR ; t=173 (odbc) i=1275
;extrn PASCAL SQLProcedures:FAR ; t=174 (odbc) i=1276
;extrn PASCAL SQLPutData:FAR ; t=67 (odbc) i=1277
;extrn PASCAL SQLRowCount:FAR ; t=12 (odbc) i=1278
;extrn PASCAL SQLSetConnectOption:FAR ; t=186 (odbc) i=1279
;extrn PASCAL SQLSetCursorName:FAR ; t=53 (odbc) i=1280
;extrn PASCAL SQLSetParam:FAR ; t=187 (odbc) i=1281
;extrn PASCAL SQLSetPos:FAR ; t=58 (odbc) i=1282
;extrn PASCAL SQLSetScrollOptions:FAR ; t=188 (odbc) i=1283
;extrn PASCAL SQLSetStmtOption:FAR ; t=186 (odbc) i=1284
;extrn PASCAL SQLSpecialColumns:FAR ; t=189 (odbc) i=1285
;extrn PASCAL SQLStatistics:FAR ; t=190 (odbc) i=1286
;extrn PASCAL SQLTablePrivileges:FAR ; t=174 (odbc) i=1287
;extrn PASCAL SQLTables:FAR ; t=173 (odbc) i=1288
;extrn PASCAL SQLTransact:FAR ; t=53 (odbc) i=1289
extrn PASCAL ResetDC:FAR ; t=10 i=1290
extrn PASCAL AdjustWindowRect:FAR ; t=191 i=1291
extrn PASCAL AdjustWindowRectEx:FAR ; t=192 i=1292
extrn PASCAL AnimatePalette:FAR ; t=50 i=1293
extrn PASCAL AnsiToOem:FAR ; t=12 i=1294
extrn PASCAL AnsiToOemBuff:FAR ; t=53 i=1295
extrn PASCAL CheckDlgButton:FAR ; t=16 i=1296
extrn PASCAL CheckRadioButton:FAR ; t=19 i=1297
extrn PASCAL ClientToScreen:FAR ; t=10 i=1298
extrn PASCAL ClipCursor:FAR ; t=2 i=1299
extrn PASCAL CloseSound:FAR ; t=7 i=1300
extrn PASCAL CloseWindow:FAR ; t=0 i=1301
extrn PASCAL CopyRect:FAR ; t=12 i=1302
extrn PASCAL CreateCaret:FAR ; t=19 i=1303
extrn PASCAL DebugBreak:FAR ; t=7 i=1304
extrn PASCAL DestroyCaret:FAR ; t=7 i=1305
extrn PASCAL DirectedYield:FAR ; t=0 i=1306
extrn PASCAL DrawFocusRect:FAR ; t=10 i=1307
extrn PASCAL DrawMenuBar:FAR ; t=0 i=1308
extrn PASCAL EndDialog:FAR ; t=1 i=1309
extrn PASCAL EndPaint:FAR ; t=10 i=1310
extrn PASCAL FatalAppExit:FAR ; t=10 i=1311
extrn PASCAL FatalExit:FAR ; t=0 i=1312
extrn PASCAL FreeLibrary:FAR ; t=0 i=1313
extrn PASCAL GetCaretPos:FAR ; t=2 i=1314
extrn PASCAL GetClientRect:FAR ; t=10 i=1315
extrn PASCAL GetClipCursor:FAR ; t=2 i=1316
extrn PASCAL GetCodeInfo:FAR ; t=120 i=1317
extrn PASCAL GetCursorPos:FAR ; t=2 i=1318
extrn PASCAL GetKeyboardState:FAR ; t=2 i=1319
extrn PASCAL GetScrollRange:FAR ; t=151 i=1320
extrn PASCAL GetWindowRect:FAR ; t=10 i=1321
extrn PASCAL GlobalFix:FAR ; t=0 i=1322
extrn PASCAL GlobalNotify:FAR ; t=5 i=1323
extrn PASCAL HideCaret:FAR ; t=0 i=1324
extrn PASCAL InflateRect:FAR ; t=28 i=1325
extrn PASCAL InvalidateRect:FAR ; t=39 i=1326
extrn PASCAL InvalidateRgn:FAR ; t=16 i=1327
extrn PASCAL InvertRect:FAR ; t=10 i=1328
extrn PASCAL LimitEmsPages:FAR ; t=5 i=1329
extrn PASCAL LineDDA:FAR ; t=193 i=1330
extrn PASCAL LogError:FAR ; t=10 i=1331
extrn PASCAL LogParamError:FAR ; t=143 i=1332
extrn PASCAL MapDialogRect:FAR ; t=10 i=1333
extrn PASCAL MapWindowPoints:FAR ; t=52 i=1334
extrn PASCAL MessageBeep:FAR ; t=0 i=1335
extrn PASCAL OemToAnsi:FAR ; t=12 i=1336
extrn PASCAL OemToAnsiBuff:FAR ; t=53 i=1337
extrn PASCAL OffsetRect:FAR ; t=28 i=1338
extrn PASCAL OutputDebugString:FAR ; t=2 i=1339
extrn PASCAL PlayMetaFileRecord:FAR ; t=66 i=1340
extrn PASCAL PostQuitMessage:FAR ; t=0 i=1341
extrn PASCAL ProfClear:FAR ; t=7 i=1342
extrn PASCAL ProfFinish:FAR ; t=7 i=1343
extrn PASCAL ProfFlush:FAR ; t=7 i=1344
extrn PASCAL ProfSampRate:FAR ; t=1 i=1345
extrn PASCAL ProfSetup:FAR ; t=1 i=1346
extrn PASCAL ProfStart:FAR ; t=7 i=1347
extrn PASCAL ProfStop:FAR ; t=7 i=1348
extrn PASCAL ReleaseCapture:FAR ; t=7 i=1349
extrn PASCAL ReplyMessage:FAR ; t=5 i=1350
extrn PASCAL ScreenToClient:FAR ; t=10 i=1351
extrn PASCAL ScrollWindow:FAR ; t=194 i=1352
extrn PASCAL SetCaretBlinkTime:FAR ; t=0 i=1353
extrn PASCAL SetCaretPos:FAR ; t=1 i=1354
extrn PASCAL SetCursorPos:FAR ; t=1 i=1355
extrn PASCAL SetDlgItemInt:FAR ; t=19 i=1356
extrn PASCAL SetDlgItemText:FAR ; t=59 i=1357
extrn PASCAL SetDoubleClickTime:FAR ; t=0 i=1358
extrn PASCAL SetKeyboardState:FAR ; t=2 i=1359
extrn PASCAL SetRect:FAR ; t=69 i=1360
extrn PASCAL SetRectEmpty:FAR ; t=2 i=1361
extrn PASCAL SetRectRgn:FAR ; t=42 i=1362
extrn PASCAL SetScrollRange:FAR ; t=42 i=1363
extrn PASCAL SetSysColors:FAR ; t=43 i=1364
extrn PASCAL SetWindowText:FAR ; t=10 i=1365
extrn PASCAL ShowCaret:FAR ; t=0 i=1366
extrn PASCAL ShowOwnedPopups:FAR ; t=1 i=1367
extrn PASCAL ShowScrollBar:FAR ; t=16 i=1368
extrn PASCAL SwapRecording:FAR ; t=0 i=1369
extrn PASCAL SwitchStackBack:FAR ; t=7 i=1370
extrn PASCAL SwitchStackTo:FAR ; t=16 i=1371
extrn PASCAL Throw:FAR ; t=4 i=1372
extrn PASCAL UpdateWindow:FAR ; t=0 i=1373
extrn PASCAL ValidateCodeSegments:FAR ; t=7 i=1374
extrn PASCAL ValidateFreeSpaces:FAR ; t=7 i=1375
extrn PASCAL ValidateRect:FAR ; t=10 i=1376
extrn PASCAL ValidateRgn:FAR ; t=1 i=1377
extrn PASCAL WaitMessage:FAR ; t=7 i=1378
extrn PASCAL Yield:FAR ; t=7 i=1379
;      PASCAL _16AdjustWindowRect ; t=102 i=1380
;      PASCAL _16AdjustWindowRectEx ; t=106 i=1381
;      PASCAL _16AnimatePalette ; t=8 i=1382
;      PASCAL _16AnsiToOem ; t=6 i=1383
;      PASCAL _16AnsiToOemBuff ; t=102 i=1384
;      PASCAL _16ClientToScreen ; t=17 i=1385
;      PASCAL _16ClipCursor ; t=5 i=1386
;      PASCAL _16CopyRect ; t=6 i=1387
;      PASCAL _16DrawFocusRect ; t=17 i=1388
;      PASCAL _16EndPaint ; t=17 i=1389
;      PASCAL _16FatalAppExit ; t=17 i=1390
;      PASCAL _16GetCaretPos ; t=5 i=1391
;      PASCAL _16GetClientRect ; t=17 i=1392
;      PASCAL _16GetClipCursor ; t=5 i=1393
;      PASCAL _16GetCodeInfo ; t=6 i=1394
;      PASCAL _16GetCursorPos ; t=5 i=1395
;      PASCAL _16GetKeyboardState ; t=5 i=1396
;      PASCAL _16GetScrollRange ; t=45 i=1397
;      PASCAL _16GetWindowRect ; t=17 i=1398
;      PASCAL _16InflateRect ; t=92 i=1399
;      PASCAL _16InvalidateRect ; t=56 i=1400
;      PASCAL _16InvertRect ; t=17 i=1401
;      PASCAL _16LogError ; t=17 i=1402
;      PASCAL _16LogParamError ; t=18 i=1403
;      PASCAL _16MapDialogRect ; t=17 i=1404
;      PASCAL _16MapWindowPoints ; t=101 i=1405
;      PASCAL _16OemToAnsi ; t=6 i=1406
;      PASCAL _16OemToAnsiBuff ; t=102 i=1407
;      PASCAL _16OffsetRect ; t=92 i=1408
;      PASCAL _16OutputDebugString ; t=5 i=1409
;      PASCAL _16PlayMetaFileRecord ; t=111 i=1410
;      PASCAL _16ScreenToClient ; t=17 i=1411
;      PASCAL _16ScrollWindow ; t=37 i=1412
;      PASCAL _16SetDlgItemText ; t=3 i=1413
;      PASCAL _16SetKeyboardState ; t=5 i=1414
;      PASCAL _16SetRect ; t=112 i=1415
;      PASCAL _16SetRectEmpty ; t=5 i=1416
;      PASCAL _16SetSysColors ; t=18 i=1417
;      PASCAL _16SetWindowText ; t=17 i=1418
;      PASCAL _16Throw ; t=47 i=1419
;      PASCAL _16ValidateRect ; t=17 i=1420
extrn PASCAL FreeProcInstance:FAR ; t=5 i=1421
;      PASCAL _16GlobalNotify ; t=5 i=1422
;      PASCAL _16LineDDA ; t=193 i=1423
extrn PASCAL __WDPMIFreeAlias:FAR ; t=5 i=1424
extrn PASCAL __WDPMIFreeHugeAlias:FAR ; t=6 i=1425
extrn PASCAL _clib_delay:FAR ; t=5 i=1426
extrn PASCAL _clib_intr:FAR ; t=10 i=1427
extrn PASCAL _clib_intrf:FAR ; t=10 i=1428
;extrn PASCAL DragFinish:FAR ; t=0 (shell) i=1429
;extrn PASCAL DragAcceptFiles:FAR ; t=1 (shell) i=1430
;extrn PASCAL AtomicVirtualEvent:FAR ; t=0 (penwin) i=1431
;extrn PASCAL BoundingRectFromPoints:FAR ; t=122 (penwin) i=1432
;extrn PASCAL DrawPenData:FAR ; t=39 (penwin) i=1433
;extrn PASCAL EmulatePen:FAR ; t=0 (penwin) i=1434
;extrn PASCAL FirstSymbolFromGraph:FAR ; t=60 (penwin) i=1435
;extrn PASCAL InitRC:FAR ; t=10 (penwin) i=1436
;extrn PASCAL PenPacket:FAR ; t=7 (penwin) i=1437
;extrn PASCAL PostVirtualKeyEvent:FAR ; t=1 (penwin) i=1438
;extrn PASCAL PostVirtualMouseEvent:FAR ; t=16 (penwin) i=1439
;extrn PASCAL RegisterPenApp:FAR ; t=1 (penwin) i=1440
;extrn PASCAL UninstallRecognizer:FAR ; t=0 (penwin) i=1441
;extrn PASCAL UpdatePenInfo:FAR ; t=2 (penwin) i=1442
;      PASCAL _16BoundingRectFromPoints ; t=153 (penwin) i=1443
;      PASCAL _16DrawPenData ; t=56 (penwin) i=1444
;      PASCAL _16FirstSymbolFromGraph ; t=106 (penwin) i=1445
;      PASCAL _16InitRC ; t=17 (penwin) i=1446
;      PASCAL _16UpdatePenInfo ; t=5 (penwin) i=1447
;extrn PASCAL FreeAllGDIMem:FAR ; t=7 (stress) i=1448
;extrn PASCAL FreeAllMem:FAR ; t=7 (stress) i=1449
;extrn PASCAL FreeAllUserMem:FAR ; t=7 (stress) i=1450
;extrn PASCAL UnAllocDiskSpace:FAR ; t=0 (stress) i=1451
;extrn PASCAL UnAllocFileHandles:FAR ; t=7 (stress) i=1452
;extrn PASCAL LZClose:FAR ; t=0 (lzexpand) i=1453
;extrn PASCAL LZDone:FAR ; t=7 (lzexpand) i=1454
;extrn PASCAL TerminateApp:FAR ; t=1 (toolhelp) i=1455
extrn        GetFirst16Alias:near
extrn        Get16Alias:near
extrn        Free16Alias:near

DGROUP group _DATA

_TEXT segment word public 'CODE' USE16
_TEXT ends

_DATA segment word public 'DATA' USE16
_DATA ends


_DATA segment

public "C", FunctionTable
FunctionTable LABEL DWORD
	dd	AbortDoc
	dd	AccessResource
	dd	AddAtom
	dd	AddFontResource
	dd	AllocDStoCSAlias
	dd	AllocResource
	dd	AllocSelector
	dd	AnsiLower
	dd	AnsiLowerBuff
	dd	__AnsiNext
	dd	__AnsiPrev
	dd	AnsiUpper
	dd	AnsiUpperBuff
	dd	AnyPopup
	dd	__AppendMenu
	dd	Arc
	dd	ArrangeIconicWindows
	dd	BeginDeferWindowPos
	dd	BeginPaint
	dd	BitBlt
	dd	BringWindowToTop
	dd	BuildCommDCB
	dd	CallMsgFilter
	dd	CallNextHookEx
	dd	CallWindowProc
	dd	Catch
	dd	ChangeClipboardChain
	dd	ChangeMenu
	dd	CheckMenuItem
	dd	ChildWindowFromPoint
	dd	Chord
	dd	ClearCommBreak
	dd	CloseClipboard
	dd	CloseComm
	dd	CloseDriver
	dd	CloseMetaFile
	dd	CombineRgn
	dd	ConvertOutlineFontFile
	dd	CopyCursor
	dd	CopyIcon
	dd	CopyMetaFile
	dd	CountClipboardFormats
	dd	CountVoiceNotes
	dd	__CreateBitmap
	dd	__CreateBitmapIndirect
	dd	CreateBrushIndirect
	dd	CreateCompatibleBitmap
	dd	CreateCompatibleDC
	dd	CreateCursor
	dd	CreateDC
	dd	CreateDialog
	dd	CreateDialogIndirect
	dd	CreateDialogIndirectParam
	dd	CreateDialogParam
	dd	__CreateDIBitmap
	dd	CreateDIBPatternBrush
	dd	CreateDiscardableBitmap
	dd	CreateEllipticRgn
	dd	CreateEllipticRgnIndirect
	dd	CreateFont
	dd	CreateFontIndirect
	dd	CreateHatchBrush
	dd	CreateIC
	dd	CreateIcon
	dd	CreateMenu
	dd	CreateMetaFile
	dd	CreatePalette
	dd	CreatePatternBrush
	dd	CreatePen
	dd	CreatePenIndirect
	dd	CreatePolygonRgn
	dd	CreatePolyPolygonRgn
	dd	CreatePopupMenu
	dd	CreateRectRgn
	dd	CreateRectRgnIndirect
	dd	CreateRoundRectRgn
	dd	CreateScalableFontResource
	dd	CreateSolidBrush
	dd	CreateWindow
	dd	CreateWindowEx
	dd	DefDlgProc
	dd	DefDriverProc
	dd	DeferWindowPos
	dd	DefFrameProc
	dd	DefHookProc
	dd	DefMDIChildProc
	dd	DefWindowProc
	dd	DeleteAtom
	dd	DeleteDC
	dd	DeleteMenu
	dd	DeleteMetaFile
	dd	DeleteObject
	dd	DestroyCursor
	dd	DestroyIcon
	dd	DestroyMenu
	dd	DestroyWindow
	dd	DialogBox
	dd	DialogBoxIndirect
	dd	DialogBoxIndirectParam
	dd	DialogBoxParam
	dd	DispatchMessage
	dd	DlgDirList
	dd	DlgDirListComboBox
	dd	DlgDirSelect
	dd	DlgDirSelectComboBox
	dd	DlgDirSelectComboBoxEx
	dd	DlgDirSelectEx
	dd	DPtoLP
	dd	DrawIcon
	dd	DrawText
	dd	Ellipse
	dd	EmptyClipboard
	dd	EnableCommNotification
	dd	EnableHardwareInput
	dd	EnableMenuItem
	dd	EnableScrollBar
	dd	EnableWindow
	dd	EndDeferWindowPos
	dd	EndDoc
	dd	EndPage
	dd	EngineMakeFontDir
	dd	EnumChildWindows
	dd	EnumClipboardFormats
	dd	EnumFontFamilies
	dd	EnumFonts
	dd	EnumMetaFile
	dd	EnumObjects
	dd	EnumProps
	dd	EnumTaskWindows
	dd	EnumWindows
	dd	EqualRect
	dd	EqualRgn
	dd	__Escape
	dd	EscapeCommFunction
	dd	ExcludeClipRect
	dd	ExcludeUpdateRgn
	dd	ExitWindows
	dd	ExitWindowsExec
	dd	ExtFloodFill
	dd	ExtTextOut
	dd	FillRect
	dd	FillRgn
	dd	FindAtom
	dd	FindResource
	dd	FindWindow
	dd	FlashWindow
	dd	FloodFill
	dd	FlushComm
	dd	FrameRect
	dd	FrameRgn
	dd	FreeModule
	dd	FreeResource
	dd	FreeSelector
	dd	GetActiveWindow
	dd	GetAspectRatioFilter
	dd	GetAspectRatioFilterEx
	dd	GetAsyncKeyState
	dd	GetAtomHandle
	dd	GetAtomName
	dd	__GetBitmapBits
	dd	GetBitmapDimension
	dd	GetBitmapDimensionEx
	dd	GetBkColor
	dd	GetBkMode
	dd	GetBoundsRect
	dd	GetBrushOrg
	dd	GetBrushOrgEx
	dd	GetCapture
	dd	GetCaretBlinkTime
	dd	GetCharABCWidths
	dd	GetCharWidth
	dd	GetClassInfo
	dd	GetClassLong
	dd	GetClassName
	dd	GetClassWord
	dd	GetClipboardData
	dd	GetClipboardFormatName
	dd	GetClipboardOwner
	dd	GetClipboardViewer
	dd	GetClipBox
	dd	GetCodeHandle
	dd	GetCommError
	dd	GetCommEventMask
	dd	GetCommState
	dd	GetCurrentPDB
	dd	GetCurrentPosition
	dd	GetCurrentPositionEx
	dd	GetCurrentTask
	dd	GetCurrentTime
	dd	GetCursor
	dd	GetDC
	dd	GetDCEx
	dd	GetDCOrg
	dd	GetDesktopWindow
	dd	GetDeviceCaps
	dd	GetDialogBaseUnits
	dd	__GetDIBits
	dd	GetDlgCtrlID
	dd	GetDlgItem
	dd	GetDlgItemInt
	dd	GetDlgItemText
	dd	GetDOSEnvironment
	dd	GetDoubleClickTime
	dd	GetDriverInfo
	dd	GetDriverModuleHandle
	dd	GetDriveType
	dd	GetEnvironment
	dd	GetFocus
	dd	GetFontData
	dd	GetFreeSpace
	dd	GetFreeSystemResources
	dd	GetGlyphOutline
	dd	GetInputState
	dd	__GetInstanceData
	dd	GetKBCodePage
	dd	GetKeyboardType
	dd	GetKeyNameText
	dd	GetKeyState
	dd	GetLastActivePopup
	dd	GetMapMode
	dd	GetMenu
	dd	GetMenuCheckMarkDimensions
	dd	GetMenuItemCount
	dd	GetMenuItemID
	dd	GetMenuState
	dd	GetMenuString
	dd	__GetMessage
	dd	GetMessageExtraInfo
	dd	GetMessagePos
	dd	GetMessageTime
	dd	GetMetaFile
	dd	GetMetaFileBits
	dd	GetModuleFileName
	dd	GetModuleHandle
	dd	GetModuleUsage
	dd	GetNearestColor
	dd	GetNearestPaletteIndex
	dd	GetNextDlgGroupItem
	dd	GetNextDlgTabItem
	dd	GetNextDriver
	dd	GetNextWindow
	dd	GetNumTasks
	dd	GetObject
	dd	GetOpenClipboardWindow
	dd	GetOutlineTextMetrics
	dd	GetPaletteEntries
	dd	GetParent
	dd	GetPixel
	dd	GetPolyFillMode
	dd	GetPriorityClipboardFormat
	dd	GetPrivateProfileInt
	dd	GetPrivateProfileString
	dd	GetProcAddress
	dd	GetProfileInt
	dd	GetProfileString
	dd	GetProp
	dd	GetQueueStatus
	dd	GetRasterizerCaps
	dd	GetRgnBox
	dd	GetROP2
	dd	GetScrollPos
	dd	GetSelectorBase
	dd	GetSelectorLimit
	dd	GetStockObject
	dd	GetStretchBltMode
	dd	GetSubMenu
	dd	GetSysColor
	dd	GetSysModalWindow
	dd	GetSystemDebugState
	dd	GetSystemDirectory
	dd	GetSystemMenu
	dd	GetSystemMetrics
	dd	GetSystemPaletteEntries
	dd	GetSystemPaletteUse
	dd	GetTabbedTextExtent
	dd	GetTempDrive
	dd	GetTempFileName
	dd	GetTextAlign
	dd	GetTextCharacterExtra
	dd	GetTextColor
	dd	GetTextExtent
	dd	GetTextExtentPoint
	dd	GetTextFace
	dd	GetTextMetrics
	dd	GetThresholdEvent
	dd	GetThresholdStatus
	dd	GetTickCount
	dd	GetTimerResolution
	dd	GetTopWindow
	dd	GetUpdateRect
	dd	GetUpdateRgn
	dd	GetVersion
	dd	GetViewportExt
	dd	GetViewportExtEx
	dd	GetViewportOrg
	dd	GetViewportOrgEx
	dd	GetWindow
	dd	GetWindowDC
	dd	GetWindowExt
	dd	GetWindowExtEx
	dd	GetWindowLong
	dd	GetWindowOrg
	dd	GetWindowOrgEx
	dd	GetWindowPlacement
	dd	GetWindowsDirectory
	dd	GetWindowTask
	dd	GetWindowText
	dd	GetWindowTextLength
	dd	GetWindowWord
	dd	GetWinFlags
	dd	GlobalAddAtom
	dd	GlobalAlloc
	dd	GlobalCompact
	dd	GlobalDeleteAtom
	dd	GlobalDosAlloc
	dd	GlobalDosFree
	dd	GlobalFindAtom
	dd	GlobalFlags
	dd	GlobalFree
	dd	GlobalGetAtomName
	dd	GlobalHandle
	dd	GlobalLock
	dd	GlobalLRUNewest
	dd	GlobalLRUOldest
	dd	GlobalPageLock
	dd	GlobalPageUnlock
	dd	GlobalReAlloc
	dd	GlobalSize
	dd	GlobalUnfix
	dd	GlobalUnlock
	dd	GlobalUnWire
	dd	GlobalWire
	dd	GrayString
	dd	HiliteMenuItem
	dd	InitAtomTable
	dd	InSendMessage
	dd	__InsertMenu
	dd	IntersectClipRect
	dd	IntersectRect
	dd	InvertRgn
	dd	IsBadCodePtr
	dd	IsBadHugeReadPtr
	dd	IsBadHugeWritePtr
	dd	IsBadReadPtr
	dd	IsBadStringPtr
	dd	IsBadWritePtr
	dd	IsCharAlpha
	dd	IsCharAlphaNumeric
	dd	IsCharLower
	dd	IsCharUpper
	dd	IsChild
	dd	IsClipboardFormatAvailable
	dd	IsDBCSLeadByte
	dd	IsDialogMessage
	dd	IsDlgButtonChecked
	dd	IsGDIObject
	dd	IsIconic
	dd	IsMenu
	dd	IsRectEmpty
	dd	IsTask
	dd	IsWindow
	dd	IsWindowEnabled
	dd	IsWindowVisible
	dd	IsZoomed
	dd	KillTimer
	dd	LineTo
	dd	LoadAccelerators
	dd	LoadBitmap
	dd	LoadCursor
	dd	LoadIcon
	dd	LoadLibrary
	dd	LoadMenu
	dd	LoadMenuIndirect
	dd	LoadModule
	dd	LoadResource
	dd	LoadString
	dd	LocalAlloc
	dd	LocalCompact
	dd	LocalFlags
	dd	LocalFree
	dd	LocalHandle
	dd	LocalInit
	dd	LocalLock
	dd	LocalReAlloc
	dd	LocalShrink
	dd	LocalSize
	dd	LocalUnlock
	dd	LockInput
	dd	LockResource
	dd	LockSegment
	dd	LockWindowUpdate
	dd	LPtoDP
	dd	lstrcat
	dd	lstrcmp
	dd	lstrcmpi
	dd	lstrcpy
	dd	lstrlen
	dd	MakeProcInstance
	dd	MapVirtualKey
	dd	MessageBox
	dd	__ModifyMenu
	dd	MoveTo
	dd	MoveToEx
	dd	MoveWindow
	dd	MulDiv
	dd	OemKeyScan
	dd	OffsetClipRgn
	dd	OffsetRgn
	dd	OffsetViewportOrg
	dd	OffsetViewportOrgEx
	dd	OffsetWindowOrg
	dd	OffsetWindowOrgEx
	dd	OpenClipboard
	dd	OpenComm
	dd	OpenDriver
	dd	OpenFile
	dd	OpenIcon
	dd	OpenSound
	dd	PaintRgn
	dd	PatBlt
	dd	__PeekMessage
	dd	Pie
	dd	PlayMetaFile
	dd	Polygon
	dd	Polyline
	dd	PolyPolygon
	dd	PostAppMessage
	dd	PostMessage
	dd	ProfInsChk
	dd	PtInRect
	dd	PtInRegion
	dd	PtVisible
	dd	QueryAbort
	dd	QueryJob
	dd	QuerySendMessage
	dd	ReadComm
	dd	RealizePalette
	dd	Rectangle
	dd	RectInRegion
	dd	RectVisible
	dd	RedrawWindow
	dd	RegisterClass
	dd	RegisterClipboardFormat
	dd	RegisterWindowMessage
	dd	ReleaseDC
	dd	RemoveFontResource
	dd	RemoveMenu
	dd	RemoveProp
	dd	ResizePalette
	dd	RestoreDC
	dd	RoundRect
	dd	SaveDC
	dd	ScaleViewportExt
	dd	ScaleViewportExtEx
	dd	ScaleWindowExt
	dd	ScaleWindowExtEx
	dd	ScrollDC
	dd	ScrollWindowEx
	dd	SelectClipRgn
	dd	SelectObject
	dd	SelectPalette
	dd	SendDlgItemMessage
	dd	SendDriverMessage
	dd	SendMessage
	dd	SetAbortProc
	dd	SetActiveWindow
	dd	__SetBitmapBits
	dd	SetBitmapDimension
	dd	SetBitmapDimensionEx
	dd	SetBkColor
	dd	SetBkMode
	dd	SetBoundsRect
	dd	SetBrushOrg
	dd	SetCapture
	dd	SetClassLong
	dd	SetClassWord
	dd	SetClipboardData
	dd	SetClipboardViewer
	dd	SetCommBreak
	dd	SetCommEventMask
	dd	SetCommState
	dd	SetCursor
	dd	__SetDIBits
	dd	__SetDIBitsToDevice
	dd	SetEnvironment
	dd	SetErrorMode
	dd	SetFocus
	dd	SetHandleCount
	dd	SetMapMode
	dd	SetMapperFlags
	dd	SetMenu
	dd	SetMenuItemBitmaps
	dd	SetMessageQueue
	dd	SetMetaFileBits
	dd	SetMetaFileBitsBetter
	dd	SetPaletteEntries
	dd	SetParent
	dd	SetPixel
	dd	SetPolyFillMode
	dd	SetProp
	dd	SetResourceHandler
	dd	SetROP2
	dd	SetScrollPos
	dd	SetSelectorBase
	dd	SetSelectorLimit
	dd	SetSoundNoise
	dd	SetStretchBltMode
	dd	SetSwapAreaSize
	dd	SetSysModalWindow
	dd	SetSystemPaletteUse
	dd	SetTextAlign
	dd	SetTextCharacterExtra
	dd	SetTextColor
	dd	SetTextJustification
	dd	SetTimer
	dd	SetViewportExt
	dd	SetViewportExtEx
	dd	SetViewportOrg
	dd	SetViewportOrgEx
	dd	SetVoiceAccent
	dd	SetVoiceEnvelope
	dd	SetVoiceNote
	dd	SetVoiceQueueSize
	dd	SetVoiceSound
	dd	SetVoiceThreshold
	dd	SetWindowExt
	dd	SetWindowExtEx
	dd	SetWindowLong
	dd	SetWindowOrg
	dd	SetWindowOrgEx
	dd	SetWindowPlacement
	dd	SetWindowPos
	dd	SetWindowsHook
	dd	SetWindowsHookEx
	dd	SetWindowWord
	dd	ShowCursor
	dd	ShowWindow
	dd	SizeofResource
	dd	SpoolFile
	dd	__StartDoc
	dd	StartPage
	dd	StartSound
	dd	StopSound
	dd	StretchBlt
	dd	__StretchDIBits
	dd	SubtractRect
	dd	SwapMouseButton
	dd	SyncAllVoices
	dd	SystemParametersInfo
	dd	TabbedTextOut
	dd	TextOut
	dd	ToAscii
	dd	TrackPopupMenu
	dd	TranslateAccelerator
	dd	TranslateMDISysAccel
	dd	TranslateMessage
	dd	TransmitCommChar
	dd	UngetCommChar
	dd	UnhookWindowsHook
	dd	UnhookWindowsHookEx
	dd	UnionRect
	dd	UnlockSegment
	dd	UnrealizeObject
	dd	UnregisterClass
	dd	UpdateColors
	dd	VkKeyScan
	dd	WaitSoundState
	dd	WindowFromPoint
	dd	WinExec
	dd	__WinHelp
	dd	WNetAddConnection
	dd	WNetCancelConnection
	dd	WNetGetConnection
	dd	WriteComm
	dd	WritePrivateProfileString
	dd	WriteProfileString
	dd	wvsprintf
	dd	_lclose
	dd	_lcreat
	dd	_llseek
	dd	_lopen
	dd	_lread
	dd	_lwrite
	dd	GetKerningPairs
	dd	CreateBitmap
	dd	CreateBitmapIndirect
	dd	CreateDIBitmap
	dd	Escape
	dd	GetBitmapBits
	dd	GetDIBits
	dd	GetMessage
	dd	PeekMessage
	dd	SetBitmapBits
	dd	SetDIBits
	dd	SetDIBitsToDevice
	dd	StartDoc
	dd	StretchDIBits
	dd	WinHelp
	dd	__WDPMIGetAlias
	dd	__WDPMIGetHugeAlias
	dd	__WDPMIAlloc
	dd	__WDPMIFree
	dd	__WDPMIAliasToFlat
	dd	_clib_bios_disk
	dd	_clib_bios_equiplist
	dd	_clib_bios_keybrd
	dd	_clib_bios_memsize
	dd	_clib_bios_printer
	dd	_clib_bios_serialcom
	dd	_clib_bios_timeofday
	dd	_clib_clock
	dd	_clib_dos_findfirst
	dd	_clib_dos_findnext
	dd	_clib_errno
	dd	_clib_int86
	dd	_clib_int86x
	dd	_clib_intdos
	dd	_clib_intdosx
	dd	__DLLPatch ; (ddeml) DdeAbandonTransaction
	dd	__DLLPatch ; (ddeml) DdeAccessData
	dd	__DLLPatch ; (ddeml) DdeAddData
	dd	__DLLPatch ; (ddeml) DdeClientTransaction
	dd	__DLLPatch ; (ddeml) DdeCmpStringHandles
	dd	__DLLPatch ; (ddeml) DdeConnect
	dd	__DLLPatch ; (ddeml) DdeConnectList
	dd	__DLLPatch ; (ddeml) DdeCreateDataHandle
	dd	__DLLPatch ; (ddeml) DdeCreateStringHandle
	dd	__DLLPatch ; (ddeml) DdeDisconnect
	dd	__DLLPatch ; (ddeml) DdeDisconnectList
	dd	__DLLPatch ; (ddeml) DdeEnableCallback
	dd	__DLLPatch ; (ddeml) DdeFreeDataHandle
	dd	__DLLPatch ; (ddeml) DdeFreeStringHandle
	dd	__DLLPatch ; (ddeml) DdeGetData
	dd	__DLLPatch ; (ddeml) DdeGetLastError
	dd	__DLLPatch ; (ddeml) DdeInitialize
	dd	__DLLPatch ; (ddeml) DdeKeepStringHandle
	dd	__DLLPatch ; (ddeml) DdeNameService
	dd	__DLLPatch ; (ddeml) DdePostAdvise
	dd	__DLLPatch ; (ddeml) DdeQueryConvInfo
	dd	__DLLPatch ; (ddeml) DdeQueryNextServer
	dd	__DLLPatch ; (ddeml) DdeQueryString
	dd	__DLLPatch ; (ddeml) DdeReconnect
	dd	__DLLPatch ; (ddeml) DdeSetUserHandle
	dd	__DLLPatch ; (ddeml) DdeUnaccessData
	dd	__DLLPatch ; (ddeml) DdeUninitialize
	dd	__DLLPatch ; (commdlg) ChooseColor
	dd	__DLLPatch ; (commdlg) ChooseFont
	dd	__DLLPatch ; (commdlg) FindText
	dd	__DLLPatch ; (commdlg) GetFileTitle
	dd	__DLLPatch ; (commdlg) GetOpenFileName
	dd	__DLLPatch ; (commdlg) GetSaveFileName
	dd	__DLLPatch ; (commdlg) PrintDlg
	dd	__DLLPatch ; (commdlg) ReplaceText
	dd	__DLLPatch ; (commdlg) CommDlgExtendedError
	dd	__DLLPatch ; (shell) RegOpenKey
	dd	__DLLPatch ; (shell) RegCreateKey
	dd	__DLLPatch ; (shell) RegCloseKey
	dd	__DLLPatch ; (shell) RegDeleteKey
	dd	__DLLPatch ; (shell) RegSetValue
	dd	__DLLPatch ; (shell) RegQueryValue
	dd	__DLLPatch ; (shell) RegEnumKey
	dd	__DLLPatch ; (shell) DragQueryFile
	dd	__DLLPatch ; (shell) DragQueryPoint
	dd	__DLLPatch ; (shell) ExtractIcon
	dd	__DLLPatch ; (shell) ShellExecute
	dd	__DLLPatch ; (shell) FindExecutable
	dd	__DLLPatch ; (penwin) AddPointsPenData
	dd	__DLLPatch ; (penwin) BeginEnumStrokes
	dd	__DLLPatch ; (penwin) CharacterToSymbol
	dd	__DLLPatch ; (penwin) CompactPenData
	dd	__DLLPatch ; (penwin) CorrectWriting
	dd	__DLLPatch ; (penwin) CreatePenData
	dd	__DLLPatch ; (penwin) DictionarySearch
	dd	__DLLPatch ; (penwin) DPtoTP
	dd	__DLLPatch ; (penwin) DuplicatePenData
	dd	__DLLPatch ; (penwin) EndPenCollection
	dd	__DLLPatch ; (penwin) EnumSymbols
	dd	__DLLPatch ; (penwin) ExecuteGesture
	dd	__DLLPatch ; (penwin) GetGlobalRC
	dd	__DLLPatch ; (penwin) GetPenAsyncState
	dd	__DLLPatch ; (penwin) GetPenDataInfo
	dd	__DLLPatch ; (penwin) GetPenDataStroke
	dd	__DLLPatch ; (penwin) GetPenHwData
	dd	__DLLPatch ; (penwin) GetPenHwEventData
	dd	__DLLPatch ; (penwin) GetPointsFromPenData
	dd	__DLLPatch ; (penwin) GetSymbolCount
	dd	__DLLPatch ; (penwin) GetSymbolMaxLength
	dd	__DLLPatch ; (penwin) GetVersionPenWin
	dd	__DLLPatch ; (penwin) InstallRecognizer
	dd	__DLLPatch ; (penwin) IsPenAware
	dd	__DLLPatch ; (penwin) IsPenEvent
	dd	__DLLPatch ; (penwin) MetricScalePenData
	dd	__DLLPatch ; (penwin) OffsetPenData
	dd	__DLLPatch ; (penwin) ProcessWriting
	dd	__DLLPatch ; (penwin) Recognize
	dd	__DLLPatch ; (penwin) RecognizeData
	dd	__DLLPatch ; (penwin) RedisplayPenData
	dd	__DLLPatch ; (penwin) ResizePenData
	dd	__DLLPatch ; (penwin) SetGlobalRC
	dd	__DLLPatch ; (penwin) SetPenHook
	dd	__DLLPatch ; (penwin) SetRecogHook
	dd	__DLLPatch ; (penwin) ShowKeyboard
	dd	__DLLPatch ; (penwin) SymbolToCharacter
	dd	__DLLPatch ; (penwin) TPtoDP
	dd	__DLLPatch ; (penwin) TrainContext
	dd	__DLLPatch ; (penwin) TrainInk
	dd	__DLLPatch ; (ver) GetFileResource
	dd	__DLLPatch ; (ver) GetFileResourceSize
	dd	__DLLPatch ; (ver) GetFileVersionInfo
	dd	__DLLPatch ; (ver) GetFileVersionInfoSize
	dd	__DLLPatch ; (ver) GetSystemDir
	dd	__DLLPatch ; (ver) GetWindowsDir
	dd	__DLLPatch ; (ver) VerFindFile
	dd	__DLLPatch ; (ver) VerInstallFile
	dd	__DLLPatch ; (ver) VerLanguageName
	dd	__DLLPatch ; (ver) VerQueryValue
	dd	__DLLPatch ; (stress) AllocDiskSpace
	dd	__DLLPatch ; (stress) AllocFileHandles
	dd	__DLLPatch ; (stress) AllocGDIMem
	dd	__DLLPatch ; (stress) AllocMem
	dd	__DLLPatch ; (stress) AllocUserMem
	dd	__DLLPatch ; (stress) GetFreeFileHandles
	dd	__DLLPatch ; (lzexpand) CopyLZFile
	dd	__DLLPatch ; (lzexpand) GetExpandedName
	dd	__DLLPatch ; (lzexpand) LZCopy
	dd	__DLLPatch ; (lzexpand) LZInit
	dd	__DLLPatch ; (lzexpand) LZOpenFile
	dd	__DLLPatch ; (lzexpand) LZRead
	dd	__DLLPatch ; (lzexpand) LZSeek
	dd	__DLLPatch ; (lzexpand) LZStart
	dd	__DLLPatch ; (mmsystem) auxGetDevCaps
	dd	__DLLPatch ; (mmsystem) auxGetNumDevs
	dd	__DLLPatch ; (mmsystem) auxGetVolume
	dd	__DLLPatch ; (mmsystem) auxOutMessage
	dd	__DLLPatch ; (mmsystem) auxSetVolume
	dd	__DLLPatch ; (mmsystem) joyGetDevCaps
	dd	__DLLPatch ; (mmsystem) joyGetNumDevs
	dd	__DLLPatch ; (mmsystem) joyGetPos
	dd	__DLLPatch ; (mmsystem) joyGetThreshold
	dd	__DLLPatch ; (mmsystem) joyReleaseCapture
	dd	__DLLPatch ; (mmsystem) joySetCapture
	dd	__DLLPatch ; (mmsystem) joySetThreshold
	dd	__DLLPatch ; (mmsystem) mciGetCreatorTask
	dd	__DLLPatch ; (mmsystem) mciGetDeviceID
	dd	__DLLPatch ; (mmsystem) mciGetDeviceIDFromElementID
	dd	__DLLPatch ; (mmsystem) mciGetErrorString
	dd	__DLLPatch ; (mmsystem) mciGetYieldProc
	dd	__DLLPatch ; (mmsystem) mciSendCommand
	dd	__DLLPatch ; (mmsystem) mciSendString
	dd	__DLLPatch ; (mmsystem) mciSetYieldProc
	dd	__DLLPatch ; (mmsystem) midiInAddBuffer
	dd	__DLLPatch ; (mmsystem) midiInClose
	dd	__DLLPatch ; (mmsystem) midiInGetDevCaps
	dd	__DLLPatch ; (mmsystem) midiInGetErrorText
	dd	__DLLPatch ; (mmsystem) midiInGetID
	dd	__DLLPatch ; (mmsystem) midiInGetNumDevs
	dd	__DLLPatch ; (mmsystem) midiInMessage
	dd	__DLLPatch ; (mmsystem) midiInOpen
	dd	__DLLPatch ; (mmsystem) midiInPrepareHeader
	dd	__DLLPatch ; (mmsystem) midiInReset
	dd	__DLLPatch ; (mmsystem) midiInStart
	dd	__DLLPatch ; (mmsystem) midiInStop
	dd	__DLLPatch ; (mmsystem) midiInUnprepareHeader
	dd	__DLLPatch ; (mmsystem) midiOutCacheDrumPatches
	dd	__DLLPatch ; (mmsystem) midiOutCachePatches
	dd	__DLLPatch ; (mmsystem) midiOutClose
	dd	__DLLPatch ; (mmsystem) midiOutGetDevCaps
	dd	__DLLPatch ; (mmsystem) midiOutGetErrorText
	dd	__DLLPatch ; (mmsystem) midiOutGetID
	dd	__DLLPatch ; (mmsystem) midiOutGetNumDevs
	dd	__DLLPatch ; (mmsystem) midiOutGetVolume
	dd	__DLLPatch ; (mmsystem) midiOutLongMsg
	dd	__DLLPatch ; (mmsystem) midiOutMessage
	dd	__DLLPatch ; (mmsystem) midiOutOpen
	dd	__DLLPatch ; (mmsystem) midiOutPrepareHeader
	dd	__DLLPatch ; (mmsystem) midiOutReset
	dd	__DLLPatch ; (mmsystem) midiOutSetVolume
	dd	__DLLPatch ; (mmsystem) midiOutShortMsg
	dd	__DLLPatch ; (mmsystem) midiOutUnprepareHeader
	dd	__DLLPatch ; (mmsystem) mmioAdvance
	dd	__DLLPatch ; (mmsystem) mmioAscend
	dd	__DLLPatch ; (mmsystem) mmioClose
	dd	__DLLPatch ; (mmsystem) mmioCreateChunk
	dd	__DLLPatch ; (mmsystem) mmioDescend
	dd	__DLLPatch ; (mmsystem) mmioFlush
	dd	__DLLPatch ; (mmsystem) mmioGetInfo
	dd	__DLLPatch ; (mmsystem) mmioInstallIOProc
	dd	__DLLPatch ; (mmsystem) mmioOpen
	dd	__DLLPatch ; (mmsystem) mmioRead
	dd	__DLLPatch ; (mmsystem) mmioRename
	dd	__DLLPatch ; (mmsystem) mmioSeek
	dd	__DLLPatch ; (mmsystem) mmioSendMessage
	dd	__DLLPatch ; (mmsystem) mmioSetBuffer
	dd	__DLLPatch ; (mmsystem) mmioSetInfo
	dd	__DLLPatch ; (mmsystem) mmioStringToFOURCC
	dd	__DLLPatch ; (mmsystem) mmioWrite
	dd	__DLLPatch ; (mmsystem) mmsystemGetVersion
	dd	__DLLPatch ; (mmsystem) sndPlaySound
	dd	__DLLPatch ; (mmsystem) timeBeginPeriod
	dd	__DLLPatch ; (mmsystem) timeEndPeriod
	dd	__DLLPatch ; (mmsystem) timeGetDevCaps
	dd	__DLLPatch ; (mmsystem) timeGetSystemTime
	dd	__DLLPatch ; (mmsystem) timeGetTime
	dd	__DLLPatch ; (mmsystem) timeKillEvent
	dd	__DLLPatch ; (mmsystem) timeSetEvent
	dd	__DLLPatch ; (mmsystem) waveInAddBuffer
	dd	__DLLPatch ; (mmsystem) waveInClose
	dd	__DLLPatch ; (mmsystem) waveInGetDevCaps
	dd	__DLLPatch ; (mmsystem) waveInGetErrorText
	dd	__DLLPatch ; (mmsystem) waveInGetID
	dd	__DLLPatch ; (mmsystem) waveInGetNumDevs
	dd	__DLLPatch ; (mmsystem) waveInGetPosition
	dd	__DLLPatch ; (mmsystem) waveInMessage
	dd	__DLLPatch ; (mmsystem) waveInOpen
	dd	__DLLPatch ; (mmsystem) waveInPrepareHeader
	dd	__DLLPatch ; (mmsystem) waveInReset
	dd	__DLLPatch ; (mmsystem) waveInStart
	dd	__DLLPatch ; (mmsystem) waveInStop
	dd	__DLLPatch ; (mmsystem) waveInUnprepareHeader
	dd	__DLLPatch ; (mmsystem) waveOutBreakLoop
	dd	__DLLPatch ; (mmsystem) waveOutClose
	dd	__DLLPatch ; (mmsystem) waveOutGetDevCaps
	dd	__DLLPatch ; (mmsystem) waveOutGetErrorText
	dd	__DLLPatch ; (mmsystem) waveOutGetID
	dd	__DLLPatch ; (mmsystem) waveOutGetNumDevs
	dd	__DLLPatch ; (mmsystem) waveOutGetPitch
	dd	__DLLPatch ; (mmsystem) waveOutGetPlaybackRate
	dd	__DLLPatch ; (mmsystem) waveOutGetPosition
	dd	__DLLPatch ; (mmsystem) waveOutGetVolume
	dd	__DLLPatch ; (mmsystem) waveOutMessage
	dd	__DLLPatch ; (mmsystem) waveOutOpen
	dd	__DLLPatch ; (mmsystem) waveOutPause
	dd	__DLLPatch ; (mmsystem) waveOutPrepareHeader
	dd	__DLLPatch ; (mmsystem) waveOutReset
	dd	__DLLPatch ; (mmsystem) waveOutRestart
	dd	__DLLPatch ; (mmsystem) waveOutSetPitch
	dd	__DLLPatch ; (mmsystem) waveOutSetPlaybackRate
	dd	__DLLPatch ; (mmsystem) waveOutSetVolume
	dd	__DLLPatch ; (mmsystem) waveOutUnprepareHeader
	dd	__DLLPatch ; (mmsystem) waveOutWrite
	dd	__DLLPatch ; (toolhelp) ClassFirst
	dd	__DLLPatch ; (toolhelp) ClassNext
	dd	__DLLPatch ; (toolhelp) GlobalEntryHandle
	dd	__DLLPatch ; (toolhelp) GlobalEntryModule
	dd	__DLLPatch ; (toolhelp) GlobalFirst
	dd	__DLLPatch ; (toolhelp) GlobalHandleToSel
	dd	__DLLPatch ; (toolhelp) GlobalInfo
	dd	__DLLPatch ; (toolhelp) GlobalNext
	dd	__DLLPatch ; (toolhelp) LocalFirst
	dd	__DLLPatch ; (toolhelp) LocalInfo
	dd	__DLLPatch ; (toolhelp) LocalNext
	dd	__DLLPatch ; (toolhelp) MemManInfo
	dd	__MemoryRead
	dd	__MemoryWrite
	dd	__DLLPatch ; (toolhelp) ModuleFindHandle
	dd	__DLLPatch ; (toolhelp) ModuleFindName
	dd	__DLLPatch ; (toolhelp) ModuleFirst
	dd	__DLLPatch ; (toolhelp) ModuleNext
	dd	__DLLPatch ; (toolhelp) NotifyRegister
	dd	__DLLPatch ; (toolhelp) NotifyUnRegister
	dd	__DLLPatch ; (toolhelp) StackTraceCSIPFirst
	dd	__DLLPatch ; (toolhelp) StackTraceFirst
	dd	__DLLPatch ; (toolhelp) StackTraceNext
	dd	__DLLPatch ; (toolhelp) SystemHeapInfo
	dd	__DLLPatch ; (toolhelp) TaskFindHandle
	dd	__DLLPatch ; (toolhelp) TaskFirst
	dd	__DLLPatch ; (toolhelp) TaskGetCSIP
	dd	__DLLPatch ; (toolhelp) TaskNext
	dd	__DLLPatch ; (toolhelp) TaskSetCSIP
	dd	__DLLPatch ; (toolhelp) TaskSwitch
	dd	__DLLPatch ; (toolhelp) TimerCount
	dd	__DLLPatch ; (toolhelp) MemoryRead
	dd	__DLLPatch ; (toolhelp) MemoryWrite
	dd	__DLLPatch ; (odbc) SQLAllocConnect
	dd	__DLLPatch ; (odbc) SQLAllocEnv
	dd	__DLLPatch ; (odbc) SQLAllocStmt
	dd	__DLLPatch ; (odbc) SQLBindCol
	dd	__DLLPatch ; (odbc) SQLBrowseConnect
	dd	__DLLPatch ; (odbc) SQLCancel
	dd	__DLLPatch ; (odbc) SQLColAttributes
	dd	__DLLPatch ; (odbc) SQLColumnPrivileges
	dd	__DLLPatch ; (odbc) SQLColumns
	dd	__DLLPatch ; (odbc) SQLConnect
	dd	__DLLPatch ; (odbc) SQLDataSources
	dd	__DLLPatch ; (odbc) SQLDescribeCol
	dd	__DLLPatch ; (odbc) SQLDescribeParam
	dd	__DLLPatch ; (odbc) SQLDisconnect
	dd	__DLLPatch ; (odbc) SQLDriverConnect
	dd	__DLLPatch ; (odbc) SQLError
	dd	__DLLPatch ; (odbc) SQLExecDirect
	dd	__DLLPatch ; (odbc) SQLExecute
	dd	__DLLPatch ; (odbc) SQLExtendedFetch
	dd	__DLLPatch ; (odbc) SQLFetch
	dd	__DLLPatch ; (odbc) SQLForeignKeys
	dd	__DLLPatch ; (odbc) SQLFreeConnect
	dd	__DLLPatch ; (odbc) SQLFreeEnv
	dd	__DLLPatch ; (odbc) SQLFreeStmt
	dd	__DLLPatch ; (odbc) SQLGetConnectOption
	dd	__DLLPatch ; (odbc) SQLGetCursorName
	dd	__DLLPatch ; (odbc) SQLGetData
	dd	__DLLPatch ; (odbc) SQLGetFunctions
	dd	__DLLPatch ; (odbc) SQLGetInfo
	dd	__DLLPatch ; (odbc) SQLGetStmtOption
	dd	__DLLPatch ; (odbc) SQLGetTypeInfo
	dd	__DLLPatch ; (odbc) SQLMoreResults
	dd	__DLLPatch ; (odbc) SQLNativeSql
	dd	__DLLPatch ; (odbc) SQLNumParams
	dd	__DLLPatch ; (odbc) SQLNumResultCols
	dd	__DLLPatch ; (odbc) SQLParamData
	dd	__DLLPatch ; (odbc) SQLParamOptions
	dd	__DLLPatch ; (odbc) SQLPrepare
	dd	__DLLPatch ; (odbc) SQLPrimaryKeys
	dd	__DLLPatch ; (odbc) SQLProcedureColumns
	dd	__DLLPatch ; (odbc) SQLProcedures
	dd	__DLLPatch ; (odbc) SQLPutData
	dd	__DLLPatch ; (odbc) SQLRowCount
	dd	__DLLPatch ; (odbc) SQLSetConnectOption
	dd	__DLLPatch ; (odbc) SQLSetCursorName
	dd	__DLLPatch ; (odbc) SQLSetParam
	dd	__DLLPatch ; (odbc) SQLSetPos
	dd	__DLLPatch ; (odbc) SQLSetScrollOptions
	dd	__DLLPatch ; (odbc) SQLSetStmtOption
	dd	__DLLPatch ; (odbc) SQLSpecialColumns
	dd	__DLLPatch ; (odbc) SQLStatistics
	dd	__DLLPatch ; (odbc) SQLTablePrivileges
	dd	__DLLPatch ; (odbc) SQLTables
	dd	__DLLPatch ; (odbc) SQLTransact
	dd	ResetDC
	dd	AdjustWindowRect
	dd	AdjustWindowRectEx
	dd	AnimatePalette
	dd	AnsiToOem
	dd	AnsiToOemBuff
	dd	CheckDlgButton
	dd	CheckRadioButton
	dd	ClientToScreen
	dd	ClipCursor
	dd	CloseSound
	dd	CloseWindow
	dd	CopyRect
	dd	CreateCaret
	dd	DebugBreak
	dd	DestroyCaret
	dd	DirectedYield
	dd	DrawFocusRect
	dd	DrawMenuBar
	dd	EndDialog
	dd	EndPaint
	dd	FatalAppExit
	dd	FatalExit
	dd	FreeLibrary
	dd	GetCaretPos
	dd	GetClientRect
	dd	GetClipCursor
	dd	GetCodeInfo
	dd	GetCursorPos
	dd	GetKeyboardState
	dd	GetScrollRange
	dd	GetWindowRect
	dd	GlobalFix
	dd	GlobalNotify
	dd	HideCaret
	dd	InflateRect
	dd	InvalidateRect
	dd	InvalidateRgn
	dd	InvertRect
	dd	LimitEmsPages
	dd	LineDDA
	dd	LogError
	dd	LogParamError
	dd	MapDialogRect
	dd	MapWindowPoints
	dd	MessageBeep
	dd	OemToAnsi
	dd	OemToAnsiBuff
	dd	OffsetRect
	dd	OutputDebugString
	dd	PlayMetaFileRecord
	dd	PostQuitMessage
	dd	ProfClear
	dd	ProfFinish
	dd	ProfFlush
	dd	ProfSampRate
	dd	ProfSetup
	dd	ProfStart
	dd	ProfStop
	dd	ReleaseCapture
	dd	ReplyMessage
	dd	ScreenToClient
	dd	ScrollWindow
	dd	SetCaretBlinkTime
	dd	SetCaretPos
	dd	SetCursorPos
	dd	SetDlgItemInt
	dd	SetDlgItemText
	dd	SetDoubleClickTime
	dd	SetKeyboardState
	dd	SetRect
	dd	SetRectEmpty
	dd	SetRectRgn
	dd	SetScrollRange
	dd	SetSysColors
	dd	SetWindowText
	dd	ShowCaret
	dd	ShowOwnedPopups
	dd	ShowScrollBar
	dd	SwapRecording
	dd	SwitchStackBack
	dd	SwitchStackTo
	dd	Throw
	dd	UpdateWindow
	dd	ValidateCodeSegments
	dd	ValidateFreeSpaces
	dd	ValidateRect
	dd	ValidateRgn
	dd	WaitMessage
	dd	Yield
	dd	FreeProcInstance
	dd	__WDPMIFreeAlias
	dd	__WDPMIFreeHugeAlias
	dd	_clib_delay
	dd	_clib_intr
	dd	_clib_intrf
	dd	__DLLPatch ; (shell) DragFinish
	dd	__DLLPatch ; (shell) DragAcceptFiles
	dd	__DLLPatch ; (penwin) AtomicVirtualEvent
	dd	__DLLPatch ; (penwin) BoundingRectFromPoints
	dd	__DLLPatch ; (penwin) DrawPenData
	dd	__DLLPatch ; (penwin) EmulatePen
	dd	__DLLPatch ; (penwin) FirstSymbolFromGraph
	dd	__DLLPatch ; (penwin) InitRC
	dd	__DLLPatch ; (penwin) PenPacket
	dd	__DLLPatch ; (penwin) PostVirtualKeyEvent
	dd	__DLLPatch ; (penwin) PostVirtualMouseEvent
	dd	__DLLPatch ; (penwin) RegisterPenApp
	dd	__DLLPatch ; (penwin) UninstallRecognizer
	dd	__DLLPatch ; (penwin) UpdatePenInfo
	dd	__DLLPatch ; (stress) FreeAllGDIMem
	dd	__DLLPatch ; (stress) FreeAllMem
	dd	__DLLPatch ; (stress) FreeAllUserMem
	dd	__DLLPatch ; (stress) UnAllocDiskSpace
	dd	__DLLPatch ; (stress) UnAllocFileHandles
	dd	__DLLPatch ; (lzexpand) LZClose
	dd	__DLLPatch ; (lzexpand) LZDone
	dd	__DLLPatch ; (toolhelp) TerminateApp

_DATA ends


_TEXT segment
	assume cs:_TEXT
	assume ds:DGROUP

public __ThunkTable
__ThunkTable LABEL WORD
	dw	__Thunk0
	dw	__Thunk1
	dw	__Thunk2
	dw	__Thunk3
	dw	__Thunk4
	dw	__Thunk5
	dw	__Thunk6
	dw	__Thunk7
	dw	__Thunk8
	dw	__Thunk9
	dw	__Thunk10
	dw	__Thunk11
	dw	__Thunk12
	dw	__Thunk13
	dw	__Thunk14
	dw	__Thunk15
	dw	__Thunk16
	dw	__Thunk17
	dw	__Thunk18
	dw	__Thunk19
	dw	__Thunk20
	dw	__Thunk21
	dw	__Thunk22
	dw	__Thunk23
	dw	__Thunk24
	dw	__Thunk25
	dw	__Thunk26
	dw	__Thunk27
	dw	__Thunk28
	dw	__Thunk29
	dw	__Thunk30
	dw	__Thunk31
	dw	__Thunk32
	dw	__Thunk33
	dw	__Thunk34
	dw	__Thunk35
	dw	__Thunk36
	dw	__Thunk37
	dw	__Thunk38
	dw	__Thunk39
	dw	__Thunk40
	dw	__Thunk41
	dw	__Thunk42
	dw	__Thunk43
	dw	__Thunk44
	dw	__Thunk45
	dw	__Thunk46
	dw	__Thunk47
	dw	__Thunk48
	dw	__Thunk49
	dw	__Thunk50
	dw	__Thunk51
	dw	__Thunk52
	dw	__Thunk53
	dw	__Thunk54
	dw	__Thunk55
	dw	__Thunk56
	dw	__Thunk57
	dw	__Thunk58
	dw	__Thunk59
	dw	__Thunk60
	dw	__Thunk61
	dw	__Thunk62
	dw	__Thunk63
	dw	__Thunk64
	dw	__Thunk65
	dw	__Thunk66
	dw	__Thunk67
	dw	__Thunk68
	dw	__Thunk69
	dw	__Thunk70
	dw	__Thunk71
	dw	__Thunk72
	dw	__Thunk73
	dw	__Thunk74
	dw	__Thunk75
	dw	__Thunk76
	dw	__Thunk77
	dw	__Thunk78
	dw	__Thunk79
	dw	__Thunk80
	dw	__Thunk81
	dw	__Thunk82
	dw	__Thunk83
	dw	__Thunk84
	dw	__Thunk85
	dw	__Thunk86
	dw	__Thunk87
	dw	__Thunk88
	dw	__Thunk89
	dw	__Thunk90
	dw	__Thunk91
	dw	__Thunk92
	dw	__Thunk93
	dw	__Thunk94
	dw	__Thunk95
	dw	__Thunk96
	dw	__Thunk97
	dw	__Thunk98
	dw	__Thunk99
	dw	__Thunk100
	dw	__Thunk101
	dw	__Thunk102
	dw	__Thunk103
	dw	__Thunk104
	dw	__Thunk105
	dw	__Thunk106
	dw	__Thunk107
	dw	__Thunk108
	dw	__Thunk109
	dw	__Thunk110
	dw	__Thunk111
	dw	__Thunk112
	dw	__Thunk113
	dw	__Thunk114
	dw	__Thunk115
	dw	__Thunk116
	dw	__Thunk117
	dw	__Thunk118
	dw	__Thunk119
	dw	__Thunk120
	dw	__Thunk121
	dw	__Thunk122
	dw	__Thunk123
	dw	__Thunk124
	dw	__Thunk125
	dw	__Thunk126
	dw	__Thunk127
	dw	__Thunk128
	dw	__Thunk129
	dw	__Thunk130
	dw	__Thunk131
	dw	__Thunk132
	dw	__Thunk133
	dw	__Thunk134
	dw	__Thunk135
	dw	__Thunk136
	dw	__Thunk137
	dw	__Thunk138
	dw	__Thunk139
	dw	__Thunk140
	dw	__Thunk141
	dw	__Thunk142
	dw	__Thunk143
	dw	__Thunk144
	dw	__Thunk145
	dw	__Thunk146
	dw	__Thunk147
	dw	__Thunk148
	dw	__Thunk149
	dw	__Thunk150
	dw	__Thunk151
	dw	__Thunk152
	dw	__Thunk153
	dw	__Thunk154
	dw	__Thunk155
	dw	__Thunk156
	dw	__Thunk157
	dw	__Thunk158
	dw	__Thunk159
	dw	__Thunk160
	dw	__Thunk161
	dw	__Thunk162
	dw	__Thunk163
	dw	__Thunk164
	dw	__Thunk165
	dw	__Thunk166
	dw	__Thunk167
	dw	__Thunk168
	dw	__Thunk169
	dw	__Thunk170
	dw	__Thunk171
	dw	__Thunk172
	dw	__Thunk173
	dw	__Thunk174
	dw	__Thunk175
	dw	__Thunk176
	dw	__Thunk177
	dw	__Thunk178
	dw	__Thunk179
	dw	__Thunk180
	dw	__Thunk181
	dw	__Thunk182
	dw	__Thunk183
	dw	__Thunk184
	dw	__Thunk185
	dw	__Thunk186
	dw	__Thunk187
	dw	__Thunk188
	dw	__Thunk189
	dw	__Thunk190
	dw	__Thunk191
	dw	__Thunk192
	dw	__Thunk193
	dw	__Thunk194

public  __Thunk0
__Thunk0 proc near
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk0 endp

public  __Thunk1
__Thunk1 proc near
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk1 endp

public  __Thunk2
__Thunk2 proc near
	mov	eax,es:[edi+16]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	jmp	Free16Alias
__Thunk2 endp

public  __Thunk3
__Thunk3 proc near
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk3 endp

public  __Thunk4
__Thunk4 proc near
	mov	eax,es:[edi+20]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+16]	; Parm2
	jmp	Free16Alias
__Thunk4 endp

public  __Thunk5
__Thunk5 proc near
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk5 endp

public  __Thunk6
__Thunk6 proc near
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk6 endp

public  __Thunk7
__Thunk7 proc near
	call	dword ptr ds:[bx]
	ret
__Thunk7 endp

public  __Thunk8
__Thunk8 proc near
	push	si
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk8 endp

public  __Thunk9
__Thunk9 proc near
	push	word ptr es:[edi+48]	; Parm1
	push	word ptr es:[edi+44]	; Parm2
	push	word ptr es:[edi+40]	; Parm3
	push	word ptr es:[edi+36]	; Parm4
	push	word ptr es:[edi+32]	; Parm5
	push	word ptr es:[edi+28]	; Parm6
	push	word ptr es:[edi+24]	; Parm7
	push	word ptr es:[edi+20]	; Parm8
	push	word ptr es:[edi+16]	; Parm9
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk9 endp

public  __Thunk10
__Thunk10 proc near
	mov	eax,es:[edi+16]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+20]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	jmp	Free16Alias
__Thunk10 endp

public  __Thunk11
__Thunk11 proc near
	push	word ptr es:[edi+48]	; Parm1
	push	word ptr es:[edi+44]	; Parm2
	push	word ptr es:[edi+40]	; Parm3
	push	word ptr es:[edi+36]	; Parm4
	push	word ptr es:[edi+32]	; Parm5
	push	word ptr es:[edi+28]	; Parm6
	push	word ptr es:[edi+24]	; Parm7
	push	word ptr es:[edi+20]	; Parm8
	push	dword ptr es:[edi+16]	; Parm9
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk11 endp

public  __Thunk12
__Thunk12 proc near
	mov	eax,es:[edi+16]		; Parm2
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr [bp-8]	; Parm2Alias
	jmp	Free16Alias
__Thunk12 endp

public  __Thunk13
__Thunk13 proc near
	push	esi
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk13 endp

public  __Thunk14
__Thunk14 proc near
	push	edi
	push	si
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk14 endp

public  __Thunk15
__Thunk15 proc near
	mov	eax,es:[edi+24]		; Parm3
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	push	word ptr es:[edi+20]	; Parm4
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk15 endp

public  __Thunk16
__Thunk16 proc near
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk16 endp

public  __Thunk17
__Thunk17 proc near
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk17 endp

public  __Thunk18
__Thunk18 proc near
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk18 endp

public  __Thunk19
__Thunk19 proc near
	push	si
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk19 endp

public  __Thunk20
__Thunk20 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk20 endp

public  __Thunk21
__Thunk21 proc near
	push	di
	push	si
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk21 endp

public  __Thunk22
__Thunk22 proc near
	mov	eax,es:[edi+16]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm6
	call	Get16Alias
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	word ptr es:[edi+24]	; Parm5
	push	dword ptr [bp-16]	; Parm6Alias
	push	dword ptr [bp-8]	; Parm7Alias
	jmp	Free16Alias
__Thunk22 endp

public  __Thunk23
__Thunk23 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk23 endp

public  __Thunk24
__Thunk24 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk24 endp

public  __Thunk25
__Thunk25 proc near
	mov	eax,es:[edi+28]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr es:[edi+20]	; Parm4
	push	dword ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk25 endp

public  __Thunk26
__Thunk26 proc near
	mov	eax,es:[edi+20]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	push	word ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk26 endp

public  __Thunk27
__Thunk27 proc near
	mov	eax,es:[edi+16]		; Parm14
	call	GetFirst16Alias
	push	word ptr es:[edi+68]	; Parm1
	push	word ptr es:[edi+64]	; Parm2
	push	word ptr es:[edi+60]	; Parm3
	push	word ptr es:[edi+56]	; Parm4
	push	word ptr es:[edi+52]	; Parm5
	push	word ptr es:[edi+48]	; Parm6
	push	word ptr es:[edi+44]	; Parm7
	push	word ptr es:[edi+40]	; Parm8
	push	word ptr es:[edi+36]	; Parm9
	push	word ptr es:[edi+32]	; Parm10
	push	word ptr es:[edi+28]	; Parm11
	push	word ptr es:[edi+24]	; Parm12
	push	word ptr es:[edi+20]	; Parm13
	push	dword ptr [bp-8]	; Parm14Alias
	jmp	Free16Alias
__Thunk27 endp

public  __Thunk28
__Thunk28 proc near
	mov	eax,es:[edi+24]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+20]	; Parm2
	push	word ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk28 endp

public  __Thunk29
__Thunk29 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+20]	; Parm3
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk29 endp

public  __Thunk30
__Thunk30 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	word ptr es:[edi+24]	; Parm4
	push	word ptr es:[edi+20]	; Parm5
	push	word ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk30 endp

public  __Thunk31
__Thunk31 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk31 endp

public  __Thunk32
__Thunk32 proc near
	mov	eax,es:[edi+16]		; Parm11
	call	GetFirst16Alias
	mov	eax,es:[edi+52]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+56]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr es:[edi+48]	; Parm3
	push	word ptr es:[edi+44]	; Parm4
	push	word ptr es:[edi+40]	; Parm5
	push	word ptr es:[edi+36]	; Parm6
	push	word ptr es:[edi+32]	; Parm7
	push	word ptr es:[edi+28]	; Parm8
	push	word ptr es:[edi+24]	; Parm9
	push	word ptr es:[edi+20]	; Parm10
	push	dword ptr [bp-8]	; Parm11Alias
	jmp	Free16Alias
__Thunk32 endp

public  __Thunk33
__Thunk33 proc near
	mov	eax,es:[edi+16]		; Parm12
	call	GetFirst16Alias
	mov	eax,es:[edi+52]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+56]		; Parm2
	call	Get16Alias
	push	dword ptr es:[edi+60]	; Parm1
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr es:[edi+48]	; Parm4
	push	word ptr es:[edi+44]	; Parm5
	push	word ptr es:[edi+40]	; Parm6
	push	word ptr es:[edi+36]	; Parm7
	push	word ptr es:[edi+32]	; Parm8
	push	word ptr es:[edi+28]	; Parm9
	push	word ptr es:[edi+24]	; Parm10
	push	word ptr es:[edi+20]	; Parm11
	push	dword ptr [bp-8]	; Parm12Alias
	jmp	Free16Alias
__Thunk33 endp

public  __Thunk34
__Thunk34 proc near
	push	edi
	push	si
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk34 endp

public  __Thunk35
__Thunk35 proc near
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	word ptr es:[edi+32]	; Parm4
	push	word ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	word ptr es:[edi+20]	; Parm7
	push	word ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk35 endp

public  __Thunk36
__Thunk36 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk36 endp

public  __Thunk37
__Thunk37 proc near
	push	di
	push	si
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk37 endp

public  __Thunk38
__Thunk38 proc near
	mov	eax,es:[edi+28]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	word ptr es:[edi+20]	; Parm4
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk38 endp

public  __Thunk39
__Thunk39 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk39 endp

public  __Thunk40
__Thunk40 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+20]	; Parm3
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk40 endp

public  __Thunk41
__Thunk41 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk41 endp

public  __Thunk42
__Thunk42 proc near
	push	di
	push	si
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk42 endp

public  __Thunk43
__Thunk43 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk43 endp

public  __Thunk44
__Thunk44 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk44 endp

public  __Thunk45
__Thunk45 proc near
	push	si
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk45 endp

public  __Thunk46
__Thunk46 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk46 endp

public  __Thunk47
__Thunk47 proc near
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk47 endp

public  __Thunk48
__Thunk48 proc near
	push	di
	push	si
	push	cx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk48 endp

public  __Thunk49
__Thunk49 proc near
	mov	eax,es:[edi+16]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	word ptr es:[edi+32]	; Parm4
	push	dword ptr [bp-24]	; Parm5Alias
	push	dword ptr [bp-16]	; Parm6Alias
	push	word ptr es:[edi+20]	; Parm7
	push	dword ptr [bp-8]	; Parm8Alias
	jmp	Free16Alias
__Thunk49 endp

public  __Thunk50
__Thunk50 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	word ptr es:[edi+24]	; Parm2
	push	word ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk50 endp

public  __Thunk51
__Thunk51 proc near
	mov	eax,es:[edi+20]		; Parm6
	call	GetFirst16Alias
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	push	word ptr es:[edi+16]	; Parm7
	jmp	Free16Alias
__Thunk51 endp

public  __Thunk52
__Thunk52 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk52 endp

public  __Thunk53
__Thunk53 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk53 endp

public  __Thunk54
__Thunk54 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	dword ptr es:[edi+28]	; Parm2
	push	dword ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	dword ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk54 endp

public  __Thunk55
__Thunk55 proc near
	mov	eax,es:[edi+16]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm4
	call	Get16Alias
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr [bp-24]	; Parm4Alias
	push	dword ptr es:[edi+24]	; Parm5
	push	dword ptr [bp-16]	; Parm6Alias
	push	dword ptr [bp-8]	; Parm7Alias
	jmp	Free16Alias
__Thunk55 endp

public  __Thunk56
__Thunk56 proc near
	push	cx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk56 endp

public  __Thunk57
__Thunk57 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	push	dword ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	word ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk57 endp

public  __Thunk58
__Thunk58 proc near
	mov	eax,es:[edi+28]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+24]	; Parm2
	push	word ptr es:[edi+20]	; Parm3
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk58 endp

public  __Thunk59
__Thunk59 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	push	word ptr es:[edi+24]	; Parm1
	push	word ptr es:[edi+20]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk59 endp

public  __Thunk60
__Thunk60 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk60 endp

public  __Thunk61
__Thunk61 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-40]	; Parm1Alias
	push	dword ptr [bp-32]	; Parm2Alias
	push	dword ptr [bp-24]	; Parm3Alias
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk61 endp

public  __Thunk62
__Thunk62 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk62 endp

public  __Thunk63
__Thunk63 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	word ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk63 endp

public  __Thunk64
__Thunk64 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk64 endp

public  __Thunk65
__Thunk65 proc near
	mov	eax,es:[edi+36]		; Parm4
	call	GetFirst16Alias
	push	word ptr es:[edi+48]	; Parm1
	push	word ptr es:[edi+44]	; Parm2
	push	dword ptr es:[edi+40]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+32]	; Parm5
	push	word ptr es:[edi+28]	; Parm6
	push	word ptr es:[edi+24]	; Parm7
	push	word ptr es:[edi+20]	; Parm8
	push	word ptr es:[edi+16]	; Parm9
	jmp	Free16Alias
__Thunk65 endp

public  __Thunk66
__Thunk66 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk66 endp

public  __Thunk67
__Thunk67 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk67 endp

public  __Thunk68
__Thunk68 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	word ptr es:[edi+24]	; Parm4
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk68 endp

public  __Thunk69
__Thunk69 proc near
	mov	eax,es:[edi+32]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+28]	; Parm2
	push	word ptr es:[edi+24]	; Parm3
	push	word ptr es:[edi+20]	; Parm4
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk69 endp

public  __Thunk70
__Thunk70 proc near
	mov	eax,es:[edi+20]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	dword ptr es:[edi+16]	; Parm2
	jmp	Free16Alias
__Thunk70 endp

public  __Thunk71
__Thunk71 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	word ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	word ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk71 endp

public  __Thunk72
__Thunk72 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	word ptr es:[edi+24]	; Parm4
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk72 endp

public  __Thunk73
__Thunk73 proc near
	mov	eax,es:[edi+16]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm4
	call	Get16Alias
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr [bp-24]	; Parm4Alias
	push	dword ptr [bp-16]	; Parm5Alias
	push	word ptr es:[edi+20]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	jmp	Free16Alias
__Thunk73 endp

public  __Thunk74
__Thunk74 proc near
	mov	eax,es:[edi+20]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm4
	call	Get16Alias
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	dword ptr [bp-24]	; Parm4Alias
	push	dword ptr [bp-16]	; Parm5Alias
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	push	word ptr es:[edi+16]	; Parm8
	jmp	Free16Alias
__Thunk74 endp

public  __Thunk75
__Thunk75 proc near
	mov	eax,es:[edi+20]		; Parm11
	call	GetFirst16Alias
	push	word ptr es:[edi+60]	; Parm1
	push	word ptr es:[edi+56]	; Parm2
	push	word ptr es:[edi+52]	; Parm3
	push	word ptr es:[edi+48]	; Parm4
	push	word ptr es:[edi+44]	; Parm5
	push	word ptr es:[edi+40]	; Parm6
	push	word ptr es:[edi+36]	; Parm7
	push	word ptr es:[edi+32]	; Parm8
	push	word ptr es:[edi+28]	; Parm9
	push	dword ptr es:[edi+24]	; Parm10
	push	dword ptr [bp-8]	; Parm11Alias
	push	word ptr es:[edi+16]	; Parm12
	jmp	Free16Alias
__Thunk75 endp

public  __Thunk76
__Thunk76 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk76 endp

public  __Thunk77
__Thunk77 proc near
	push	si
	push	ecx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk77 endp

public  __Thunk78
__Thunk78 proc near
	push	word ptr es:[edi+56]	; Parm1
	push	word ptr es:[edi+52]	; Parm2
	push	word ptr es:[edi+48]	; Parm3
	push	word ptr es:[edi+44]	; Parm4
	push	word ptr es:[edi+40]	; Parm5
	push	word ptr es:[edi+36]	; Parm6
	push	word ptr es:[edi+32]	; Parm7
	push	word ptr es:[edi+28]	; Parm8
	push	word ptr es:[edi+24]	; Parm9
	push	word ptr es:[edi+20]	; Parm10
	push	dword ptr es:[edi+16]	; Parm11
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk78 endp

public  __Thunk79
__Thunk79 proc near
	mov	eax,es:[edi+24]		; Parm11
	call	GetFirst16Alias
	push	word ptr es:[edi+64]	; Parm1
	push	word ptr es:[edi+60]	; Parm2
	push	word ptr es:[edi+56]	; Parm3
	push	word ptr es:[edi+52]	; Parm4
	push	word ptr es:[edi+48]	; Parm5
	push	word ptr es:[edi+44]	; Parm6
	push	word ptr es:[edi+40]	; Parm7
	push	word ptr es:[edi+36]	; Parm8
	push	word ptr es:[edi+32]	; Parm9
	push	dword ptr es:[edi+28]	; Parm10
	push	dword ptr [bp-8]	; Parm11Alias
	push	word ptr es:[edi+20]	; Parm12
	push	dword ptr es:[edi+16]	; Parm13
	jmp	Free16Alias
__Thunk79 endp

public  __Thunk80
__Thunk80 proc near
	mov	eax,es:[edi+20]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+32]		; Parm4
	call	Get16Alias
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	push	word ptr es:[edi+16]	; Parm8
	jmp	Free16Alias
__Thunk80 endp

public  __Thunk81
__Thunk81 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk81 endp

public  __Thunk82
__Thunk82 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm3
	call	Get16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk82 endp

public  __Thunk83
__Thunk83 proc near
	mov	eax,es:[edi+16]		; Parm7
	call	GetFirst16Alias
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	word ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	jmp	Free16Alias
__Thunk83 endp

public  __Thunk84
__Thunk84 proc near
	push	di
	push	si
	push	ecx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk84 endp

public  __Thunk85
__Thunk85 proc near
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk85 endp

public  __Thunk86
__Thunk86 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	word ptr es:[edi+24]	; Parm5
	push	dword ptr es:[edi+20]	; Parm6
	push	dword ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk86 endp

public  __Thunk87
__Thunk87 proc near
	push	esi
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk87 endp

public  __Thunk88
__Thunk88 proc near
	push	si
	push	ecx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk88 endp

public  __Thunk89
__Thunk89 proc near
	push	di
	push	esi
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk89 endp

public  __Thunk90
__Thunk90 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	dword ptr es:[edi+32]	; Parm2
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	word ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk90 endp

public  __Thunk91
__Thunk91 proc near
	push	word ptr es:[edi+68]	; Parm1
	push	word ptr es:[edi+64]	; Parm2
	push	word ptr es:[edi+60]	; Parm3
	push	word ptr es:[edi+56]	; Parm4
	push	word ptr es:[edi+52]	; Parm5
	push	word ptr es:[edi+48]	; Parm6
	push	word ptr es:[edi+44]	; Parm7
	push	word ptr es:[edi+40]	; Parm8
	push	word ptr es:[edi+36]	; Parm9
	push	word ptr es:[edi+32]	; Parm10
	push	word ptr es:[edi+28]	; Parm11
	push	word ptr es:[edi+24]	; Parm12
	push	word ptr es:[edi+20]	; Parm13
	push	dword ptr es:[edi+16]	; Parm14
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk91 endp

public  __Thunk92
__Thunk92 proc near
	push	ecx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk92 endp

public  __Thunk93
__Thunk93 proc near
	push	esi
	push	ecx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk93 endp

public  __Thunk94
__Thunk94 proc near
	push	si
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk94 endp

public  __Thunk95
__Thunk95 proc near
	push	dword ptr es:[edi+56]	; Parm1
	push	dword ptr es:[edi+52]	; Parm2
	push	dword ptr es:[edi+48]	; Parm3
	push	word ptr es:[edi+44]	; Parm4
	push	word ptr es:[edi+40]	; Parm5
	push	word ptr es:[edi+36]	; Parm6
	push	word ptr es:[edi+32]	; Parm7
	push	word ptr es:[edi+28]	; Parm8
	push	word ptr es:[edi+24]	; Parm9
	push	word ptr es:[edi+20]	; Parm10
	push	dword ptr es:[edi+16]	; Parm11
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk95 endp

public  __Thunk96
__Thunk96 proc near
	push	dword ptr es:[edi+60]	; Parm1
	push	dword ptr es:[edi+56]	; Parm2
	push	dword ptr es:[edi+52]	; Parm3
	push	dword ptr es:[edi+48]	; Parm4
	push	word ptr es:[edi+44]	; Parm5
	push	word ptr es:[edi+40]	; Parm6
	push	word ptr es:[edi+36]	; Parm7
	push	word ptr es:[edi+32]	; Parm8
	push	word ptr es:[edi+28]	; Parm9
	push	word ptr es:[edi+24]	; Parm10
	push	word ptr es:[edi+20]	; Parm11
	push	dword ptr es:[edi+16]	; Parm12
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk96 endp

public  __Thunk97
__Thunk97 proc near
	push	di
	push	esi
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk97 endp

public  __Thunk98
__Thunk98 proc near
	push	di
	push	esi
	push	cx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk98 endp

public  __Thunk99
__Thunk99 proc near
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	word ptr es:[edi+32]	; Parm4
	push	dword ptr es:[edi+28]	; Parm5
	push	dword ptr es:[edi+24]	; Parm6
	push	word ptr es:[edi+20]	; Parm7
	push	dword ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk99 endp

public  __Thunk100
__Thunk100 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	dword ptr es:[edi+20]	; Parm6
	push	word ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk100 endp

public  __Thunk101
__Thunk101 proc near
	push	si
	push	cx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk101 endp

public  __Thunk102
__Thunk102 proc near
	push	ecx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk102 endp

public  __Thunk103
__Thunk103 proc near
	push	di
	push	esi
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk103 endp

public  __Thunk104
__Thunk104 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	dword ptr es:[edi+20]	; Parm6
	push	dword ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk104 endp

public  __Thunk105
__Thunk105 proc near
	push	esi
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk105 endp

public  __Thunk106
__Thunk106 proc near
	push	esi
	push	ecx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk106 endp

public  __Thunk107
__Thunk107 proc near
	push	dword ptr es:[edi+36]	; Parm1
	push	dword ptr es:[edi+32]	; Parm2
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk107 endp

public  __Thunk108
__Thunk108 proc near
	push	edi
	push	esi
	push	ecx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk108 endp

public  __Thunk109
__Thunk109 proc near
	push	di
	push	esi
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk109 endp

public  __Thunk110
__Thunk110 proc near
	push	word ptr es:[edi+48]	; Parm1
	push	word ptr es:[edi+44]	; Parm2
	push	dword ptr es:[edi+40]	; Parm3
	push	dword ptr es:[edi+36]	; Parm4
	push	word ptr es:[edi+32]	; Parm5
	push	word ptr es:[edi+28]	; Parm6
	push	word ptr es:[edi+24]	; Parm7
	push	word ptr es:[edi+20]	; Parm8
	push	word ptr es:[edi+16]	; Parm9
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk110 endp

public  __Thunk111
__Thunk111 proc near
	push	si
	push	ecx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk111 endp

public  __Thunk112
__Thunk112 proc near
	push	edi
	push	si
	push	cx
	push	dx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk112 endp

public  __Thunk113
__Thunk113 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	dword ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk113 endp

public  __Thunk114
__Thunk114 proc near
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	dword ptr es:[edi+32]	; Parm4
	push	dword ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	word ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk114 endp

public  __Thunk115
__Thunk115 proc near
	push	word ptr es:[edi+60]	; Parm1
	push	word ptr es:[edi+56]	; Parm2
	push	word ptr es:[edi+52]	; Parm3
	push	word ptr es:[edi+48]	; Parm4
	push	word ptr es:[edi+44]	; Parm5
	push	word ptr es:[edi+40]	; Parm6
	push	word ptr es:[edi+36]	; Parm7
	push	word ptr es:[edi+32]	; Parm8
	push	word ptr es:[edi+28]	; Parm9
	push	dword ptr es:[edi+24]	; Parm10
	push	dword ptr es:[edi+20]	; Parm11
	push	word ptr es:[edi+16]	; Parm12
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk115 endp

public  __Thunk116
__Thunk116 proc near
	push	word ptr es:[edi+64]	; Parm1
	push	word ptr es:[edi+60]	; Parm2
	push	word ptr es:[edi+56]	; Parm3
	push	word ptr es:[edi+52]	; Parm4
	push	word ptr es:[edi+48]	; Parm5
	push	word ptr es:[edi+44]	; Parm6
	push	word ptr es:[edi+40]	; Parm7
	push	word ptr es:[edi+36]	; Parm8
	push	word ptr es:[edi+32]	; Parm9
	push	dword ptr es:[edi+28]	; Parm10
	push	dword ptr es:[edi+24]	; Parm11
	push	word ptr es:[edi+20]	; Parm12
	push	dword ptr es:[edi+16]	; Parm13
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk116 endp

public  __Thunk117
__Thunk117 proc near
	push	word ptr es:[edi+44]	; Parm1
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	dword ptr es:[edi+32]	; Parm4
	push	word ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	word ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk117 endp

public  __Thunk118
__Thunk118 proc near
	push	di
	push	si
	push	ecx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk118 endp

public  __Thunk119
__Thunk119 proc near
	push	word ptr es:[edi+40]	; Parm1
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	word ptr es:[edi+28]	; Parm4
	push	word ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	dword ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk119 endp

public  __Thunk120
__Thunk120 proc near
	mov	eax,es:[edi+16]		; Parm2
	call	GetFirst16Alias
	push	dword ptr es:[edi+20]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	jmp	Free16Alias
__Thunk120 endp

public  __Thunk121
__Thunk121 proc near
	mov	eax,es:[edi+20]		; Parm2
	call	GetFirst16Alias
	push	dword ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk121 endp

public  __Thunk122
__Thunk122 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	word ptr es:[edi+20]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk122 endp

public  __Thunk123
__Thunk123 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	push	dword ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk123 endp

public  __Thunk124
__Thunk124 proc near
	mov	eax,es:[edi+16]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+44]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr es:[edi+40]	; Parm2
	push	dword ptr es:[edi+36]	; Parm3
	push	dword ptr es:[edi+32]	; Parm4
	push	word ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	dword ptr [bp-8]	; Parm8Alias
	jmp	Free16Alias
__Thunk124 endp

public  __Thunk125
__Thunk125 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	push	dword ptr es:[edi+28]	; Parm1
	push	dword ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk125 endp

public  __Thunk126
__Thunk126 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	push	dword ptr es:[edi+32]	; Parm1
	push	dword ptr es:[edi+28]	; Parm2
	push	dword ptr es:[edi+24]	; Parm3
	push	dword ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk126 endp

public  __Thunk127
__Thunk127 proc near
	mov	eax,es:[edi+36]		; Parm2
	call	GetFirst16Alias
	push	dword ptr es:[edi+40]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+32]	; Parm3
	push	dword ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	word ptr es:[edi+16]	; Parm7
	jmp	Free16Alias
__Thunk127 endp

public  __Thunk128
__Thunk128 proc near
	mov	eax,es:[edi+28]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	dword ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk128 endp

public  __Thunk129
__Thunk129 proc near
	push	esi
	push	ecx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk129 endp

public  __Thunk130
__Thunk130 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	push	dword ptr es:[edi+24]	; Parm1
	push	dword ptr es:[edi+20]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk130 endp

public  __Thunk131
__Thunk131 proc near
	mov	eax,es:[edi+24]		; Parm3
	call	GetFirst16Alias
	push	dword ptr es:[edi+32]	; Parm1
	push	dword ptr es:[edi+28]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	push	dword ptr es:[edi+20]	; Parm4
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk131 endp

public  __Thunk132
__Thunk132 proc near
	push	dword ptr es:[edi+44]	; Parm1
	push	dword ptr es:[edi+40]	; Parm2
	push	dword ptr es:[edi+36]	; Parm3
	push	dword ptr es:[edi+32]	; Parm4
	push	word ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	dword ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk132 endp

public  __Thunk133
__Thunk133 proc near
	push	edi
	push	esi
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk133 endp

public  __Thunk134
__Thunk134 proc near
	push	dword ptr es:[edi+40]	; Parm1
	push	dword ptr es:[edi+36]	; Parm2
	push	dword ptr es:[edi+32]	; Parm3
	push	dword ptr es:[edi+28]	; Parm4
	push	dword ptr es:[edi+24]	; Parm5
	push	word ptr es:[edi+20]	; Parm6
	push	word ptr es:[edi+16]	; Parm7
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk134 endp

public  __Thunk135
__Thunk135 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm2
	call	Get16Alias
	push	dword ptr es:[edi+24]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk135 endp

public  __Thunk136
__Thunk136 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	push	dword ptr es:[edi+32]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	dword ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk136 endp

public  __Thunk137
__Thunk137 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	push	dword ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk137 endp

public  __Thunk138
__Thunk138 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	push	dword ptr es:[edi+28]	; Parm1
	push	dword ptr es:[edi+24]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk138 endp

public  __Thunk139
__Thunk139 proc near
	mov	eax,es:[edi+20]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	dword ptr [bp-32]	; Parm2Alias
	push	dword ptr [bp-24]	; Parm3Alias
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr [bp-8]	; Parm5Alias
	push	word ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk139 endp

public  __Thunk140
__Thunk140 proc near
	mov	eax,es:[edi+24]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+28]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk140 endp

public  __Thunk141
__Thunk141 proc near
	mov	eax,es:[edi+20]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk141 endp

public  __Thunk142
__Thunk142 proc near
	mov	eax,es:[edi+28]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk142 endp

public  __Thunk143
__Thunk143 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	push	word ptr es:[edi+24]	; Parm1
	push	dword ptr es:[edi+20]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk143 endp

public  __Thunk144
__Thunk144 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk144 endp

public  __Thunk145
__Thunk145 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk145 endp

public  __Thunk146
__Thunk146 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr [bp-24]	; Parm3Alias
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk146 endp

public  __Thunk147
__Thunk147 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	word ptr es:[edi+24]	; Parm3
	push	word ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk147 endp

public  __Thunk148
__Thunk148 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr [bp-24]	; Parm3Alias
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk148 endp

public  __Thunk149
__Thunk149 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	word ptr es:[edi+24]	; Parm3
	push	word ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk149 endp

public  __Thunk150
__Thunk150 proc near
	mov	eax,es:[edi+24]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk150 endp

public  __Thunk151
__Thunk151 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm3
	call	Get16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk151 endp

public  __Thunk152
__Thunk152 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk152 endp

public  __Thunk153
__Thunk153 proc near
	push	ecx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk153 endp

public  __Thunk154
__Thunk154 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	dword ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk154 endp

public  __Thunk155
__Thunk155 proc near
	push	edi
	push	esi
	push	cx
	push	edx
	push	ax
	call	dword ptr ds:[bx]
	ret
__Thunk155 endp

public  __Thunk156
__Thunk156 proc near
	push	esi
	push	cx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk156 endp

public  __Thunk157
__Thunk157 proc near
	push	edi
	push	si
	push	ecx
	push	edx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk157 endp

public  __Thunk158
__Thunk158 proc near
	push	edi
	push	esi
	push	cx
	push	dx
	push	eax
	call	dword ptr ds:[bx]
	ret
__Thunk158 endp

public  __Thunk159
__Thunk159 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk159 endp

public  __Thunk160
__Thunk160 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr [bp-16]	; Parm3Alias
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk160 endp

public  __Thunk161
__Thunk161 proc near
	mov	eax,es:[edi+16]		; Parm4
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	dword ptr [bp-8]	; Parm4Alias
	jmp	Free16Alias
__Thunk161 endp

public  __Thunk162
__Thunk162 proc near
	mov	eax,es:[edi+16]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm7
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+40]		; Parm2
	call	Get16Alias
	push	word ptr es:[edi+44]	; Parm1
	push	dword ptr [bp-56]	; Parm2Alias
	push	dword ptr [bp-48]	; Parm3Alias
	push	dword ptr [bp-40]	; Parm4Alias
	push	dword ptr [bp-32]	; Parm5Alias
	push	dword ptr [bp-24]	; Parm6Alias
	push	dword ptr [bp-16]	; Parm7Alias
	push	dword ptr [bp-8]	; Parm8Alias
	jmp	Free16Alias
__Thunk162 endp

public  __Thunk163
__Thunk163 proc near
	push	dword ptr es:[edi+36]	; Parm1
	push	dword ptr es:[edi+32]	; Parm2
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk163 endp

public  __Thunk164
__Thunk164 proc near
	push	word ptr es:[edi+44]	; Parm1
	push	dword ptr es:[edi+40]	; Parm2
	push	dword ptr es:[edi+36]	; Parm3
	push	dword ptr es:[edi+32]	; Parm4
	push	dword ptr es:[edi+28]	; Parm5
	push	dword ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	dword ptr es:[edi+16]	; Parm8
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk164 endp

public  __Thunk165
__Thunk165 proc near
	mov	eax,es:[edi+32]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr es:[edi+24]	; Parm3
	push	dword ptr es:[edi+20]	; Parm4
	push	dword ptr es:[edi+16]	; Parm5
	jmp	Free16Alias
__Thunk165 endp

public  __Thunk166
__Thunk166 proc near
	mov	eax,es:[edi+20]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	dword ptr [bp-16]	; Parm2Alias
	push	dword ptr [bp-8]	; Parm3Alias
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk166 endp

public  __Thunk167
__Thunk167 proc near
	mov	eax,es:[edi+24]		; Parm2
	call	GetFirst16Alias
	push	word ptr es:[edi+28]	; Parm1
	push	dword ptr [bp-8]	; Parm2Alias
	push	dword ptr es:[edi+20]	; Parm3
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk167 endp

public  __Thunk168
__Thunk168 proc near
	mov	eax,es:[edi+28]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk168 endp

public  __Thunk169
__Thunk169 proc near
	push	dword ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk169 endp

public  __Thunk170
__Thunk170 proc near
	mov	eax,es:[edi+36]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	dword ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	jmp	Free16Alias
__Thunk170 endp

public  __Thunk171
__Thunk171 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	word ptr es:[edi+28]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk171 endp

public  __Thunk172
__Thunk172 proc near
	mov	eax,es:[edi+16]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+40]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	word ptr es:[edi+36]	; Parm2
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr [bp-24]	; Parm4Alias
	push	word ptr es:[edi+24]	; Parm5
	push	dword ptr [bp-16]	; Parm6Alias
	push	dword ptr [bp-8]	; Parm7Alias
	jmp	Free16Alias
__Thunk172 endp

public  __Thunk173
__Thunk173 proc near
	mov	eax,es:[edi+20]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+48]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-40]	; Parm1Alias
	push	dword ptr [bp-32]	; Parm2Alias
	push	word ptr es:[edi+40]	; Parm3
	push	dword ptr [bp-24]	; Parm4Alias
	push	word ptr es:[edi+32]	; Parm5
	push	dword ptr [bp-16]	; Parm6Alias
	push	word ptr es:[edi+24]	; Parm7
	push	dword ptr [bp-8]	; Parm8Alias
	push	word ptr es:[edi+16]	; Parm9
	jmp	Free16Alias
__Thunk173 endp

public  __Thunk174
__Thunk174 proc near
	mov	eax,es:[edi+20]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+40]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	word ptr es:[edi+32]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+24]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	push	word ptr es:[edi+16]	; Parm7
	jmp	Free16Alias
__Thunk174 endp

public  __Thunk175
__Thunk175 proc near
	mov	eax,es:[edi+16]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-40]	; Parm1Alias
	push	word ptr es:[edi+40]	; Parm2
	push	dword ptr [bp-32]	; Parm3Alias
	push	word ptr es:[edi+32]	; Parm4
	push	dword ptr [bp-24]	; Parm5Alias
	push	dword ptr [bp-16]	; Parm6Alias
	push	word ptr es:[edi+20]	; Parm7
	push	dword ptr [bp-8]	; Parm8Alias
	jmp	Free16Alias
__Thunk175 endp

public  __Thunk176
__Thunk176 proc near
	mov	eax,es:[edi+16]		; Parm9
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm8
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm7
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+40]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+48]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-56]	; Parm1Alias
	push	word ptr es:[edi+44]	; Parm2
	push	dword ptr [bp-48]	; Parm3Alias
	push	word ptr es:[edi+36]	; Parm4
	push	dword ptr [bp-40]	; Parm5Alias
	push	dword ptr [bp-32]	; Parm6Alias
	push	dword ptr [bp-24]	; Parm7Alias
	push	dword ptr [bp-16]	; Parm8Alias
	push	dword ptr [bp-8]	; Parm9Alias
	jmp	Free16Alias
__Thunk176 endp

public  __Thunk177
__Thunk177 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-40]	; Parm1Alias
	push	word ptr es:[edi+32]	; Parm2
	push	dword ptr [bp-32]	; Parm3Alias
	push	dword ptr [bp-24]	; Parm4Alias
	push	dword ptr [bp-16]	; Parm5Alias
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk177 endp

public  __Thunk178
__Thunk178 proc near
	mov	eax,es:[edi+20]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	word ptr es:[edi+40]	; Parm2
	push	dword ptr [bp-24]	; Parm3Alias
	push	word ptr es:[edi+32]	; Parm4
	push	dword ptr [bp-16]	; Parm5Alias
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	push	word ptr es:[edi+16]	; Parm8
	jmp	Free16Alias
__Thunk178 endp

public  __Thunk179
__Thunk179 proc near
	mov	eax,es:[edi+16]		; Parm8
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+28]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+40]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-56]	; Parm1Alias
	push	dword ptr [bp-48]	; Parm2Alias
	push	dword ptr [bp-40]	; Parm3Alias
	push	dword ptr [bp-32]	; Parm4Alias
	push	dword ptr [bp-24]	; Parm5Alias
	push	dword ptr [bp-16]	; Parm6Alias
	push	word ptr es:[edi+20]	; Parm7
	push	dword ptr [bp-8]	; Parm8Alias
	jmp	Free16Alias
__Thunk179 endp

public  __Thunk180
__Thunk180 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk180 endp

public  __Thunk181
__Thunk181 proc near
	mov	eax,es:[edi+20]		; Parm12
	call	GetFirst16Alias
	mov	eax,es:[edi+28]		; Parm10
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm8
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm6
	call	Get16Alias
	mov	eax,es:[edi+52]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+60]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+64]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-56]	; Parm1Alias
	push	dword ptr [bp-48]	; Parm2Alias
	push	word ptr es:[edi+56]	; Parm3
	push	dword ptr [bp-40]	; Parm4Alias
	push	word ptr es:[edi+48]	; Parm5
	push	dword ptr [bp-32]	; Parm6Alias
	push	word ptr es:[edi+40]	; Parm7
	push	dword ptr [bp-24]	; Parm8Alias
	push	word ptr es:[edi+32]	; Parm9
	push	dword ptr [bp-16]	; Parm10Alias
	push	word ptr es:[edi+24]	; Parm11
	push	dword ptr [bp-8]	; Parm12Alias
	push	word ptr es:[edi+16]	; Parm13
	jmp	Free16Alias
__Thunk181 endp

public  __Thunk182
__Thunk182 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk182 endp

public  __Thunk183
__Thunk183 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-24]	; Parm1Alias
	push	word ptr es:[edi+28]	; Parm2
	push	dword ptr [bp-16]	; Parm3Alias
	push	word ptr es:[edi+20]	; Parm4
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk183 endp

public  __Thunk184
__Thunk184 proc near
	mov	eax,es:[edi+16]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+32]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+36]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	dword ptr es:[edi+28]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	jmp	Free16Alias
__Thunk184 endp

public  __Thunk185
__Thunk185 proc near
	mov	eax,es:[edi+16]		; Parm3
	call	GetFirst16Alias
	mov	eax,es:[edi+24]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-16]	; Parm1Alias
	push	dword ptr es:[edi+20]	; Parm2
	push	dword ptr [bp-8]	; Parm3Alias
	jmp	Free16Alias
__Thunk185 endp

public  __Thunk186
__Thunk186 proc near
	mov	eax,es:[edi+24]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+20]	; Parm2
	push	dword ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk186 endp

public  __Thunk187
__Thunk187 proc near
	mov	eax,es:[edi+44]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+40]	; Parm2
	push	word ptr es:[edi+36]	; Parm3
	push	word ptr es:[edi+32]	; Parm4
	push	dword ptr es:[edi+28]	; Parm5
	push	word ptr es:[edi+24]	; Parm6
	push	dword ptr es:[edi+20]	; Parm7
	push	dword ptr es:[edi+16]	; Parm8
	jmp	Free16Alias
__Thunk187 endp

public  __Thunk188
__Thunk188 proc near
	mov	eax,es:[edi+28]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	word ptr es:[edi+24]	; Parm2
	push	dword ptr es:[edi+20]	; Parm3
	push	word ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk188 endp

public  __Thunk189
__Thunk189 proc near
	mov	eax,es:[edi+28]		; Parm7
	call	GetFirst16Alias
	mov	eax,es:[edi+36]		; Parm5
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm3
	call	Get16Alias
	mov	eax,es:[edi+52]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	word ptr es:[edi+48]	; Parm2
	push	dword ptr [bp-24]	; Parm3Alias
	push	word ptr es:[edi+40]	; Parm4
	push	dword ptr [bp-16]	; Parm5Alias
	push	word ptr es:[edi+32]	; Parm6
	push	dword ptr [bp-8]	; Parm7Alias
	push	word ptr es:[edi+24]	; Parm8
	push	word ptr es:[edi+20]	; Parm9
	push	word ptr es:[edi+16]	; Parm10
	jmp	Free16Alias
__Thunk189 endp

public  __Thunk190
__Thunk190 proc near
	mov	eax,es:[edi+28]		; Parm6
	call	GetFirst16Alias
	mov	eax,es:[edi+36]		; Parm4
	call	Get16Alias
	mov	eax,es:[edi+44]		; Parm2
	call	Get16Alias
	mov	eax,es:[edi+48]		; Parm1
	call	Get16Alias
	push	dword ptr [bp-32]	; Parm1Alias
	push	dword ptr [bp-24]	; Parm2Alias
	push	word ptr es:[edi+40]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	word ptr es:[edi+32]	; Parm5
	push	dword ptr [bp-8]	; Parm6Alias
	push	word ptr es:[edi+24]	; Parm7
	push	word ptr es:[edi+20]	; Parm8
	push	word ptr es:[edi+16]	; Parm9
	jmp	Free16Alias
__Thunk190 endp

public  __Thunk191
__Thunk191 proc near
	mov	eax,es:[edi+24]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	dword ptr es:[edi+20]	; Parm2
	push	word ptr es:[edi+16]	; Parm3
	jmp	Free16Alias
__Thunk191 endp

public  __Thunk192
__Thunk192 proc near
	mov	eax,es:[edi+28]		; Parm1
	call	GetFirst16Alias
	push	dword ptr [bp-8]	; Parm1Alias
	push	dword ptr es:[edi+24]	; Parm2
	push	word ptr es:[edi+20]	; Parm3
	push	dword ptr es:[edi+16]	; Parm4
	jmp	Free16Alias
__Thunk192 endp

public  __Thunk193
__Thunk193 proc near
	push	word ptr es:[edi+36]	; Parm1
	push	word ptr es:[edi+32]	; Parm2
	push	word ptr es:[edi+28]	; Parm3
	push	word ptr es:[edi+24]	; Parm4
	push	dword ptr es:[edi+20]	; Parm5
	push	dword ptr es:[edi+16]	; Parm6
	call	dword ptr ds:[bx]
	push	dx
	push	ax
	pop	eax
	ret
__Thunk193 endp

public  __Thunk194
__Thunk194 proc near
	mov	eax,es:[edi+16]		; Parm5
	call	GetFirst16Alias
	mov	eax,es:[edi+20]		; Parm4
	call	Get16Alias
	push	word ptr es:[edi+32]	; Parm1
	push	word ptr es:[edi+28]	; Parm2
	push	word ptr es:[edi+24]	; Parm3
	push	dword ptr [bp-16]	; Parm4Alias
	push	dword ptr [bp-8]	; Parm5Alias
	jmp	Free16Alias
__Thunk194 endp

_TEXT ends

end
