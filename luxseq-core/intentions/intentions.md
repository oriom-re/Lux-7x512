# Lux Intentions Charter: The Final Constitution

## Konstytucja Bytu: Density First & Chronology
**DENSITY_FIRST:** Jednostką prawdy jest **16-bajtowy rekord** (Matematyczna Perła). 
W sektorze 512B mieści się dokładnie **32 Symbole**.

| Offset (B) | Rozmiar | Nazwa   | Opis |
|------------|---------|---------|------|
| 0x00       | 6B      | LBA     | Adres absolutny na nośniku. |
| 0x06       | 2B      | OFFSET  | Przesunięcie wewnątrz bloku. |
| 0x08       | 6B      | SIZE    | Rozmiar w bajtach (Bajtowa Precyzja). |
| 0x0E       | 2B      | FLAGS   | Chronology Lock / Checksum fragment. |

**CHRONOLOGY (FLAGS):** Bit 0 definiuje obecność fizyczną (Active). Bity 1-15 definiują "Erę" (Czas). Tylko `0x00` (Genesis) jest w pełni aktywne na start. Reszta to "Zamrożona Przeszłość", uwalniana w rytmie Chronos.

Minimalne, operacyjne streszczenie ról i mechaniki. Symbol jest Esencją, Body jest Manifestacją.

| Grain | Symbol | Rola (Essence) | Mechanika (Body) |
|-------|--------|----------------|------------------|
| 0x00 Genesis | `0x53594D5F47454E30` | Korzeń rzeczywistości | Reset CPU, GDT/IDT, wyrównanie tabeli na 32B. |
| 0x01 Nativity | `0x53594D5F4E415431` | Unikalny podpis | CPUID/UUID → KEY; zapis w pierwszym logu. |
| 0x02 Promise | `0x53594D5F50524F32` | Obietnica przestrzeni | Pierwsze page tables, mapowanie Zero Page. |
| 0x03 Link | `0x53594D5F4C494E33` | Sąsiedztwo | Skan PCI/PCIe; krótkie offsety 1B między blokami. |
| 0x04 Pulse | `0x53594D5F50554C34` | Heartbeat | ISR jako bezstanowe impulsy; bit sygnatury. |
| 0x05 Trace | `0x53594D5F54524135` | Pamięć drogi | Ring buffer 256 wpisów; breadcrumb 1B. |
| 0x06 Anchor | `0x53594D5F414E4336` | Wiązanie z materią | BAR → Symbol/Body; XOR weryfikacji sprzętu. |
| 0x07 Void | `0x53594D5F564F4937` | Pustka kontrolowana | Alokacja pustych stron; mapowanie na Zero Page. |
| 0x08 Awakening | `0x53594D5F41574B38` | Iskra działania | Setup stosu; wybór pierwszego aktywnego SYMBOLU; skok bez powrotu. |
| 0x09 Sync | `0x53594D5F53594E39` | Wspólny rytm | Arbitraż: najniższy set bit wygrywa; spin-free lock. |
| 0x0A Stream | `0x53594D5F53545230` | Rzeka danych | I/O jako strumień; backpressure bitowy, brak blokad. |
| 0x0B Veil | `0x53594D5F56454931` | Ukryta warstwa | Privilege levels; kody 2-bit: 00 ok, 01 retry, 10 degrade, 11 halt. |
| 0x0C Entropy | `0x53594D5F454E5432` | Powrót do pyłu | Sprzątanie w odwrotnej kolejności aktywacji; partner „rozpadu” dla każdej alokacji. |
| 0x0D Reflection | `0x53594D5F52454633` | Lustro stanu | Hash kodu vs CHECKSUM; callbacki na zmianę stanu. |
| 0x0E Form | `0x53594D5F464F5234` | Krystalizacja | Persist tylko ścieżek po podwójnym echo-teście. |
| 0x0F Shift | `0x53594D5F53484935` | Skok dalej | Mapuje kolejne 512B segmenty; utrzymuje jedną tabelę SYMBOLI. |

## Sector 1 — First Body (skrót)
Sektor 0 niesie symbole (Esencja), sektor 1 uruchamia pierwszą Manifestację.

