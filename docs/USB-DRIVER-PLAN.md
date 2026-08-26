# USB Driver Plan — DOS + Win98 + WinNT

_the crew 4free — sysop/0_
_Last updated: 2026-08-25_

## Hardware

### USB Ethernet — Natec Cricket NNC-1924
- Chipset: Realtek RTL8153
- Interface: USB 3.0 Type-A → RJ-45
- Speed: Gigabit (1000/100/10 Mbps)
- Features: Wake on LAN, Full Duplex, Auto-Negotiation
- Linux driver: r8152.c (~3K lines, GPL)
- Our target: DOS packet driver (~2K lines)

### USB Wireless — TBD
- Need USB WiFi adapter with documented chipset
- Candidates: RT2500/RT73 (Ralink, open docs)

### USB Modems
- CDC-ACM class — any USB modem
- Bridge to FOSSIL API for BBS software
- usb_cdc.pas framework written

## DOS USB Ethernet Architecture

```
Application (mTCP, Trumpet, Telnet)
    ↓
Packet Driver API (INT 60h, NE2000-compatible)
    ↓
rtl8153_pkt.asm — our RTL8153 packet driver
    ↓
USB Bulk Transfer (CDC-ECM + vendor extensions)
    ↓
EHCI/xHCI host controller driver
    ↓
USB hardware (PCI → USB port → Cricket dongle)
```

## Implementation Phases

### Phase U-1: RTL8153 Register Map
- [ ] Extract register definitions from Linux r8152.c
- [ ] Map USB control transfers for chip init
- [ ] PHY init sequence (RTL8153 has internal PHY)
- [ ] MAC address read (from EEPROM via USB)

### Phase U-2: USB Bulk Transfer for Ethernet
- [ ] RX: bulk IN endpoint → Ethernet frame
- [ ] TX: Ethernet frame → bulk OUT endpoint
- [ ] RTL8153 frame format (4-byte header + payload)
- [ ] Multi-packet aggregation (USB 3.0 optimization)

### Phase U-3: DOS Packet Driver
- [ ] INT 60h hook (packet driver API)
- [ ] get_address — return MAC address
- [ ] send_pkt — transmit Ethernet frame
- [ ] receive — callback for incoming frames
- [ ] TSR (terminate and stay resident)

### Phase U-4: Integration + Testing
- [ ] mTCP ping test over USB Ethernet
- [ ] Telnet over USB Ethernet to BBS
- [ ] FTP file transfer speed test
- [ ] Compare with NE2000 ISA baseline

## VBE/VGA Display Drivers

### VBE9x Miniport (Win98)
- Location: xp-drivers/vbe9x-miniport/VBE9X/
- VBE.VXD — universal VBE driver for Win98
- Supports: ATI, CL54, Intel, NV, Bochs, VMware, Universal
- Status: In archive, needs testing on Win98

### VBEMP2K (WinNT/2K/XP)
- Location: xp-drivers/vbe9x-miniport/VBEMP2K/
- Miniport driver for NT-family
- Works on x64 too
- Status: In archive, needs testing

### SciTech Display Doctor (DOS)
- Location: snap-graphics/
- SNAP Graphics source → rebuild Display Doctor
- Universal VBE/AF for every VGA card
- Protected mode VESA driver
- Status: Source archived, needs rebuild

## FPC USB Phases (Prerequisites)

| Phase | File | Lines | Tests |
|-------|------|-------|-------|
| 12a | Core types | in test_phase12ac.pas | T01-T03 |
| 12b | Descriptors | in test_phase12ac.pas | T04-T09 |
| 12c | Hub driver | in test_phase12ac.pas | T10-T13 |
| 12d | Mass storage | usb_mass_storage.pas (214) | T14-T21 |
| 12e | HID | usb_hid.pas (37) | T22-T25 |
| 12f | Audio | usb_audio.pas (28) | T26-T28 |
| 12g | CDC serial | usb_cdc.pas (38) | T29-T31 |
| 12h | Printer | usb_printer.pas (32) | T32-T33 |
| 13a-h | Host controllers | usb_host_controllers.pas (121) | T34-T38 |

38/38 tests. All frameworks written.

## Reference Code in Archive

| Source | Location | Lines |
|--------|----------|-------|
| DOSUSB20 stick.pas | xp-drivers/dosusb20-src/ | 622 |
| DOSUSB20 address.pas | xp-drivers/dosusb20-src/ | 217 |
| DOSUSB20 serdrv.asm | xp-drivers/dosusb20-src/ | 1,338 |
| DOSUSB20 prnusb.asm | xp-drivers/dosusb20-src/ | 816 |
| NE2000 packet drivers | nicDRIVERS/ | multiple |
| Trumpet packet drivers | xp-drivers/trumpet-netstack/ | 10 drivers |
| MS Client DOS | xp-drivers/msclient-dos/ | TCP/IP stack |
