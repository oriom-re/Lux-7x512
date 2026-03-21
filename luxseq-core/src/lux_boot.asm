[BITS 16]
org 0x7C00

; ---------------------------------------------------------
; LUX-7x512 BOOTLOADER (SECTOR 0)
; Rola: Załadować Grain Table (Sektor 1) i Config (Sektor 2).
; ---------------------------------------------------------

start:
    jmp short main
    nop

main:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; 1. Załaduj GRAIN TABLE (Sektor 1 z dysku -> 0x7E00 w RAM)
    mov ah, 0x02        ; Funkcja: Odczyt sektorów
    mov al, 0x01        ; Ilość: 1 sektor (512 bajtów - cała tabela)
    mov ch, 0x00        ; Cylinder 0
    mov cl, 0x02        ; Sektor 2 (To jest fizycznie Sektor 1 LBA)
    mov dh, 0x00        ; Głowica 0
    mov bx, 0x7E00      ; Adres docelowy: Tuż za bootloaderem
    int 0x13
    jc disk_error

    mov si, msg_grain_loaded
    call print_string

    ; 2. Odczytaj CONFIG (Grain 0x00)
    ; Tabela jest pod 0x7E00. Config to pierwsze ziarno.
    mov bx, 0x7E00      ; Wskaźnik na początek tabeli
    mov eax, [bx + 16]  ; LBA Start Configu
    mov cx, [bx + 28]   ; Rozmiar Configu (w sektorach)

    ; Konwersja LBA -> CHS (Uproszczona: LBA+1 dla małych wartości)
    inc ax              ; BIOS Sector start

    ; 3. Załaduj CONFIG do 0x8000
    mov ah, 0x02        ; Read
    mov al, cl          ; Ilość sektorów
    mov ch, 0x00
    mov cl, al          ; Sektor startowy
    mov dh, 0x00
    mov bx, 0x8000      ; Adres docelowy Configu
    int 0x13
    jc disk_error

    mov si, msg_config_loaded
    call print_string
    rep movsb

    ; 4. Skok do Configu (Sektor 2)
    ; Config przejmuje sterowanie, ładuje kernela i wchodzi w Long Mode.
    jmp 0x0000:0x8000

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

disk_error:
    mov si, msg_error
    call print_string
    cli
    hlt

msg_grain_loaded:  db "Lux: Table OK.", 13, 10, 0
msg_config_loaded: db "Lux: Config OK. Passing torch...", 13, 10, 0
msg_error:        db "Lux: Disk Error!", 0

; Wyrównanie do 510 bajtów i sygnatura
times 510 - ($ - $$) db 0
dw 0xAA55




; =========================================================
; SEKTOR 1 - GRAIN TABLE (0x7E00 w pamięci)
; =========================================================
; Tutaj zaczyna się fizycznie drugi sektor w pliku binarnym.

; --- GRAIN 0x00: CONFIG / PRE-BOOT ---
db "SYM_CONF"         ; 8 bajtów Symbol
dq 0x0000000000000001 ; UUID
dq 0x0000000000000002 ; OFFSET 16: LBA Start (Sektor 2 - bo 0=MBR, 1=Table)
dd 0x00000001         ; OFFSET 24: Flags (Bootable)
dd 0x00000001         ; OFFSET 28: Size (1 sektor)

; --- GRAIN 0x01: KERNEL (Rust) ---
db "SYM_KERN"         ; 8 bajtów Symbol
dq 0x0000000000000002 ; UUID
dq 0x0000000000000003 ; OFFSET 16: LBA Start (Sektor 3 - bo 0=MBR, 1=Table, 2=Genesis)
dd 0x00000000         ; OFFSET 24: Flags
dd 0x00000010         ; OFFSET 28: Size (16 sektorów kernela)

; ... reszta ziaren (dopełnienie) ...
times 512 - ($ - $$ - 512) db 0

; =========================================================
; SEKTOR 2 - CONFIG & LONG MODE SETUP (0x8000 w pamięci)
; =========================================================
; Tu dzieje się magia: E820, Paging, Switch to 64-bit.

