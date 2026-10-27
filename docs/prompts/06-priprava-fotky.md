# Fáze 06 – Příprava vozu a focení

## Kontext

Přečti `CLAUDE.md`; ve specifikaci **B6.3 (jednoduché úkoly), BZ3.1, B6.6 (základ)**, řádek Fotky v „Rozsah MVP“ a obrazovky 5 a 6; v datovém modelu `vehicle_tasks`, `vehicle_costs`, `vehicle_photos`, `inspections` (kind `pre_sale`).

## Cíl

Vedoucí vidí, co se na kterém voze dělá a kolik to stojí; prodejce nafotí vůz podle šablony 16 záběrů za 5 minut a fotky jsou hned připravené pro portály i web.

## Postup

1. **Příprava (`/priprava` + záložka v kartě vozu):**
   - kanban podle stavu úkolu (Čeká · Probíhá · Hotovo) a seznam podle vozů; filtr pobočka, dodavatel, po termínu,
   - úkol: název (rychlé volby: Čištění, Leštění, Oprava, STK, Pneu, Geometrie, Ozón, Vlastní), dodavatel (vlastní dílna / externí – volný text s našeptáváním z historie), odhad ceny, termín, přiřazený člověk,
   - po dokončení úkolu se zeptá na skutečnou cenu a vytvoří `vehicle_costs` navázaný na úkol (marže se hned přepočítá),
   - vůz ve stavu `buyout` s prvním úkolem přejde do `preparation`, po dokončení všech úkolů nabídne „Připraveno k prodeji“.
2. **Předprodejní checklist (BZ3.1):** šablona `pre_sale`, výsledek do `inspections`. Nastavení firmy „Bez dokončeného checklistu nejde vůz zveřejnit“ (výchozí zapnuto) – kontrola i v databázi (funkce `can_publish(vehicle_id)` novou migrací, kterou použije fáze 07).
3. **Focení (mobil, záložka Fotky):**
   - režim „Nafotit podle šablony“: 16 záběrů (zepředu zleva, zepředu, zepředu zprava, bok levý, bok pravý, zezadu zleva, zezadu, zezadu zprava, palubní deska, tachometr, přední sedadla, zadní sedadla, kufr, motor, kolo a pneu, štítek VIN – štítek VIN se nezveřejňuje); obrys vozu jako vodítko přes náhled kamery (SVG overlay), postup po jednom, možnost přeskočit a vrátit se,
   - nahrávání z galerie hromadně, přetahování pořadí, titulní fotka = první,
   - zpracování v prohlížeči před nahráním (Web Worker + OffscreenCanvas): oříznutí na 4:3, EXIF otočení a odstranění GPS z EXIF, export WebP ve 3 velikostech 480 / 960 / 1600 px (kvalita 0.8), cesta `{company_id}/{vehicle_id}/{uuid}-{size}.webp`,
   - **ruční rozmazání SPZ:** nástroj obdélník přes fotku → rozmazání (pixelace) v canvasu, `plate_blurred = true`,
   - logo bazaru volitelně v rohu (nastavení firmy: pozice, průhlednost) – přidává se při publikaci, originál zůstává čistý,
   - offline fronta stejně jako ve výkupu.
4. **Upozornění:** vůz bez fotek nebo s méně než 8 fotkami má v kartě i na skladě štítek „Doplnit fotky“.

## Mimo rozsah

Automatické rozpoznání a rozmazání SPZ, výměna pozadí, AI úpravy (v1). Zakázka do servisu na platformě (v2).

## Akceptační kritéria

- [ ] Úkol s cenou se po dokončení propíše do nákladů a marže.
- [ ] Zapnuté pravidlo checklistu zablokuje zveřejnění i přímým voláním API (test na `can_publish`).
- [ ] 16 fotek z telefonu se zpracuje a nahraje bez zamrznutí UI (zpracování mimo hlavní vlákno), každá ve 3 velikostech, bez GPS v EXIF.
- [ ] Rozmazaná SPZ je rozmazaná i ve všech třech velikostech.
- [ ] E2e: úkol → hotovo → náklad; nahrání 3 fotek, změna pořadí, rozmazání.

## Na konci

`docs/progress.md`, větev `phase/06-priprava`, PR.
