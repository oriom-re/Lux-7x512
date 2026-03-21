[BITS 16]
org 0x7C00

; ---------------------------------------------------------
; LUX-7x512 BOOTLOADER (SECTOR 0)
; Rola: Załadować Grain Table (Sektor 1) i Config (Sektor 2).
; ---------------------------------------------------------

%define STACK_ADDR 0x2000000  ; 32 MiB - solidny stos dla Long Mode (z bootloader.asm)
%define SERIAL_PORT 0x3f8

start:
    jmp short main
    nop

main:
    mov [boot_drive], dl ; Zapisz dysk startowy
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; --- TESTY / DEBUG (Inspiracja bootloader.asm) ---
    call init_serial    ; Włączamy UART (COM1)
    mov al, 'B'         ; 'B' = Boot Start
    call print_serial_char

    ; 1. Załaduj GRAIN TABLE (Sektor 1 z dysku -> 0x7E00 w RAM)
    mov eax, 1          ; LBA = 1
    mov cx, 1           ; Ilość sektorów = 1
    xor ax, ax
    mov es, ax          ; ES:BX = 0x0000:0x7E00
    mov bx, 0x7E00
    call read_lba

    mov al, 'T'         ; 'T' = Table Loaded
    call print_serial_char
    mov si, msg_grain_loaded
    call print_string

    ; 2. Odczytaj i załaduj CONFIG (Grain 0x00)
    mov bx, 0x7E00      ; Wskaźnik na początek tabeli
    mov eax, [bx + 16]  ; LBA Start Configu
    mov cx, [bx + 28]   ; Rozmiar Configu (w sektorach)
    xor ax, ax
    mov es, ax          ; ES:BX = 0x0000:0x8000
    mov bx, 0x8000
    call read_lba

    mov al, 'C'         ; 'C' = Config Loaded
    call print_serial_char
    mov si, msg_config_loaded
    call print_string

    ; 4. Skok do Configu (Sektor 2)
    ; Config przejmuje sterowanie, ładuje kernela i wchodzi w Long Mode.
    jmp 0x0000:0x8000

; --- PROCEDURY POMOCNICZE (Port z bootloader.asm) ---
read_lba:
    ; Wejście: EAX = LBA, CX = ilość sektorów, ES:BX = adres docelowy
    pusha
    mov byte [retry_count], 3 ; Ustaw licznik prób

.retry_loop:
    ; Przygotuj Disk Address Packet (DAP) w bezpiecznym miejscu (np. 0x7000)
    mov di, 0x7000
    mov byte [di], 0x10     ; Rozmiar pakietu (16 bajtów)
    mov byte [di+1], 0      ; Zarezerwowane
    mov [di+2], cx          ; Ilość sektorów
    mov [di+4], bx          ; Offset docelowy
    mov [di+6], es          ; Segment docelowy
    mov [di+8], eax         ; LBA (dolne 32 bity)
    mov dword [di+12], 0    ; LBA (górne 32 bity, na razie 0)

    mov ah, 0x42            ; Funkcja INT 13h: Extended Read
    mov dl, [boot_drive]    ; Dysk startowy
    mov si, di              ; DS:SI wskazuje na DAP
    int 0x13
    jnc .success            ; Jeśli Carry Flag=0, odczyt udany

    ; Błąd - resetujemy kontroler i próbujemy ponownie
    xor ax, ax              ; Funkcja AH=00h: Reset Disk System
    mov dl, [boot_drive]
    int 0x13
    dec byte [retry_count]
    jnz .retry_loop
    jmp disk_error          ; Wszystkie próby zawiodły
.success:
    popa
    ret

init_serial:
    push dx
    push ax
    mov dx, 0x3fb
    mov al, 0x80    ; DLAB on
    out dx, al
    mov dx, SERIAL_PORT
    mov al, 0x03    ; 38400 baud
    out dx, al
    mov dx, 0x3f9
    xor al, al
    out dx, al
    mov dx, 0x3fb
    mov al, 0x03    ; 8N1
    out dx, al
    pop ax
    pop dx
    ret

print_serial_char:
    push dx
    mov dx, SERIAL_PORT
    out dx, al
    pop dx
    ret

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
    mov al, 'E'
    call print_serial_char
    mov si, msg_error
    call print_string
    cli
    hlt

msg_grain_loaded:  db "Lux: Table OK.", 13, 10, 0
msg_config_loaded: db "Lux: Config OK. Passing torch...", 13, 10, 0
msg_error:        db "Lux: Disk Error!", 0