config_entry:
    ; Jesteśmy w 16-bit Real Mode pod adresem 0x8000
    
    ; 1. Załaduj KERNEL (Grain 0x01)
    ; Kernel ładujemy do 0x20000 (128KB), żeby nie nadpisać BIOSu ani Configu
    mov bx, 0x7E00
    mov eax, [bx + 32 + 16] ; LBA Kernela (Grain 1 offset 16)
    mov cx, [bx + 32 + 28]  ; Size Kernela
    
    inc ax              ; LBA -> Sector number
    
    push es
    mov bx, 0x2000
    mov es, bx
    xor bx, bx          ; ES:BX = 0x2000:0000 -> 0x20000 fizycznie
    
    mov ah, 0x02
    mov al, cl          ; Ilość sektorów
    mov ch, 0x00
    mov cl, al          ; Sektor startowy
    mov dh, 0x00
    int 0x13
    pop es
    ; (Brak obsługi błędów dla czytelności - zakładamy, że dysk działa)

    ; 2. Mapa Pamięci E820 (Pobieramy zanim wejdziemy w Protected Mode)
    call get_memory_map


    ; 3. A20 Gate (Szybka metoda)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; 4. Budowanie Tabel Stronicowania (PML4)
    ; Używamy adresu 0x1000 dla tablic stronicowania
    ; Mapowanie tożsamościowe (Identity Map) pierwszych 2MB
    
    ; Czyścimy pamięć dla tablic (0x1000 - 0x4000)
    mov di, 0x1000
    xor ax, ax
    mov cx, 4096

    ; PML4 (0x1000) -> PDP (0x2000)
    mov dword [0x1000], 0x2003  ; Adres 0x2000 + Present + Writable

    ; PDP (0x2000) -> PD (0x3000)
    mov dword [0x2000], 0x3003  ; Adres 0x3000 + Present + Writable

    ; PD (0x3000) -> Mapujemy 2MB Huge Page
    ; 0x00000000 | Present | Writable | Huge Page (bit 7)
    mov dword [0x3000], 0x00000083

    ; 5. Przygotowanie do Long Mode
    ; Ładujemy GDT (Global Descriptor Table)
    cli 
    lgdt [gdt_descriptor]

    ; Włącz PAE (Physical Address Extension) w CR4
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Włącz Long Mode w EFER MSR (Model Specific Register 0xC0000080)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8      ; Bit 8 = LME (Long Mode Enable)
    wrmsr

    ; Włącz Stronicowanie (Paging) w CR0
    mov eax, 0x1000     ; Adres PML4
    mov cr3, eax

    mov eax, cr0
    or eax, 1 << 31     ; Bit 31 = PG (Paging)
    or eax, 1 << 0      ; Bit 0  = PE (Protected Mode)
    mov cr0, eax

    ; 6. TRANSCENDENCJA -> Skok do 64-bitowego kodu
    jmp 0x08:long_mode_start

get_memory_map:
    mov di, 0x9000      ; Tu zapiszemy mapę od BIOS-u
    xor ebx, ebx        ; Start od zera
    mov edx, 0x534D4150 ; Sygnatura 'SMAP'
.loop:
    mov eax, 0xE820
    mov ecx, 24         ; Rozmiar rekordu
    int 0x15
    jc .done            ; Błąd lub koniec
    add di, 24          ; Następny slot
    test ebx, ebx       ; Jeśli ebx=0, to koniec mapy
    jnz .loop
.done:
    ret
    ; Teraz system WIE, ile ma RAM-u, zanim w ogóle powstanie!

[BITS 64]
long_mode_start:
    ; Jesteśmy w 64-bitach!
    mov ax, 0x10        ; Segment danych z GDT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Skok do Kernela załadowanego pod 0x20000
    mov rax, 0x20000
    jmp rax

; --- GDT DATA ---
align 4
gdt_start:
    dq 0x0000000000000000 ; Null Descriptor
gdt_code:
    dq 0x0020980000000000 ; Code Segment (64-bit, Present, Exec/Read)
gdt_data:
    dq 0x0000920000000000 ; Data Segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Wyrównanie Sektora 2 do 512 bajtów

