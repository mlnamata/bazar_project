# Fáze 08 – Leady, zkušební jízda, prodej, smlouvy a faktury

## Kontext

Přečti `CLAUDE.md` (pravidlo 5 o DPH); ve specifikaci **B6.13, BZ4.1, B6.14, BZ4.3, BZ5.1 (checklist), BZ2.3, BZN.3 (zdroj leadu qr)**, dokumenty **D3–D6**, obrazovky 8–11 a řádek Účetnictví v „Rozsah MVP“; v datovém modelu `leads`, `lead_events`, `customers`, `test_drives`, `sales`, `invoices`, `invoice_items`, `number_series`, `outbound_messages`.

## Cíl

Každý zájemce je na jednom místě u vozu a prodejce; prodej od zkušební jízdy po fakturu proběhne bez ručního přepisování (kritérium MVP 4).

## Postup

1. **Leady (`/leady`):** seznam podle stavu (Nový · Kontaktován · Prohlídka · Nabídka · Vyhráno · Ztraceno) jako tabulka i kanban; filtr prodejce, vůz, zdroj; nový lead ručně (telefonát, osobně). Detail: kontakt, vůz (s cenou a stavem), časová osa `lead_events` (poznámka, hovor, SMS, e-mail, změna stavu), rychlé akce Zavolat (tel: odkaz + zápis hovoru), Poslat SMS / e-mail ze šablon (`Děkujeme za zájem…`, `Potvrzení prohlídky…`), Naplánovat prohlídku / zkušební jízdu, Ztraceno s důvodem. Automatické přiřazení: round-robin mezi prodejci pobočky (nastavitelné). Notifikace prodejci o novém leadu (e-mail + web push v PWA).
2. **Adaptéry `sms/` a `email/`:** mock zapisuje do `outbound_messages`, real přes zvolenou službu (konfigurovatelné env). Odesílání přes frontu se stavem a chybou. Odhlášení z marketingu respektuje `marketing_consent`.
3. **Zkušební jízda (BZ4.1, mobil):** z leadu nebo karty vozu – termín, foto řidičáku (do `documents`), km a palivo na začátku, souhlas se zkušební jízdou (D5) s podpisem prstem; po návratu km a palivo na konci. Kalendář prohlídek a jízd v přehledu dne.
4. **Prodej (`/prodej/:id`, obrazovka 10):** průvodce – zákazník (z leadu předvyplněný; osoba / firma, ARES) → cena a režim DPH (výchozí `margin`, u vozu koupeného s DPH `standard`) → protiúčet (BZ2.3: otevře výkupní průvodce z fáze 05 v režimu protiúčtu a odečte jeho hodnotu) → záloha a způsob platby → odpovědnost za vady: 24 měsíců, u spotřebitele lze dohodou zkrátit na 12 (BZ4.3) – systém nabídne obě varianty a vysvětlí je → známé vady (předvyplní se z checklistů, prodejce upraví) → náhled kupní smlouvy D3 → podpisy → předávací protokol D4 (km, palivo, počet klíčů, doklady, příslušenství) → faktura D6 → checklist přepisu (BZ5.1: předán velký TP, plná moc, evidenční kontrola, termín na úřadě …). Dokončení přepne vůz do `sold` (spustí stažení inzerce z fáze 07) a lead do `won`.
5. **Faktury:** číslování `next_number(company, 'invoice')`; zvláštní režim: jedna položka „Osobní automobil {značka model}, VIN …“, cena bez rozpisu DPH, povinný text „Zvláštní režim – použité zboží“; standardní režim s rozpisem DPH 21 %; QR platba (formát SPAYD) na faktuře; zálohová faktura a dobropis; PDF v `packages/documents`. Seznam faktur s filtrem, označení zaplaceno.
6. **Export do účetnictví:** za období ISDOC (ZIP) a XML pro Pohodu (formát Pohoda XML import faktur vydaných), CSV obecně. Testy na validitu ISDOC proti XSD.
7. **Zákazníci (`/zakaznici`):** seznam, detail s koupenými a prodanými vozy, leady, dokumenty; slučování duplicit (stejný telefon/e-mail); export a výmaz osobních údajů na žádost (GDPR) – výmaz jen tam, kde nebrání zákonná archivace dokladů (zablokuje a vysvětlí).

## Mimo rozsah

Automatické načítání dotazů z portálů (v1), rezervace se zálohou (v1), EET 2.0 (v1), komisní prodej (v1).

## Akceptační kritéria

- [ ] Lead z ručního zadání → prohlídka → zkušební jízda → prodej s protiúčtem → smlouva, protokol, faktura v PDF → vůz `sold`, inzerce stažená, lead `won` (e2e).
- [ ] Faktura ve zvláštním režimu nevyčísluje DPH a nese povinný text; standardní režim počítá DPH správně (testy na zaokrouhlení).
- [ ] Čísla faktur jsou souvislá i při souběžném vystavení (test 20 paralelních volání).
- [ ] Export ISDOC projde XSD validací.
- [ ] Všechny dokumenty z karty vozu bez jediného ručně přepsaného údaje.

## Na konci

`docs/progress.md`, větev `phase/08-prodej`, PR.
