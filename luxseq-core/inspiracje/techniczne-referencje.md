# Kierunki techniczne do eksploracji

Zestaw haseł do dalszych kwerend — bez linków, żeby zachować lekkość repo.

- Boot/BIOS: 16-bit real mode → skok do 64-bit long mode z minimalnym GDT/IDT.  
- Minimalne runtime: brak libc; własne `memset/memcpy`; stos ustawiony ręcznie.  
- Layout pamięci: pierwsze 64 KiB na bootstrap, kolejne warstwy po 512B mapowane przez 0x0F.  
- Integrity: prosty XOR lub CRC32 w polu CHECKSUM na każdy glif; hash kodu porównywany cyklicznie (0x0D).  
- I/O: port-mapped I/O jako pierwszy strumień; fallback na MMIO; każde urządzenie opisane 16-bitową sygnaturą.  
- Logowanie: jedno słowo na impuls; opcjonalny ring buffer 256 wpisów w niskiej pamięci.  
- Testy: goldeny binarne 512B; property-based testy dla mapowania glifów na akcje; symulacja real-mode w QEMU.  
- Toolchain: `nasm` lub `yasm` do sektora 0; `rustc nightly` z `#![no_std]` dla warstw powyżej; `bootimage` jako most.  
- Deploy: obraz dysku 64 MiB, pierwsze 512B nadpisywane przez builder; GCP bucket jako artefakt binarny; checksum w nazwie pliku.  
- Bezpieczeństwo: brak ukrytych trybów — wszystkie skoki jawne; brak przerwań maskujących, tylko jawne wektory.
