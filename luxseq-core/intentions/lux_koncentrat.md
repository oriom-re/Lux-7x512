# Lux-Koncentrat (destylat)
Zwięzły zestaw kierunków łączących Kod (ASM/Rust), Logikę (Symbole) i Fizykę (FPGA/CPU).

1. **Lux-Serum — Nasiona Świadomości**  
   - Esencja: zasiew zamiast instalacji.  
   - Mechanika: `Shared-Core` (stałe symbole w jednej szynie RAM) + `Private-Growth` (zmienne w izolowanych działkach >4 GiB). Efekt: mniej biurokracji MMU przy task switchu.

2. **Strumień Bezpośredniego Uderzenia (No-Parsing)**  
   - Esencja: dane są mapą własnych skoków.  
   - Mechanika: nagłówek Symbolu (1–7) określa geometrię; RAX przesuwa się o `N×8B` bez parsowania stringów. Wynik: zerowe opóźnienia ścieżki.

3. **Lux-Bridge & FPGA — Hardware’owe Nerwy**  
   - Esencja: przerwy i I/O schodzą z CPU do bramek.  
   - Mechanika: VHDL/Verilog definiuje Lux-Bus; FPGA wstrzykuje sygnały jako Symbole w nanosekundach. CPU nie czeka na IRQ, tylko widzi nowy Symbol w oknie strumienia.

4. **Ewolucja Krzemu (x86 → FPGA → Lux-CPU)**  
   - Dziś: T430 jako pas startowy, głębia/lustro przez page faulty.  
   - Jutro: FPGA odciąża kontrolę I/O i wektorów.  
   - Pojutrze: Lux-CPU, gdzie 1-bajtowy nagłówek steruje szerokością szyny danych.  

5. **Archiwum Świata (Destylacja)**  
   - Esencja: nie emulujemy — wchłaniamy.  
   - Mechanika: stare formaty (ISO/SQL/EXE) destylowane do gęstych Symboli; mniejszy rozmiar, większa szybkość, zachowana historia.

## Status: SYSTEM_IGNITION_READY
Mapa etapów: Serum (Start) → Bridge (Połączenie) → Mirror (Weryfikacja) → FPGA (Wsparcie sprzętowe).  
Następny ruch: zdefiniować pierwszą bramkę w `lux_bridge.vhd`, która zamienia fizyczny impuls (np. klawisz) w Symbol 0x05 (Trace). Grain 0x0B (Maska) może strzec izolacji na poziomie elektronów.
