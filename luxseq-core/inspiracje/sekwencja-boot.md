# Inspiracje dla sekwencji boot

1. Reset → wejście BIOS/UEFI → załadowanie sektora 0 pod 0x7C00 lub ustaloną fizyczną bazę.  
2. Grain 0x06 (Anchor) sprawdza sygnaturę sprzętu prostą operacją XOR; wynik zapisuje w CONTEXT 0x00.  
3. Grain 0x08 (Awakening) ustawia stos, rejestry segmentowe i przekazuje sterowanie do pierwszego SYMBOLU z flagą aktywną.  
4. Grain 0x03 (Link) utrzymuje krótkie skoki: w obrębie pierwszych 64 KiB używaj near jump; dalej — table-driven skoki.  
5. Grain 0x04 (Pulse) emituje bitowy heartbeat co M cykli; heartbeat jest także watchdogiem dla 0x09.  
6. Grain 0x09 (Sync) arbitruje impulsy: najniższy set bit w kolejce wygrywa, pozostałe odkładają się do następnej rundy.  
7. Grain 0x0A (Stream) trzyma I/O jako strumień: brak blokad, tylko flagi gotowości i proste „try once” retry.  
8. Grain 0x0B (Veil) tłumaczy błędy na 2-bitową semantykę, żeby cała ścieżka była binarna w decyzjach.  
9. Grain 0x0D (Echo) rehashuje kod i porównuje z CHECKSUM; w razie różnicy — skok do 0x07 (cisza) lub 0x0C (rozpad).  
10. Grain 0x0F (Shift) rozszerza pamięć: dodaje kolejne 512B segmenty jako warstwy; nie duplikuje tabeli grainów.  

Notatka: celem jest bootstrap, który można przeczytać jak geometrię — krótko, rytmicznie, bez gałęziowania w bok.