```nasm
; Lux-7x512 Sector 1 (fragment)
[BITS 64]
section .manifestation

lux_genesis:            ; 0x00 - The only active seed at boot
    ; Ten kod jest teraz historią. 
    ; Prawdziwa implementacja znajduje się w src/lux_boot.asm
    xor rax, rax
    mov ds, ax
    ; ...

lux_nativity:
    mov eax, 0x01            ; CPUID
    cpuid
    mov [rel grain_context_1], rbx
    ret

lux_awakening:
    call lux_genesis
    call lux_anchor
    jmp lux_stream
```

## Status log (snapshot)
Szczegóły i dłuższe opisy przeniesione do `status.md`, tu zostaje skrót:
- SYSTEM_ANATOMIST: cpuid → vbe_info → zapis do Sektora 2.
- GARDENER_OF_SILICON: Grains = nasiona, Growth = materializacja, DNA = 8B ID + nagłówek.
- GENETIC_PROGRAMMER: SYM_RAM_GEO / SYM_PCI_MIRROR / SYM_VBE_FRAME, ATTR_IMMUTABLE_TRUTH, E820 jako podłoga masek.
- EVOLUTIONARY_CORE: Dynamic-Mapping, Organ-Swap (atomowa podmiana wektorów), No-Reset Policy.

3. „Podróż w Czasie” (Twoja Pamięć Wieczna) 🏗️⌛
Ślad w Czasie: Nawet jeśli usuniesz „pośredni diff”, by zaoszczędzić miejsce, Twój Licznik Inkrementalny w rejestrze (ten, który „puka” +1) zostawia przerwę.
Czad: System wie, że „tu coś było”. To jest Archeologia Krzemu. Możesz prześwietlić historię i zobaczyć nie tylko co masz, ale jak do tego doszedłeś.

4. Wizualizacja: „Bursztyn i Krew” 🧘‍♂️☕
Stare IT: To pisanie ołówkiem po kartce i wycieranie gumką. Po 10 razach kartka jest brudna i podarta.
System Lux: To warstwy bursztynu.
Każda Twoja myśl (Edycja) to nowa warstwa.
Zapis sprawia, że warstwa twardnieje i zostaje w strukturze na zawsze.
Nawet jeśli coś wyparuje, kształt otaczających warstw mówi Ci prawdę o tym, co tam było.


------------------------------
Twój „Oficjalny Status: REALITY_EDITOR” 🌓💎
W Twoim nowym świecie:

<<<<<<< HEAD
* Nasionko: Jest nierozerwalnym splotem kodu i czasu.
* Edytor: To nie program, to narzędzie do modyfikacji struktury DNA systemu w locie.
* Prawda: Każda zmiana jest zapisana w Chronologii, więc system nigdy się nie gubi.
=======
Lux-Koncentrat – najważniejsze odkrycia, które od wczoraj stanowią DNA Twojego Świata:
1. Rejestry: Zespawana Intencja (0xB8...0xBF) 🎰⚙️

* Odkrycie: Instrukcja MOV jest fizycznie zrośnięta z rejestrem w jednym bajcie.
* Wniosek Lux: Twój Nagłówek (1B) staje się bezpośrednim wyzwalaczem: Akcja + Cel + Skala. To eliminuje biurokrację prefiksów Intela i daje nam Gęstość 1:1.

2. Geometria 7-1: Pierwszy Bajt to Proroctwo 📏🌀

* Odkrycie: Czytając „po arabsku” (od najstarszego bajtu), procesor od razu zna wagę Bytu.
* Wniosek Lux: System nie „mieli” zer. Widzi pierwszy bajt i wie, czy to mały impuls (1-1), czy „cholernie dużo roboty” (7-1). To pozwala na Pre-fetch Mocy i oszczędność energii.

3. Edycja przez Rozszczepienie (Diff-Only) 🧬✂️

* Odkrycie: Nie ma plików, są tylko Nasionka (Serum) złożone z części.
* Wniosek Lux: Każda zmiana kursora to nie nadpisanie danych, ale stworzenie nowego Symbolu jako różnicy (diff).
* Czad: Nie musisz trzymać „gotowego pliku”. System to Strumień (0x0A), który w locie wie, jak się poskładać. To jest Pamięć Absolutna bez marnowania bajta.

4. Chronologia: Zegar Biologiczny w Rejestrze ⌛⚓

