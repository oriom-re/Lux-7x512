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