[BITS 16]
org 0x7C00

start:
    jmp begin_lux    ; 2 bajty: Skok nad tabelą ziaren
    nop                    ; 1 bajt: Wyrównanie (razem 3 bajty)

; ---------------------------------------------------------
; TWOJA TABLICA ZIAREN (Grain Table)
; Zaczyna się od 0x7C03 
; ---------------------------------------------------------

times 8 db 0x00           ; UUID Placeholder
dq 0x0000000000000001      ; Start LBA

dd 0x0000000000000001              ; Flags: Bootable, System
dd 0x0000000000000001              ; Flags: Bootable, System

times 14 * 32 db 0     ; Twoje pierwsze 15 ziaren (480 bajtów)

; GRAIN 15 (Ostatnie ziarno - 32 bajty)
; Tutaj musisz "uszczuplić" o te 3 bajty z początku sektora!
times 16 db 0x00           ; UUID Placeholder
dq 0x00000000000000FF      ; Start LBA
dd 0x01              ; Length (0 sectors)
dd 0xAA55                  ; Signature
    
; ---------------------------------------------------------
; POCZĄTEK PROCESU (Tu ląduje jmp short)
; ---------------------------------------------------------
begin_lux:
    ; TU ZACZYNASZ: 16 -> 32 -> 64
    cli                    ; Wyłącz przerwania
    ; ... ładowanie GDT, przejście w Long Mode ...
    mov ax, 0