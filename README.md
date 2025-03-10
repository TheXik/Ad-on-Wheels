# Aplikácia

Tento projekt predstavuje aplikáciu, ktorá sprostredkováva prenájom reklamného priestoru na autách. 
Obsahuje dve hlavné užívateľské role – Majiteľ auta a Firma. Cieľom je vytvoriť platformu, 
kde majitelia áut môžu ponúkať reklamný priestor(svoje auto) a firmy môžu tieto reklamy nakupovať. 

## Užívateľské role

1. **Nezaregistrovaný užívateľ**
   - Nemá prístup do aplikácie, vidí len úvodnú obrazovku s možnosťou registrácie.
   - Môže si pozrieť demo v read-only režime.
   - Možnosť registrácie ako firma alebo ako majiteľ auta.

2. **Registrovaný užívateľ (Majiteľ auta)**
   - Má prístup k funkcionalite na registráciu auta, zobrazenie štatistík, príjmov a nastavení.

3. **Registrovaná firma**
   - Má prístup k funkcionalite na nákup reklamného priestoru na autách, zobrazenie štatistík, 
     prehľad platieb a nastavení.

4. **Admin account**
   - Správa celého systému (nie je detailne rozpísané).

---

## Funkčné požiadavky

### 1. Pre registrovaných majiteľov áut
- **Pred registráciou auta:**
  - Užívateľ musí podpísať zmluvné podmienky a GDPR (ak aj odmietne, musí mať možnosť pokračovať 
    v obmedzenom režime)
  - Musí existovať možnosť zmazať účet

- **Registrovanie auta:**
  - Registrácia auta na minimálne mesiac a viac.
  - Zadáva sa značka, typ auta, lokalita (kde sa bude najčastejšie jazdiť) a plánovaný mesačný nájazd kilometrov.
  - Na základe týchto údajov sa vypočíta cena reklamy, ktorú bude firma platiť (majiteľ auta musí splniť 
    stanovený limit kilometrov).

- **Hlavné menu (Majiteľ auta):**
  - Zobrazuje, koľko kilometrov najazdil za daný mesiac.
  - Koľko mu chýba do splnenia limitu na získanie platby za prenájom.
  - Rýchly prehľad podstatných informácií.

- **Sledovanie cez GPS (voliteľne):**
  - Aplikácia trackuje, koľko a v akých časoch majiteľ auta jazdil.
  - Na základe týchto údajov by sa mohol odhadnúť dosah reklamy (hot oblasti).
  - Vo verzii 1 nie je nevyhnutné.

- **Nastavenia (Majiteľ auta):**
  - Nastavenie bankového účtu, zmena hesla, e-mailu, a iných osobných údajov.

- **Štatistika (Majiteľ auta):**
  - Ako veľa najazdil.
  - Koľko peňazí zarobil.

- **Detailné záznamy o platbách:**
  - Možnosť kontroly, reklamácie, storna platieb a podobne.

- **Stručný prehľad obrazoviek (Majiteľ auta):**
  - **STATS** | **INCOME** | **MENU** | **REGISTER CAR** | **SETTINGS**

---

### 2. Pre registrovanú firmu
- **Nutnosť registrácie firmy:**
  - Podpísanie zmluvných podmienok (pre účely projektu sa nebudeme zaoberať detailmi).

- **Hlavné menu (Firma):**
  - Zobrazenie základnej štatistiky:
    - Počet prenajatých áut.
    - Koľko áut najazdilo.
    - Koľko firma míňa na reklamu.
  - Odhad dosahu reklamy (voliteľné).

- **STATS page (Firma):**
  - Všetky možné štatistiky (počet prenajatých áut, cena reklamy, mapa Slovenska s lokalitami, kde sú 
    zakúpené reklamy).

- **BUY AD (Firma):**
  - Možnosť firmy vidieť aktuálnu ponuku vozidiel, na ktoré môže umiestniť reklamu.
  - Filter a/alebo odporúčací algoritmus (napr. podľa lokality, značky, nájazdu).

- **SETTINGS (Firma):**
  - Podobné nastavenia ako pri užívateľovi (zmena hesla, e-mailu atď.).

- **PAYMENT (Firma):**
  - Detailné záznamy o platbách.
  - Možnosť kontroly, reklamácie, storna platieb.

---

### 3. Vzájomná interakcia (Firma - Majiteľ auta)
- Firmy si vyberajú autá od majiteľov, na ktoré chcú umiestniť reklamu.
- Môže existovať odporúčací algoritmus pre firmy na základe lokality a iných parametrov.

---

## Nefunkčné požiadavky

1. **Intuitívne UI**
   - Jednoduchá orientácia, dôraz na prehľadnosť.
2. **Kompatibilita s iOS**
   - Cieľom je mať aplikáciu spustiteľnú na iOS.


