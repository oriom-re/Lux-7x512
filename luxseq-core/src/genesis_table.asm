; Lux-7x512 Sector 0 - Grain Table Implementation
; Total size: 512 bytes (15 grains * 32 bytes + Jump Code + Sector Signature)

SECTION .data
ALIGN 32

; Grain Table Structure:
; Each entry is 32 bytes:
; [0-15]  Grain UUID / Hash
; [16-23] Start LBA (Logical Block Address)
; [24-27] Length in Sectors
; [28-31] Flags & Attributes

grain_table_start:

; Grain 0: Boot Loader / Kernel Image
db 0x33, 0x6d, 0xd0, 0x93, 0x97, 0xf9, 0x49, 0x03, 0x83, 0x56, 0xcb, 0xa9, 0x4d, 0xf0, 0xaa, 0x11
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

dq 0x00000000000000A9      ; Start LBA
dd 0x00000040              ; Length (64 sectors)
dd 0x00000008              ; Flags: System, Driver

; Grain 3: Drivers
times 16 db 0x00           ; UUID Placeholder

; Fill remaining 14 grains (14 * 32 = 448 bytes)
times 11 * 32 db 0

; Jump Code

; Sector Signature
times 510-($-$$) db 0
dw 0xAA55

; Boot Loader / Kernel Image


; Lux-7x512 Sector 1 - 129 - Initial Logic Execution
; Offset: 0x200 (512 bytes)

[BITS 16]
[ORG 0x8000]

entry_point:
    ; The bootloader jumps here after entering Long Mode.
    ; We are now in 64-bit mode at address 0x8000.
    
    ; Signal entry into the kernel via serial
    mov dx, 0x3f8
    mov al, 'G'
    out dx, al
    mov al, 'E'
    out dx, al
    mov al, 'N'
    out dx, al

    ; Initialize the Lux environment
    call lux_awakening

    ; Infinite loop if stream returns
    cli
    hlt
    jmp $

; Data context for the grains
section .data
grain_context_1: dq 0
grain_context_2: dq 0

section .text


[BITS 64]
section .manifestation

lux_genesis:
    ; Initialize CPU registers to a known state
    xor rax, rax
    mov ds, ax
    mov es, ax
    mov ss, ax
    ; Set up the stack for the Awakening grain
    mov rsp, 0x7C00 
    ret

lux_nativity:
    ; Generate Unique Identity from CPUID
    mov eax, 0x01
    cpuid
    mov [rel grain_context_1], rbx ; Store identity in Context
    ret

lux_awakening:
    ; The Spark: Jump to the first task in the stream
    call lux_genesis
    call lux_anchor
    jmp lux_stream

; Placeholder for remaining grain vectors
lux_promise:    iretq
lux_link:       iretq
lux_pulse:      iretq
lux_trace:      iretq
lux_anchor:     iretq
lux_void:       iretq
lux_sync:       iretq
lux_stream:     iretq
lux_veil:       iretq
lux_entropy:    iretq
lux_reflection: iretq
lux_form:       iretq
lux_shift:      iretq