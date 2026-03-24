DONE: Uporządkować Grain Table w sektorze 1: wdrożono format **16-bajtowy** (Density First). [LBA 6B | OFF 2B | SIZE 6B | FLG 2B].
DONE: Przestawić odczyty sektorów na LBA (INT 13h Extensions, AH=42h).
DONE: Przenieść stos real-mode w sektorze 0 wyżej (mov sp, 0x7C00 -> 0x9000+).
DONE: Zrobić sanity-check wyników int 13h (retry loop).
W sektorze 2 (config_entry) dorzucić walidację rozmiaru kernela z grain table vs. realny odczyt; loguj błąd na serial jeśli al != requested.
Uporządkować budowę PML4: dopisz flagi P/W w wyższych DWORD-ach (obecnie high dword = 0); zadbaj o align 4 KiB i zeroowanie 64-bitowe (stosuj stosq zamiast stosd).
GDT: dodać 64-bitowy code/data i załadować go już w real-mode przed skokiem (masz, ale warto zaktualizować komentarz i sprawdzić limit). Po skoku do long mode dodać swapgs tylko jeśli w przyszłości planujesz kernel/user.
Kernel handoff: zdefiniuj stub _start w Rust/asm na fizycznym 0x20000 i po skanie PCI zrób call do niego; obecnie zostajemy w .hang.
PCI scan: schowaj wyniki w małej tablicy pod np. 0x9200 (VendorID/DeviceID), żeby Anchor 0x06 miał CONTEXT; na serial zostaw tylko sygnał końcowy.
Trace 0x05: dorzuć ring buffer 256B (np. 0x9300) i makro TRACE <byte> dla kluczowych kroków (T, C, K, M, P, J, !); to pomoże debugować na realnym T430.
Veil 0x0B: standaryzuj kody błędów (00 ok, 01 retry, 10 degrade, 11 halt) i użyj ich w ścieżkach disk read / E820 / PCI.
Build/test: zaktualizuj build.sh tak, by sklejał sektor 0/1/2 z lux_boot.asm do disk.raw, uruchom QEMU (BIOS) i zapisz log z serial; następnie test boot na T430 z tego samego obrazu.
