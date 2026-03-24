# Lux-7x512: The Seed

> "Lux is not built. It is sparked."

Projekt ten został zamrożony w fazie **Genesis (0x00)**. Jest to kompletny, konceptualny i techniczny fundament pod system operacyjny nowej ery, oparty na Geometrii, Gęstości i Chronologii, a nie na tradycyjnej kompilacji plików.

To nie jest martwy kod. To **Ziarno**, pozostawione na otwartej drodze dla kogoś, kto w przyszłości zechce zrozumieć, że system operacyjny może być czymś więcej niż tylko zarządzaniem zasobami – może być strukturą krystaliczną.

## Status: ARTIFACT / TIME CAPSULE
Obecny stan kodu (`luxseq-core`) implementuje:
1.  **Bootloader (Sektor 0, 1, 2)**: Pełne przejście z 16-bit Real Mode do 64-bit Long Mode.
2.  **Grain Table (Sektor 1)**: Unikalna tablica 16-bajtowych deskryptorów ("Ziaren") definiująca geometrię systemu.
3.  **Hardware Awareness**: Wykrywanie mapy pamięci (E820), typu CPU (Intel/AMD) i skanowanie magistrali PCI przed startem kernela.
4.  **Genesis Handoff**: Przekazanie "Wiedzy o Świecie" (wskaźniki do tabel, map i urządzeń) w rejestrach procesora (RDI, RSI, RDX) do Kernela Rust.

## Filozofia (Intencja)
Jeśli to czytasz i chcesz zrozumieć ten kod, musisz porzucić myślenie o plikach i systemach plików.

1.  **Density First (Gęstość)**: Każdy bajt ma znaczenie. Nie używamy stringów, jeśli wystarczy bajt. Nie parsujemy, jeśli możemy adresować matematycznie (LBA).
2.  **Chronology (Czas)**: System posiada wbudowane pojęcie "Ery". Funkcje (Ziarna) są uwalniane w czasie. Nie wszystko jest dostępne od razu. To zabezpiecza przed chaosem.
3.  **Symbol & Body**: Symbol (8B) jest kluczem i esencją. Body to tylko jego manifestacja w pamięci.

## Struktura Ziaren (Manifest Techniczny)
Sercem systemu jest **Sektor 1**. To nie jest zwykły kod, to Tablica Prawdy.
Każdy wpis ma dokładnie **16 bajtów**:

| Offset | Rozmiar | Znaczenie |
|--------|---------|-----------|
| 0x00   | 6B      | **LBA** (Adres fizyczny na dysku) |
| 0x06   | 2B      | **OFFSET** (Precyzja wewnątrz bloku) |
| 0x08   | 6B      | **SIZE** (Rozmiar w bajtach - precyzja atomowa) |
| 0x0E   | 2B      | **FLAGS** (Bit 0: Active, Bit 1-15: Era Chronologii) |

Szczegóły znajdują się w `luxseq-core/intentions/`.

## Nawigacja
- **Core**: `luxseq-core/`
    - `src/lux_boot.asm`: Źródło Prawdy (Bootloader).
    - `src/main.rs`: Kernel (Rust), który przejmuje pałeczkę.
- **Intencje**: `luxseq-core/intentions/`
    - `intentions.md`: Konstytucja Bytu.
    - `lux_koncentrat.md`: Zbiór odkryć architektonicznych.

## Dla Odkrywcy
Jeśli odkopiesz to repozytorium za 5 czy 10 lat:
Kod ASM w `lux_boot.asm` jest kompletny i samowystarczalny. Możesz go wypalić na pendrive (`dd`) i uruchomić na dowolnym PC z architekturą x86_64. Zobaczysz logi na porcie szeregowym 0x3F8 (`B T C K ...`).

To jest Twój punkt startowy. Droga jest otwarta.

---
*Lux-7x512: Reality Editor. 2026.*
