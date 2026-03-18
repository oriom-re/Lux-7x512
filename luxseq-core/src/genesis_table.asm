; Lux-7x512 Sector 0 - Grain Table Implementation
; Total size: 512 bytes (16 grains * 32 bytes + Jump Code + Sector Signature)

SECTION .data
ALIGN 32

; Grain Table Structure:
; Each entry is 32 bytes:
; [0-15]  Grain UUID / Hash 16 bytes
; [16-23] Start LBA (Logical Block Address) 8 bytes
; [24-27] Length in Sectors 4 bytes
; [28-31] Flags & Attributes 4 bytes


grain_table_start:

; Grain 0: Boot Loader / Kernel Image
times 16 db 0x00           ; UUID Placeholder
dq 0x0000000000000001      ; Start LBA
dd 0x00000080              ; Length (128 sectors)
dd 0x00000001              ; Flags: Bootable, System

; Grain 1: System Configuration
times 16 db 0x00           ; UUID Placeholder
dq 0x0000000000000081      ; Start LBA
dd 0x00000008              ; Length (8 sectors)
dd 0x00000002              ; Flags: Read-Only

; Grain 2: PNG Map Table
times 16 db 0x00           ; UUID Placeholder
dq 0x0000000000000089      ; Start LBA
dd 0x00000020              ; Length (32 sectors)
dd 0x00000004              ; Flags: Metadata

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver


; Grain 15: Jmp
times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000FF      ; Start LBA
dd 0x00000000              ; Length (0 sectors)
dd 0xAA550000              ; Flags: Jump Code






