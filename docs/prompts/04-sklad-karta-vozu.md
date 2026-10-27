# Fáze 04 – Sklad vozů, karta vozu a převzetí skladu

## Kontext

Přečti `CLAUDE.md`; ve specifikaci body **B6.1, BZ1.1, BZ1.2, BZ1.4, BZN.1, V4.9** a obrazovky 2 a 3; v datovém modelu `vehicles`, `vehicle_costs`, `vehicle_documents`, `vehicle_status_history`, `vehicle_economics`, `imports`.

## Cíl

Bazar vidí celý sklad s marží a dny na skladě, otevře kartu vozu se vším na jednom místě a do 30 minut převezme svůj stávající sklad z CSV.

## Postup

1. **Sklad (`/sklad`):**
   - přepínač Tabulka / Dlaždice (uloží se), stránkování serverem po 50,
   - sloupce: fotka 64×48 + značka model varianta, rok, km, palivo/převodovka, stav, inzerovaná cena, marže (Kč a %), dny na skladě, kanály (ikonky stavů inzerce – zatím prázdné), pobočka,
   - filtry: stav (vícenásobný), značka, model, palivo, rok od–do, cena od–do, dny na skladě (> 30, > 60, > 90), pobočka, „bez fotek“, „bez ceny“; fulltext (VIN, SPZ, skladové číslo, model); filtry v URL,
   - souhrn nad tabulkou: počet vozů, hodnota skladu v nákupních cenách, průměrné dny na skladě, vozy nad 60 dní,
   - hromadné akce: změnit stav, zlevnit o % / Kč, (zveřejnit / stáhnout doplní fáze 07),
   - tlačítko „Nový vůz“ (rychlé ruční založení: VIN nebo značka + model, km, rok, nákupní cena) a „Výkup“ (fáze 05).
2. **Karta vozu (`/vuz/:id`):** hlavička s fotkou, názvem v Archivo, stavem (rozbalovací změna s potvrzením a poznámkou do historie), cenou a tlačítky další akce podle stavu. Záložky:
   - **Údaje a výbava** – formulář všech technických polí, výbava jako zaškrtávací seznam podle skupin (katalog `packages/shared/src/equipment.ts` s ~120 položkami a českými názvy; kódy do `vehicles.equipment`),
   - **Fotky** (doplní fáze 06, zatím nahrání a pořadí),
   - **Ekonomika** – nákupní cena a režim DPH, náklady (`vehicle_costs`: přidat, upravit, kategorie), cílová / minimální / inzerovaná cena, výpočet marže živě, dny na skladě; varování, když inzerovaná cena < minimální,
   - **Příprava** (fáze 06), **Prověrka a km** (fáze 05), **Inzerce** (fáze 07) – zatím prázdné stavy,
   - **Dokumenty** – nahrání skenu mobilem (fotoaparát) i souborem, typ dokumentu, náhled, upozornění na chybějící povinné doklady (malý TP, velký TP),
   - **Historie** – časová osa změn stavů a důležitých změn z `audit_log` (kdo, kdy, co).
3. **Limit tarifu:** při překročení `companies.vehicle_limit` (vozy mimo stav sold/written_off) nový vůz nejde založit – srozumitelná hláška s odkazem na vyšší tarif.
4. **Import CSV (BZN.1, `/sklad/import`):** průvodce 4 kroky – nahrát CSV/XLSX → namapovat sloupce (automatický návrh podle hlaviček včetně typických exportů Sauto/TipCars, ruční úprava, uložení mapy) → náhled s chybami po řádcích → import. Fotky z URL ve sloupci (odděleno `|`) stáhne edge funkce `import-photos` na pozadí a převede na WebP. Duplicita podle VIN nebo skladového čísla = aktualizace. Výsledek do `imports.stats/errors`. Vzorový CSV ke stažení.
5. **Výkon:** seznam přes jeden dotaz na pohled (rozšiř `vehicle_economics` nebo nový pohled `vehicle_list` s titulní fotkou – novou migrací), indexy podle filtrů.

## Akceptační kritéria

- [ ] Demo sklad 25 vozů se načte do 1 s, filtry a řazení fungují a zůstanou v URL.
- [ ] Marže a dny na skladě sedí s ručním výpočtem (test na `vehicle_economics`).
- [ ] Import vzorového CSV se 100 vozy včetně fotek doběhne a chybné řádky jsou vysvětlené česky.
- [ ] Změna stavu se zapíše do historie s autorem.
- [ ] E2e: založit vůz, upravit výbavu, přidat náklad, změnit stav, importovat CSV.

## Na konci

`docs/progress.md`, `pnpm db:docs` při změně schématu, větev `phase/04-sklad`, PR.