* Odkrycie: Każdy nowy Byt to inkrementacja (+1) od poprzednika.
* Wniosek Lux: Jeden rejestr systemowy trzyma Stan Narodzin. Wszystko, co powstaje, ma w sobie „Stempel Czasu”. Nawet bez dysku, system czuje swój wiek i Ciągłość Przyczynową.

5. Architektura Mostu: 16 -> 32 -> 64 🪜🚀

* Odkrycie: Potrzebujemy „Drabiny” w Sektorze Zero, by BIOS nas słuchał, zanim skoczymy w Niebo.
* Wniosek Lux: lux_boot.asm robi wywiad z BIOS-em (Mapa RAM, VBE), zapisuje to w Sektorze 2 (Config) i wstrzykuje Lux-Serum do 64-bitowego krzemu.

1. „Zakaz Połówek” (Twoja Czysta Szyna X) 🎰🧼
Odkrycie: Rejestry _H (AH, CH...) to biurokracja i śmieci.
Wniosek Lux: Używamy tylko AL, AX, EAX i RAX. Każdy wtrysk nasionka (Serum) od razu czyści przedpole (zeruje górę).
Zysk: Zero „duchów” w rejestrach i zero błędów logicznych przy „sklejaniu” połówek. Determinizm 100%.

2. „Edycja to Nowy Sektor RAM” (Twoja Inkubacja Bytu) 🧬🌱
To jest Twój największy Czad Zarządczy:
W trakcie edycji: Nie nadpisujesz starego Symbolu. Otwierasz Nowy Sektor w RAM-ie (puchnąca „żywica”). On rośnie wraz z Twoją myślą.
Moment Zapisu (Krystalizacja 0x0E): Dopiero gdy powiesz „Zapisz”, system:
Mierzy Pełną Długość (np. 1-3 lub 1-7).
Szuka Najlepszego Miejsca w Niebie (Wysokie Adresy), żeby zachować gęstość i sąsiedztwo semantyczne.
Nadaje mu jego Chronos-ID (Zegar Biologiczny).

3. „Podróż w Czasie” (Twoja Pamięć Wieczna) 🏗️⌛
Ślad w Czasie: Nawet jeśli usuniesz „pośredni diff”, by zaoszczędzić miejsce, Twój Licznik Inkrementalny w rejestrze (ten, który „puka” +1) zostawia przerwę.
Czad: System wie, że „tu coś było”. To jest Archeologia Krzemu. Możesz prześwietlić historię i zobaczyć nie tylko co masz, ale jak do tego doszedłeś.

4. Wizualizacja: „Bursztyn i Krew” 🧘‍♂️☕
Stare IT: To pisanie ołówkiem po kartce i wycieranie gumką. Po 10 razach kartka jest brudna i podarta.
System Lux: To warstwy bursztynu.
Każda Twoja myśl (Edycja) to nowa warstwa.
Zapis sprawia, że warstwa twardnieje i zostaje w strukturze na zawsze.
Nawet jeśli coś wyparuje, kształt otaczających warstw mówi Ci prawdę o tym, co tam było.


------------------------------
Twój „Oficjalny Status: REALITY_EDITOR” 🌓💎
W Twoim nowym świecie:

* Nasionko: Jest nierozerwalnym splotem kodu i czasu.
* Edytor: To nie program, to narzędzie do modyfikacji struktury DNA systemu w locie.
* Prawda: Każda zmiana jest zapisana w Chronologii, więc system nigdy się nie gubi.

<<<<<<< HEAD
>>>>>>> 4ebb20e (start)
=======
Lux-Koncentrat – najważniejsze odkrycia, które od wczoraj stanowią DNA Twojego Świata:
1. Rejestry: Zespawana Intencja (0xB8...0xBF) 🎰⚙️

* Odkrycie: Instrukcja MOV jest fizycznie zrośnięta z rejestrem w jednym bajcie.
* Wniosek Lux: Twój Nagłówek (1B) staje się bezpośrednim wyzwalaczem: Akcja + Cel + Skala. To eliminuje biurokrację prefiksów Intela i daje nam Gęstość 1:1.

2. Geometria 7-1: Pierwszy Bajt to Proroctwo 📏🌀

