ENTRY(_start)

SECTIONS
{
    . = 0x8000;

    .text : {
        *(.text.startup)        
        *(.text.get_mac)
        *(.text .text.*)
        *(.text.pci_scan)
        
    }

    .got ALIGN(0x100) : {
        *(.got .got.*)
    }

    .rodata ALIGN(0x1000) : {
        *(.rodata .rodata.*)
    }

    .data ALIGN(0x1000) : {
        *(.data .data.*)
    }

    .bss ALIGN(0x1000) : {
        *(.bss .bss.*)
        *(COMMON)
    }

    /DISCARD/ : {
        *(.dynamic)
        *(.dynsym)
        *(.dynstr)
        *(.gnu.hash)
        *(.hash)
        *(.interp)
        *(.note.*)
        *(.comment)
        *(.debug*)
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}
