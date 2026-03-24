[bits 16]
[org 0x7c00]

%define PML4_ADDR 0x100000    ; A16_A0_A0      16_0_0       ML4 dla pierwszego 1 GiB (2 MiB strony)
%define PDPT_ADDR 0x101000    ; A16_A16_A0     16_16_0      PDPT dla pierwszego 1 GiB (2 MiB strony)
%define PD_ADDR   0x102000    ; A16_A32_A0     16_32_0      PD dla pierwszego 1 GiB (2 MiB strony)
%define STACK_ADDR 0x2000000  ; A2_A0_A0_A0    2_0_0_0      Stos
%define MSR_EFER 0xc0000080   ; B92_A0_A0_B28 192_0_0_128  Model-Specific Register dla EFER (Extended Feature Enable Register)
%define EFER_LME 0x100        ; A1_A0         1_0          Long Mode Enable
%define CR4_PAE 0x20          ; A32           32           PAE jest wymagane do włączenia LME

start:
    cli
    
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00
    mov [boot_drive], dl

    mov dx, 0x3f8
    mov al, 'B' 
    out dx, al
    
    call init_serial
    call enable_a20
    
    xor ax, ax           ; reset kontroler dysku
    mov dl, [boot_drive]
    
    int 0x13

    mov ah, 0x02
    mov al, 0x40         ; wczytaj kilka sektorów (kernel startuje w sektorze 2)
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, [boot_drive]
    mov bx, 0x8000
    int 0x13
    jc disk_error

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

 
    mov dx, 0x3f8
    mov al, 'O'
    out dx, al
    
    jmp 0x08:protected_mode_entry

; jeśli coś się nie uda

disk_error:
    mov dx, 0x3f8
    mov al, 'E'
    out dx, al
    hlt
    jmp $

init_serial:
    mov dx, 0x3fb
    mov al, 0x80    ; Włącz DLAB
    out dx, al
    ; Ustawiamy prędkość (np. 38400 baud)
    mov dx, 0x3f8
    mov al, 0x03    ; Dzielnik (Lo byte)
    out dx, al
    mov dx, 0x3f9
    xor al, al      ; Dzielnik (Hi byte)
    out dx, al

    ; --- KLUCZOWY MOMENT ---
    mov dx, 0x3fb
    mov al, 0x03    ; Wyłącz DLAB + ustaw 8N1 (8 bitów, brak parzystości, 1 stop)
    out dx, al
    ; -----------------------
    ret

serial_ok:
    mov dx, 0x3f8
    mov al, 'P'
    out dx, al
    mov al, 'O'
    out dx, al
    mov al, 'K'
    out dx, al
    mov al, ' '
    out dx, al
    ret

enable_a20:
    mov dx, 0x3f8
    mov al, 'O'
    out dx, al
    
    mov dx, 0x92
    in al, dx
    or al, 0x02
    out dx, al
    ret

[BITS 32]
protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    call setup_page_tables
    call enable_long_mode
    mov eax, cr0
    
    or eax, 0x80000000
    mov cr0, eax
    mov dx, 0x3f8
    mov al, 'T'
    out dx, al

    jmp 0x18:long_mode_entry

setup_page_tables:
    mov eax, PDPT_ADDR | 0x3   ; PML4[0] → PDPT
    mov [PML4_ADDR], eax
    mov dword [PML4_ADDR + 4], 0

    ; --- PDPT[0] (0-1 GiB) ---
    mov eax, 0x83
    mov [PDPT_ADDR], eax
    mov dword [PDPT_ADDR + 4], 0 ; 
    
    ; --- PDPT[1] (1-2 GiB) ---
    mov eax, 0x40000000 | 0x83  ; 1 GiB fizycznie
    mov [PDPT_ADDR + 8], eax    ; Następny slot (8 bajtów dalej)
    mov dword [PDPT_ADDR + 12], 0

    ; --- PDPT[2] (2-3 GiB) ---
    mov eax, 0x80000000 | 0x83  ; 2 GiB fizycznie
    mov [PDPT_ADDR + 16], eax
    mov dword [PDPT_ADDR + 20], 0

    ; --- PDPT[3] (3-4 GiB) --- tu siedzi Twoje Wideo i Sieć!
    mov eax, 0xC0000000 | 0x83  ; 3 GiB fizycznie
    mov [PDPT_ADDR + 24], eax
    mov dword [PDPT_ADDR + 28], 0

    ; --- PDPT[4..511] są puste, więc nie musimy ich ustawiać, bo domyślnie będą 0 (nieobecne)

    xor eax, eax
    mov [PD_ADDR], eax ; PD[0] = 0x00000000
    mov dword [PD_ADDR + 4], 0

    mov eax, PML4_ADDR
    mov cr3, eax
    ret

enable_long_mode:
    mov eax, cr4
    or eax, CR4_PAE
    mov cr4, eax

    mov ecx, MSR_EFER
    rdmsr
    or eax, EFER_LME
    xor edx, edx
    wrmsr
    ret

[BITS 64]
long_mode_entry:
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    xor rbp, rbp
    
    ; ... (ustawienie segmentów ds, es, ss na 0x20) ...
    mov dx, 0x3f8
    mov al, ' '
    out dx, al
    mov al, 'O'
    out dx, al
    mov al, 'K'
    out dx, al

    
    mov rsp, STACK_ADDR    ; Ustawiamy wierzchołek stosu
    mov rbp, rsp        ; Opcjonalnie: ustawiamy bazę ramki    
    mov rax, 0x8000
    
    jmp rax ; Skaczemy do naszego 64-bitowego kernela

gdt_start:
    dq 0

    ; 32-bit code
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x9a
    db 0xcf
    db 0x00

    ; 32-bit data
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x92
    db 0xcf
    db 0x00

    ; 64-bit code
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x9a
    db 0x20
    db 0x00

    ; 64-bit data
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x92
    db 0x8f
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive: db 0

times 510 - ($ - $$) db 0 ; Wyrównanie do 510 bajtów i sygnatura
dw 0xaa55
