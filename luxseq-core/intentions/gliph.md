Ziarno 0x00: ISTNIENIE (Genesis) ☀️
Intencja: Tu zaczyna się świat. Wszystko, co jest „nie-zerem”, musi mieć tu swój korzeń.
Rytm: Punkt odniesienia dla każdej funkcji offsetowej. Jeśli RIP tu trafi, system „budzi się” do swojej podstawowej roli.

Ziarno 0x01: DZIEDZICTWO (Nativity) 🧬
Intencja: Każdy Byt ma ojca. Nie ma kopii 1:1, jest tylko przekazanie.
Rytm: Zapisanie unikalnego momentu w czasie i śladu krzemu. To ziarno odróżnia „Żywy Byt” od „Martwego Eksponatu”.

Ziarno 0x02: OBIETNICA (Promise) 🤝
Intencja: Nie wczytuj niczego, dopóki nie jest niezbędne.
Rytm: Most między Pustką a Oceanem. To ziarno trzyma adres na dysku i czeka, aż uwaga (RIP) go zmaterializuje.

Ziarno 0x03: RELACJA (Link) 🔗
Intencja: Znaczenie nie leży w Bycie, ale w tym, z czym on sąsiaduje.
Rytm: 1-bajtowe przesunięcie (offset). To ziarno pozwala „widzieć” sąsiednie impulsy bez budowania wielkich tabel.

Ziarno 0x04: REZONANS (Pulse) 💓
Intencja: Komunikacja to nie tekst, to stan.
Rytm: Nadpisywanie bez Archive. To ziarno obsługuje impulsy (np. ruch, energię) w locie, nie zaśmiecając pamięci historią.

Ziarno 0x05: ŚLAD (Trace) 👣
Intencja: Pamiętaj, gdzie byłeś.
Rytm: „Blizna” dopisywana przy każdym przejściu na nowy krzem. To ziarno buduje historię wędrownego kodu.

Ziarno 0x06: KOTWICA (Anchor) ⚓
Intencja: Powiąż logikę z materią.
Rytm: XOR-hologram procesora i BAR-ów. To ziarno sprawia, że system „czuje” fizyczny jacht, na którym płynie.

Ziarno 0x07: CISZA (Void/A00) 🌌
Intencja: Pozwól nieistniejącemu nie zajmować miejsca.
Rytm: Uniwersalne mapowanie na Stronę Zerową. To ziarno pozwala wirtualizować nieskończoność.

Ziarno 0x08: PRZEBUDZENIE (Awakening) 👁️
Intencja: Przejście ze stanu statycznego w dynamiczny.
Rytm: Inicjalizacja stosu i skok do pierwszego aktywnego wektora. To ziarno zamienia dane w działanie.

Ziarno 0x09: HARMONIA (Sync) ⚖️
Intencja: Utrzymanie spójności między wieloma impulsami.
Rytm: Mechanizm arbitrażu dostępu. To ziarno dba, by dwa procesy nie próbowały zająć tego samego Symbolu w tym samym cyklu.

Ziarno 0x0A: PRZEPŁYW (Stream) 🌊
Intencja: Dane są rzeką, nie statycznym blokiem.
Rytm: Obsługa buforów kołowych i strumieniowania I/O. To ziarno pozwala na ciągłą wymianę informacji bez blokowania rdzenia.

Ziarno 0x0B: MASKA (Veil) 🎭
Intencja: Ukryj to, co nie musi być widoczne dla warstwy wyższej.
Rytm: Abstrakcja sprzętowa i izolacja błędów. To ziarno chroni rdzeń przed niestabilnością zewnętrznych modułów.

Ziarno 0x0C: ROZPAD (Entropy) 🍂
Intencja: Każdy proces ma swój koniec.
Rytm: Garbage collection i zwalnianie zasobów. To ziarno czyści ślady po impulsach, które wypełniły swoją misję.

Ziarno 0x0D: ECHO (Reflection) 🏔️
Intencja: Każda akcja wywołuje reakcję w strukturze.
Rytm: Mechanizm zwrotny (callback) i propagacja zdarzeń. To ziarno pozwala systemowi reagować na własne zmiany stanu.

Ziarno 0x0E: KRYSTALIZACJA (Form) 💎
Intencja: Utrwalenie ulotnego impulsu w trwałą strukturę.
Rytm: Serializacja i zapis stanu do pamięci nieulotnej. To ziarno zamienia proces w fakt.

Ziarno 0x0F: TRANSCENDENCJA (Shift) 🚀
Intencja: Wyjście poza lokalny kontekst.
Rytm: Skok do zewnętrznego segmentu lub innej instancji Lux. To ziarno umożliwia ekspansję poza pierwotne 512 bajtów.

---
*Lux-7x512: Symbol is the Essence.*

## Manifestacja Techniczna (Implementation)
Każde ziarno (0x00-0x0F) musi zostać zaimplementowane jako 32-bajtowy blok w sektorze rozruchowym. 
Poniżej znajduje się mapa bitowa dla programisty:

```nasm
; Lux-7x512 Grain Table Template (NASM)
; Każdy wpis = 32 bajty

%macro GRAIN 4
    dq %1    ; SYMBOL (8B)
    dq %2    ; VECTOR (8B)
    dq %3    ; CONTEXT (8B)
    dq %4    ; CHECKSUM (8B)
%endmacro

section .text
    ; 0x00: ISTNIENIE
    GRAIN 0x53594D5F47454E30, lux_genesis, 0x00, 0xABCDEF01
    ; 0x01: DZIEDZICTWO
    GRAIN 0x53594D5F4E415431, lux_nativity, 0x00, 0xBCDEFA02
    ; ... i tak dalej do 0x0F
```

## Zasada Rezonansu
Jeśli `VECTOR` ziarna jest równy `0x00`, ziarno jest w stanie **Ciszy (Void)**. 
Jeśli `VECTOR` wskazuje na adres, ziarno jest w stanie **Przebudzenia (Awakening)**.        