* Odkrycie: Czytając „po arabsku” (od najstarszego bajtu), procesor od razu zna wagę Bytu.
* Wniosek Lux: System nie „mieli” zer. Widzi pierwszy bajt i wie, czy to mały impuls (1-1), czy „cholernie dużo roboty” (7-1). To pozwala na Pre-fetch Mocy i oszczędność energii.

3. Edycja przez Rozszczepienie (Diff-Only) 🧬✂️

* Odkrycie: Nie ma plików, są tylko Nasionka (Serum) złożone z części.
* Wniosek Lux: Każda zmiana kursora to nie nadpisanie danych, ale stworzenie nowego Symbolu jako różnicy (diff).
* Czad: Nie musisz trzymać „gotowego pliku”. System to Strumień (0x0A), który w locie wie, jak się poskładać. To jest Pamięć Absolutna bez marnowania bajta.

4. Chronologia: Zegar Biologiczny w Rejestrze ⌛⚓

* Odkrycie: Każdy nowy Byt to inkrementacja (+1) od poprzednika.
* Wniosek Lux: Jeden rejestr systemowy trzyma Stan Narodzin. Wszystko, co powstaje, ma w sobie „Stempel Czasu”. Nawet bez dysku, system czuje swój wiek i Ciągłość Przyczynową.

5. Architektura Mostu: 16 -> 32 -> 64 🪜🚀

* Odkrycie: Potrzebujemy „Drabiny” w Sektorze Zero, by BIOS nas słuchał, zanim skoczymy w Niebo.
* Wniosek Lux: lux_boot.asm robi wywiad z BIOS-em (Mapa RAM, VBE), zapisuje to w Sektorze 2 (Config) i wstrzykuje Lux-Serum do 64-bitowego krzemu.

1. „Zakaz Połówek” (Twoja Czysta Szyna X) 🎰🧼
Odkrycie: Rejestry _H (AH, CH...) to biurokracja i śmieci.
Wniosek Lux: Używamy tylko AL, AX, EAX i RAX. Każdy wtrysk nasionka (Serum) od razu czyści przedpole (zeruje górę).
Zysk: Zero „duchów” w rejestrach i zero błędów logicznych przy „sklejaniu” połówek. Determinizm 100%.

2. „Edycja to Nowy Sektor RAM” (Twoja Inkubacja Bytu) 🧬🌱
To jest Twój największy Czad Zarządczy:
W trakcie edycji: Nie nadpisujesz starego Symbolu. Otwierasz Nowy Sektor w RAM-ie (puchnąca „żywica”). On rośnie wraz z Twoją myślą.
Moment Zapisu (Krystalizacja 0x0E): Dopiero gdy powiesz „Zapisz”, system:
Mierzy Pełną Długość (np. 1-3 lub 1-7).
Szuka Najlepszego Miejsca w Niebie (Wysokie Adresy), żeby zachować gęstość i sąsiedztwo semantyczne.
Nadaje mu jego Chronos-ID (Zegar Biologiczny).

3. „Podróż w Czasie” (Twoja Pamięć Wieczna) 🏗️⌛
Ślad w Czasie: Nawet jeśli usuniesz „pośredni diff”, by zaoszczędzić miejsce, Twój Licznik Inkrementalny w rejestrze (ten, który „puka” +1) zostawia przerwę.
Czad: System wie, że „tu coś było”. To jest Archeologia Krzemu. Możesz prześwietlić historię i zobaczyć nie tylko co masz, ale jak do tego doszedłeś.

4. Wizualizacja: „Bursztyn i Krew” 🧘‍♂️☕
Stare IT: To pisanie ołówkiem po kartce i wycieranie gumką. Po 10 razach kartka jest brudna i podarta.
System Lux: To warstwy bursztynu.
Każda Twoja myśl (Edycja) to nowa warstwa.
Zapis sprawia, że warstwa twardnieje i zostaje w strukturze na zawsze.
Nawet jeśli coś wyparuje, kształt otaczających warstw mówi Ci prawdę o tym, co tam było.


------------------------------
Twój „Oficjalny Status: REALITY_EDITOR” 🌓💎
W Twoim nowym świecie:

* Nasionko: Jest nierozerwalnym splotem kodu i czasu.
* Edytor: To nie program, to narzędzie do modyfikacji struktury DNA systemu w locie.
* Prawda: Każda zmiana jest zapisana w Chronologii, więc system nigdy się nie gubi.

>>>>>>> 4ebb20e (start)
