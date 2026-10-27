# Fáze 09 – Plugin na web bazaru, veřejné API a stránka vozu

## Kontext

Přečti `CLAUDE.md`, **celý** `docs/integration-contract.md` (sekce 4 a 5 jsou závazné – prezentační web na ně spoléhá), ve specifikaci **PL.1, PL.5–PL.9, BZN.3**, akceptační kritérium MVP 5 a `docs/design-system.md` sekce Přístupnost a výkon.

**Skills pro UI:** před prací načti `impeccable`, `shadcn` a `frontend-design`; po každé obrazovce `break-ui`, před PR `baseline-ui` a `web-design-guidelines`; mobilní obrazovky `mobile-native`; pohyb `animate` (viz tabulka v CLAUDE.md).

## Cíl

Bazar vloží jeden řádek kódu do svého webu a má nabídku vozů s filtry, detailem a formulářem; zákazník na ploše naskenuje QR kód a vidí totéž. Prezentační web ukazuje plugin s demo firmou (`key="demo"`).

## Postup

1. **Edge funkce `public-api`** přesně podle kontraktu sekce 4: routy, parametry, tvar odpovědí (zdokumentuj je jako TypeScript typy v `packages/shared/src/public-api.ts`, které importuje plugin i funkce), filtrování jen veřejných vozů, bezpečné sloupce (žádné nákupní ceny, náklady, celé VIN, SPZ), facety, `Cache-Control`, CORS `*`, rate limit a honeypot na `POST /leads`, `POST /events` přes `sendBeacon`. Lead z pluginu vytvoří `leads` se zdrojem `web` nebo `qr`, přiřadí prodejce a pošle notifikaci (fáze 08). Testy: že žádná odpověď neobsahuje zakázaná pole (snapshot klíčů).
2. **Plugin `apps/widget` (Lit, Shadow DOM):**
   - element `<{BRAND.widgetTag} key="…">` s atributy z kontraktu sekce 5; registrace názvu z `BRAND.widgetTag`,
   - **výpis:** mřížka karet (fotka 960, název v Archivo, rok · km · palivo · převodovka, cena, splátka od X Kč/měs. když má firma F&I – fáze 10 doplní výpočet, teď jen místo), odznak Prověřeno, štítek Rezervováno; filtry (značka → model závislé, cena do, rok od, km do, palivo, převodovka, karoserie) – na mobilu ve vysouvacím panelu; řazení; stránkování „Načíst další“; stav filtrů v URL hostitelské stránky (`#vozy?make=skoda`) pro sdílení odkazu,
   - **detail:** galerie (swipe, zoom, fullscreen, lazy), parametry, výbava po skupinách, prověrka a časová osa km (jednoduchý SVG graf), protokol vozu PDF ke stažení, kontakt pobočky a otevírací doba, podobné vozy, formulář Dotaz / Prohlídka / Zkušební jízda (jméno, telefon nebo e-mail, zpráva, preferovaný termín, souhlas se zpracováním s odkazem na zásady bazaru z nastavení), potvrzení odeslání,
   - **vzhled:** převezme písmo stránky (`font: inherit`), akcent z atributu nebo z `GET /company`, neutrální šedé z tokenů přes CSS proměnné, které může bazar přepsat (`--widget-accent`, `--widget-radius` …); funguje ve světlém i tmavém webu,
   - **výkon:** ≤ 60 kB gzip, `srcset` WebP 480/960/1600, `loading="lazy"`, žádné externí fonty, prefetch detailu při najetí; cíl LCP výpisu < 2,5 s na Moto G (Lighthouse mobile v CI na `demo.html`),
   - **přístupnost:** ovládání klávesnicí, aria popisky, focus trap v galerii, kontrast,
   - **měření (PL.8):** `list_view`, `detail_view`, `contact_click`, `lead_submit`, `calc_open` přes `/events`, `sessionId` jen v `sessionStorage`, bez cookies,
   - událost `lead-submitted` pro hostitelský web.
3. **Veřejná stránka vozu `/v/:publicKey/:vehicleId`** v `apps/app` (bez přihlášení): použije plugin v režimu `view="detail"`, meta tagy Open Graph (fotka, název, cena) pro sdílení, odkaz „Další vozy bazaru“. Pro bazary bez webu je to jejich nabídka (`/v/:publicKey`).
4. **QR štítky (BZN.3):** v kartě vozu a hromadně na skladě „Tisk QR štítků“ → PDF A4 (2 nebo 4 štítky na stranu) s názvem vozu, cenou, QR na `/v/:publicKey/:vehicleId?src=qr`, logem bazaru; lead z této stránky má zdroj `qr`.
5. **Nastavení webu (`/nastaveni/web`, obrazovka 13):** náhled pluginu živě, barva akcentu, zaoblení, počet vozů na stránku, texty (nadpis, GDPR odkaz), kód k vložení s tlačítkem Kopírovat a návodem pro Wix, Webnode, WordPress (vložit HTML blok); seznam povolených domén (nepovinné – když je vyplněný, `public-api` kontroluje `Origin`).
6. **Demo:** `apps/widget/demo.html` s `key="demo"` a ukázkou vložení do jednoduché stránky bazaru; prezentační web použije přesně tento kód.

## Akceptační kritéria

- [ ] Vložení dvou řádků do prázdného HTML souboru zobrazí nabídku demo firmy, filtry, detail a odešle lead, který se objeví v aplikaci u správného vozu a prodejce.
- [ ] Odpovědi API neobsahují nákupní cenu, náklady, celé VIN ani SPZ (test).
- [ ] Plugin ≤ 60 kB gzip, Lighthouse mobile: Performance ≥ 90, Accessibility ≥ 95 na `demo.html`.
- [ ] QR štítek vede na stránku vozu a lead má zdroj `qr`.
- [ ] Plugin nepřebírá ani nerozbíjí styly hostitelské stránky (test na stránce s agresivním globálním CSS).

## Na konci

`docs/progress.md`, aktualizuj kontrakt, pokud se něco upřesnilo (a napiš to do PR, ať se upraví i Lovable), větev `phase/09-plugin`, PR.
