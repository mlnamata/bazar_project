# Fáze 05 – Výkup, VIN, prověrka, km a výkupní smlouva

## Kontext

Přečti `CLAUDE.md`, `docs/integration-contract.md` sekce 8; ve specifikaci **B6.2, BZ2.1 (základ), BZ2.3, V4.1, V4.3, V4.4, V4.9, V4.10, V4.12, K5.1**, dokumenty **D1, D8** a obrazovku 4; v datovém modelu `buyouts`, `vin_reports`, `mileage_records`, `checklist_templates`, `inspections`, `customers`.

**Skills pro UI:** před prací načti `impeccable`, `shadcn` a `frontend-design`; po každé obrazovce `break-ui`, před PR `baseline-ui` a `web-design-guidelines`; mobilní obrazovky `mobile-native`; pohyb `animate` (viz tabulka v CLAUDE.md).

## Cíl

Výkupčí na telefonu projde výkup za 10 minut: VIN z fotky → údaje vozu → prověrka → checklist stavu → doporučená cena → smlouva podepsaná prstem. Funguje i při výpadku signálu.

## Postup

1. **Adaptéry (Deno, `supabase/functions/_shared/providers/`):**
   - `vin/` – rozhraní `decode(vin)`, `stolenCheck(vin)`, `marketPrices(spec)`; mock čte `fixtures/vin/*.json` (připrav 10 VIN pro modely z demo seedu), real = Vincario (podpis požadavku podle jejich dokumentace; pokud dokumentace není dostupná, nech jasný TODO a test jen na mock),
   - `history/` – `checkHistory(vin)` vrací normalizovaný výsledek `{findings: [...], mileage: [{date, km, source}], damages, stolen, leasing, reportUrl}`; mock podle posledního znaku VIN (např. `…9` = stočené km), real = Cebia (po smlouvě),
   - `ai/` – `readVinFromImage(image)` (Anthropic API, vision; vrátí VIN + jistotu; validace kontrolní číslice není u EU VIN povinná – validuj formát).
2. **Edge funkce:** `vin-decode`, `vin-ocr`, `vehicle-check` (zapíše `vin_reports`, záznamy do `mileage_records`, nastaví `vehicles.verified` když prověrka bez nálezu). **Cache:** pokud firma má pro VIN výsledek mladší 30 dní, nevolá znovu a nabídne „Aktualizovat (placené)“. Cena prověrky se uloží do `vin_reports.cost`.
3. **Průvodce výkupem (`/vykup/novy`, mobil first, komponenta `Wizard`):**
   1. **Vůz** – vyfotit štítek VIN nebo TP → OCR → potvrdit; nebo zadat ručně; SPZ; foto tachometru → km (ruční potvrzení).
   2. **Údaje** – předvyplněno z dekódování, uživatel opraví; kontrola odcizení (výsledek zeleně / červeně, při nálezu blokace s vysvětlením).
   3. **Prověrka** – tlačítko „Prověřit historii“ s cenou, výsledek srozumitelně: nálezy, časová osa km.
   4. **Stav** – výkupní checklist ze šablony: skupiny, u položky OK / pozor / závada, poznámka, fotka; hloubka dezénu 4× v mm; palivo; klíče; doklady.
   5. **Ocenění (BZ2.1 základ)** – srovnatelné vozy z `marketPrices` (stejný model, motor, rok ±1, km ±20 %): medián, rozptyl, počet; odhad nákladů přípravy (součet „závad“ × paušály z nastavení firmy); doporučená výkupní cena = cílová prodejní − příprava − požadovaná marže (marže z nastavení, výchozí 12 %); vše jako vysvětlený výpočet, ne jedno číslo.
   6. **Prodávající** – zákazník (vyhledat / nový; osoba nebo firma, IČO přes ARES), datum narození a číslo dokladu jen pro smlouvu.
   7. **Smlouva** – dohodnutá cena, způsob platby, protiúčet (BZ2.3: vazba na rozpracovaný prodej), náhled D1 + plná moc k přepisu, podpis prstem prodávajícího a výkupčího (`signature_pad`), PDF do `documents`.
   - Po dokončení vznikne vůz ve stavu `buyout` → nabídka „Pokračovat do přípravy“.
4. **Offline:** každý krok se ukládá do IndexedDB (`idb-keyval`) jako koncept; fotky ve frontě; po připojení se odešlou (Background Sync, jinak při otevření). Indikátor „Uloženo v telefonu, odešle se po připojení“.
5. **Karta vozu – záložka Prověrka a km:** seznam prověrek, souhrn nálezů, **časová osa km** (graf: body podle zdroje, čára; pokles km zvýrazněný červeně s popisem), tlačítko „Protokol vozu PDF“ (D8: údaje, výbava, prověrka, časová osa, fotky, logo bazaru).
6. **PDF:** šablony D1 a D8 v `packages/documents` (React-PDF), data z karty vozu a zákazníka, čísla smluv přes `next_number(company, 'buyout_contract')`. Každý dokument má v patičce „Šablona ke kontrole advokátem“ dokud firma nenahraje schválenou verzi.

## Akceptační kritéria

- [ ] Celý výkup na telefonu (Playwright mobile, mock adaptéry) skončí vozem ve stavu `buyout`, podepsanou smlouvou v PDF a záznamy km.
- [ ] Přerušení sítě v kroku 4 nic neztratí; po obnovení se výkup dokončí.
- [ ] Opakovaná prověrka stejného VIN do 30 dní nic neplatí (test).
- [ ] Vůz se stočenými km z mocku má na časové ose červeně vyznačený pokles a text „Pokles o X km mezi …“.
- [ ] PDF D1 a D8 s diakritikou, číslem smlouvy a podpisy.

## Na konci

`docs/progress.md`, větev `phase/05-vykup`, PR.
