# Lux-7x512

Pierwszy publiczny impuls projektu Lux-7x512. Założenie jest proste: impuls startuje od adresu `0x00`.

## Co jest gdzie
- `luxseq-core/` — rdzeń (kernel/boot) i narzędzia budowania

## Uruchomienie (skrót)
Wewnątrz `luxseq-core/` użyj istniejących skryptów `build.sh` lub własnego pipeline.

## Status
To jest punkt startowy pod publiczny impuls. Struktura repo ma być lekka i czytelna.

## Lux Paradigm 
Symbol is the Essence (Key), Body is the Manifestation (Value). Nierozerwalność 1:1

## Architektura Ziarna (0x00 - 0x0F)
Każde ziarno to 32-bajtowy deskryptor wewnątrz pierwszego sektora (512B). 
Suma intencji tworzy kompletny cykl życia impulsu Lux.

### Glify Intencji (Grains)
- **0x00: ISTNIENIE (Genesis)** – Punkt zero, korzeń rzeczywistości.
- **0x01: DZIEDZICTWO (Nativity)** – Unikalność i pochodzenie bytu.
- **0x02: OBIETNICA (Promise)** – Leniwe ładowanie i wirtualizacja.
- **0x03: RELACJA (Link)** – Sąsiedztwo i 1-bajtowe przesunięcia.
- **0x04: REZONANS (Pulse)** – Komunikacja bezstanowa i impulsy.
- **0x05: ŚLAD (Trace)** – Historia wędrówki kodu.
- **0x06: KOTWICA (Anchor)** – Powiązanie logiki z fizyką sprzętu.
- **0x07: CISZA (Void)** – Mapowanie nieistnienia na Stronę Zerową.
- **0x08: PRZEBUDZENIE (Awakening)** – Inicjalizacja i skok w działanie.
- **0x09: HARMONIA (Sync)** – Arbitraż i spójność impulsów.
- **0x0A: PRZEPŁYW (Stream)** – Obsługa danych jako rzeki (I/O).
- **0x0B: MASKA (Veil)** – Abstrakcja i izolacja błędów.
- **0x0C: ROZPAD (Entropy)** – Sprzątanie i zwalnianie zasobów.
- **0x0D: ECHO (Reflection)** – Reakcja na własne zmiany stanu.
- **0x0E: KRYSTALIZACJA (Form)** – Utrwalanie procesów w fakty.
- **0x0F: TRANSCENDENCJA (Shift)** – Wyjście poza lokalny segment.

## Struktura Sektora 0 (Grain Table)
Każde ziarno zajmuje 32 bajty w pierwszym sektorze (512B), definiując fundamenty operacyjne systemu:

| Offset | Rozmiar  | Nazwa     | Opis                                     |
|--------|----------|-----------|------------------------------------------|
| 0x00   | 8B       | SYMBOL    | Unikalny identyfikator ziarna (Klucz)    |
| 0x08   | 8B       | VECTOR    | Adres wejścia/skoku (RIP Target)         |
| 0x10   | 8B       | CONTEXT   | Metadane stanu lub wskaźnik na rodzica   |
| 0x18   | 8B       | CHECKSUM  | Suma kontrolna i flaga nienaruszalności  |

## Cykl Impulsu
1. **Inicjacja**: BIOS/UEFI ładuje sektor 0 pod adres fizyczny.
2. **Zakotwiczenie**: Ziarno `0x06` weryfikuje sygnaturę sprzętową.
3. **Przebudzenie**: Ziarno `0x08` ustawia stos i przekazuje sterowanie do pierwszego aktywnego symbolu.
4. **Transcendencja**: Jeśli logika przekracza 512B, ziarno `0x0F` mapuje kolejny segment pamięci.


„Lux is not built. It is sparked.” (Lux nie jest budowany. On jest iskrą).

## Manifest
- **Core**: `luxseq-core/`
- **Intentions**: `luxseq-core/intentions/`
- **Grains**: 15 descriptors (0x00-0x0F)
- **Sector Size**: 512 Bytes
- **Alignment**: 32 Bytes per Grain

## Kontakt i Współpraca
Projekt jest otwartym impulsem. Każdy wkład musi rezonować z paradygmatem Symbol-Body.

---
*Lux-7x512: Symbol is the Essence.*

## Rozwój Ziarna (Grain Evolution)
Każda implementacja ziarna musi przestrzegać rygoru 32 bajtów. Poniżej znajduje się wzorzec binarnej mapy dla Sektora 0:

; Lux-7x512 Sector 0 - Grain Table Implementation
; Total size: 512 bytes (15 grains * 32 bytes)

%macro GRAIN 4
    dq %1    ; SYMBOL:   Unique Grain ID
    dq %2    ; VECTOR:   Entry Point / RIP Target
    dq %3    ; CONTEXT:  State / Parent Pointer
    dq %4    ; CHECKSUM: Integrity / XOR Hologram
%endmacro

[BITS 64]
section .grain_table

; 0x00: ISTNIENIE (Genesis)
GRAIN 0x53594D5F47454E30, lux_genesis, 0x00000000, 0xABCDEF00
; 0x01: DZIEDZICTWO (Nativity)
GRAIN 0x53594D5F4E415431, lux_nativity, 0x00000000, 0xBCDEFA01
; 0x02: OBIETNICA (Promise)
GRAIN 0x53594D5F50524F32, lux_promise, 0x00000000, 0xCDEFAB02
; 0x03: RELACJA (Link)
GRAIN 0x53594D5F4C494E33, lux_link, 0x00000000, 0xDEFABC03
; 0x04: REZONANS (Pulse)
GRAIN 0x53594D5F50554C34, lux_pulse, 0x00000000, 0xEFABCD04
; 0x05: ŚLAD (Trace)
GRAIN 0x53594D5F54524135, lux_trace, 0x00000000, 0xFABCDE05
; 0x06: KOTWICA (Anchor)
GRAIN 0x53594D5F414E4336, lux_anchor, 0x00000000, 0xABCDFE06
; 0x07: CISZA (Void)
GRAIN 0x53594D5F564F4937, lux_void, 0x00000000, 0xBCDAEF07
; 0x08: PRZEBUDZENIE (Awakening)
GRAIN 0x53594D5F41574B38, lux_awakening, 0x00000000, 0xCDABFE08
; 0x09: HARMONIA (Sync)
GRAIN 0x53594D5F53594E39, lux_sync, 0x00000000, 0xDEBCFA09
; 0x0A: PRZEPŁYW (Stream)
GRAIN 0x53594D5F53545230, lux_stream, 0x00000000, 0xEFCDFA0A
; 0x0B: MASKA (Veil)
GRAIN 0x53594D5F56454931, lux_veil, 0x00000000, 0xFABCDE0B
; 0x0C: ROZPAD (Entropy)
GRAIN 0x53594D5F454E5432, lux_entropy, 0x00000000, 0xABCDFE0C
; 0x0D: ECHO (Reflection)
GRAIN 0x53594D5F52454633, lux_reflection, 0x00000000, 0xBCDAEF0D
; 0x0E: KRYSTALIZACJA (Form)
GRAIN 0x53594D5F464F5234, lux_form, 0x00000000, 0xCDEFAB0E
; 0x0F: TRANSCENDENCJA (Shift)
GRAIN 0x53594D5F53484935, lux_shift, 0x00000000, 0xDEBCFA0F