boot_drive: db 0
retry_count: db 0

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
    
    ; Reset segmentów dla pewności
    xor ax, ax
    mov ds, ax

    ; 1. Załaduj KERNEL (Grain 0x01)
    ; Kernel ładujemy do 0x20000 (128KB), żeby nie nadpisać BIOSu ani Configu
    mov bx, 0x7E00
    mov eax, [bx + 32 + 16] ; LBA Kernela (Grain 1 offset 16)
    mov cx, [bx + 32 + 28]  ; Size Kernela
    
    ; Ustawiamy segment:offset docelowy -> 0x2000:0x0000 (0x20000)
    push es
    mov bx, 0x2000
    mov es, bx
    xor bx, bx
    call read_lba
    pop es

    ; (Brak obsługi błędów dla czytelności - zakładamy, że dysk działa)
    
    mov dx, SERIAL_PORT
    mov al, 'K'         ; 'K' = Kernel Loaded
    out dx, al

    ; 2. Mapa Pamięci E820 (Pobieramy zanim wejdziemy w Protected Mode)
    call get_memory_map
    
    mov dx, SERIAL_PORT
    mov al, 'M'         ; 'M' = Map E820 Done
    out dx, al

    ; 2a. Wykrywanie CPU (CPUID) - Grain 0x01 Logic
    call detect_cpu


    ; 3. A20 Gate (Szybka metoda)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; 4. Budowanie Tabel Stronicowania (PML4)
    ; Używamy adresu 0x1000 dla tablic stronicowania
    ; Grain 0x02 (Promise): Mapujemy całe dolne 4 GiB dla Kernela.
    ; Zakres tablic: 0x1000 - 0x7000 (24 KB)
    
    ; Czyścimy pamięć dla tablic
    mov di, 0x1000
    xor ax, ax
    mov cx, 6144        ; 24 KB / 4 bajty = 6144 dwords
    rep stosd

    ; PML4 (0x1000) -> PDP (0x2000)
    ; 0x03 = Present | RW | Supervisor (US=0) -> Tylko Kernel ma tu wstęp
    mov dword [0x1000], 0x2003

    ; PDP (0x2000) -> 4 x PD (0x3000, 0x4000, 0x5000, 0x6000)
    ; Każdy wpis PDP pokrywa 1 GiB. Ustawiamy 4 wpisy = 4 GiB.
    mov dword [0x2000], 0x3003
    mov dword [0x2008], 0x4003
    mov dword [0x2010], 0x5003
    mov dword [0x2018], 0x6003

    ; PD (0x3000..0x6FFF) -> Mapujemy 4 GiB na Huge Pages (2MB)
    ; 0x00000000 | Present | Writable | Huge Page (bit 7)
    ; Flaga 0x83 = P(1) | RW(1) | US(0) | Huge(1)
    mov eax, 0x83           ; Start: 0x00000000 + flagi
    mov di, 0x3000          ; Adres PD
    mov cx, 2048            ; 4 * 512 wpisów = 2048 stron po 2MB = 4 GiB
.map_pd:
    mov [di], eax           ; Zapisz wpis (Low 32 bit)
    mov dword [di + 4], 0   ; High 32 bit (0)
    add eax, 0x200000       ; +2MB fizycznie
    add di, 8               ; Następny wpis w tabeli
    loop .map_pd

    mov dx, SERIAL_PORT
    mov al, 'P'         ; 'P' = Paging Setup
    out dx, al

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

    mov dx, SERIAL_PORT
    mov al, 'J'         ; 'J' = Jump to Long Mode
    out dx, al

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

detect_cpu:
    pusha
    xor eax, eax    ; CPUID Function 0: Get Vendor ID
    cpuid           ; Returns: EBX, EDX, ECX (ASCII string)
    
    ; Zapisz wynik pod stałym adresem 0x9100 (zaraz za mapą pamięci)
    ; To będzie nasz "Context" dla ziarna Nativity
    mov [0x9100], ebx
    mov [0x9104], edx
    mov [0x9108], ecx

    ; Prosta heurystyka dla logów
    cmp ebx, 0x756e6547 ; "Genu" (GenuineIntel)
    je .intel
    cmp ebx, 0x68747541 ; "Auth" (AuthenticAMD)
    je .amd
    
    mov al, '?'         ; Nieznany
    jmp .print

.intel:
    mov al, 'I'
    jmp .print
.amd:
    mov al, 'A'
.print:
    mov dx, SERIAL_PORT
    out dx, al
    popa
    ret

[BITS 64]
long_mode_start:
    ; Jesteśmy w 64-bitach!
    mov ax, 0x10        ; Segment danych z GDT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Inspiracja z bootloader.asm: Ustawienie stosu w Long Mode
    mov rsp, STACK_ADDR 
    mov rbp, rsp
    
    mov dx, SERIAL_PORT
    mov al, '!'         ; '!' = We are inside 64-bit!
    out dx, al

    ; --- SCAN PCI (Grain 0x06 Logic) ---
    ; Zanim skoczymy do (brakującego) kernela, poszukajmy sprzętu.
    call pci_scan_bus0

    ; Kernel not ready - enter Meditation State
    mov dx, SERIAL_PORT
    mov al, '.'
    out dx, al
.hang:
    hlt
    jmp .hang

pci_scan_bus0:
    ; Skanuje Bus 0, Device 0-31, Func 0
    ; Port 0xCF8 (Addr), 0xCFC (Data)
    xor rbx, rbx        ; Device counter (0-31)
.next_dev:
    mov eax, 0x80000000 ; Enable Bit
    mov edx, ebx
    shl edx, 11         ; Device << 11
    or eax, edx         ; Bus 0 implies bits 16-23 are 0
    
    mov dx, 0xCF8
    out dx, eax
    mov dx, 0xCFC
    in eax, dx

    cmp ax, 0xFFFF      ; Vendor ID = 0xFFFF means empty
    je .skip
    
    ; Urządzenie znalezione!
    mov dx, SERIAL_PORT
    mov al, '+'
    out dx, al
.skip:
    inc rbx
    cmp rbx, 32
    jl .next_dev
    ret

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
