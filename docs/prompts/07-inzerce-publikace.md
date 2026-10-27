# Fáze 07 – AI texty a publikace na Sauto, TipCars a web

## Kontext

Přečti `CLAUDE.md` (pravidlo 6 o AI textech), `docs/integration-contract.md` sekce 8; ve specifikaci **A9.8–A9.11 (čeština), A9.13, A9.14, B6.8**, tabulku portálů v sekci „Portály, prověrky a dokumenty“, akceptační kritéria MVP 2 a 3; v datovém modelu `listings`, `publication_jobs`, `channel_accounts`, `ai_texts`.

## Cíl

Prodejce vygeneruje pravdivý text inzerátu, zaškrtne portály a jedním klikem vůz zveřejní. Změna ceny se propíše všude do 5 minut, prodaný vůz zmizí ze všech portálů sám a chyby portálů jsou srozumitelné.

## Postup

1. **AI texty (edge funkce `ai-listing-text`, adaptér `ai/`):**
   - vstup: data vozu, výbava, prověrka (souhrn), časová osa km, checklist (silné stránky a vady), cena, tón (`věcný | prodejní | prémiový`), kanál (Sauto má limit délky – zjisti z dokumentace, TipCars, web),
   - model vrátí JSON `{title, description, keywords[], sentences: [{text, sources: ['equipment.heated_seats', 'check.no_findings', …]}]}`; funkce ověří, že každý zdroj existuje v datech, věty bez platného zdroje zahodí,
   - **zakázaná tvrzení** bez dat: „nehavarované“, „garance km“, „1. majitel“, „servisní knížka“, „bez investic“ … – seznam v `packages/shared/src/ai-rules.ts`, test na každé,
   - prompt pro model v češtině, krátké věty, žádné superlativy, vady pravdivě a věcně; tón podle volby,
   - mock vytvoří text šablonou z dat (aby šlo testovat bez klíče),
   - UI v záložce Inzerce: tlačítko Vygenerovat, editor textu, u věty na najetí zdroj („z výbavy: vyhřívaná sedadla“), schválení člověkem → `ai_texts.approved_*`, text se uloží do `vehicles.title/description`.
2. **Adaptéry portálů (`portals/sauto`, `portals/tipcars`):** rozhraní `upsert(listingPayload)`, `remove(externalId)`, `validate(payload)` → seznam chyb v češtině. Mapování číselníků (značka, model, karoserie, palivo, výbava) jako tabulky v `supabase/functions/_shared/providers/portals/<portál>/maps.ts`. **Sauto:** importní rozhraní XML-RPC podle oficiální importní dokumentace Sauto (přihlášení softwarovým klíčem, vložení/úprava auta, fotky, smazání); **TipCars:** dealerský import podle jejich dokumentace. Když dokumentace v době vývoje nemáš, implementuj mock + validaci povinných polí a nech v kódu přesný TODO s odkazem – nehádej formát.
3. **Fronta publikace:**
   - akce v UI (zveřejnit / stáhnout / hromadně) zapíše `listings` + `publication_jobs`,
   - trigger na `vehicles` (cena, text, fotky, stav) vytvoří `upsert` job pro všechny `live` listingy; stav `sold`/`written_off` vytvoří `remove`; `payload_hash` brání zbytečnému odesílání,
   - worker = edge funkce `publication-worker` spouštěná pg_cron každou minutu (`select … for update skip locked`), max 3 pokusy s backoffem 1/5/15 min, chyby do `listings.last_error` česky,
   - kanál `web` = jen nastaví `is_public` (plugin čte přímo),
   - před publikací `can_publish(vehicle_id)` (fáze 06) + validace adaptéru; bez přístupů k portálu tlačítko vysvětlí, kde je nastavit.
4. **UI:** záložka Inzerce v kartě vozu – stav po kanálech (`ChannelStatus`: online s odkazem, čeká, chyba s textem a tlačítkem Opravit → skočí na pole), poslední synchronizace; na skladě sloupec kanálů a hromadné akce Zveřejnit / Stáhnout; přehled chyb publikace pro přehled dne.
5. **Odznak prověření (B6.8):** když `verified = true`, inzerát a plugin nesou „Prověřeno {datum}“ a odkaz na protokol vozu; text inzerátu to smí zmínit.
6. **Nastavení portálů** (`/nastaveni/firma/portaly`, jen majitel): přihlašovací údaje → edge funkce uloží heslo do Vault a do `channel_accounts.secret_id`, tlačítko „Ověřit připojení“.

## Akceptační kritéria

- [ ] Na mocích: vůz zveřejněný na 3 kanálech; změna ceny vytvoří joby a do 2 minut jsou všechny kanály `live` s novou cenou; prodej vůz stáhne všude (test kritéria MVP 3).
- [ ] AI text nikdy neobsahuje zakázané tvrzení bez dat (testy na 20 vozech z demo seedu s mock i skutečným modelem, je-li klíč).
- [ ] Chyba validace se ukáže česky u konkrétního pole.
- [ ] Hesla k portálům nejsou v žádné tabulce ani v logu.
- [ ] E2e: vygenerovat text, schválit, zveřejnit, změnit cenu, prodat.

## Na konci

`docs/progress.md`, aktualizuj tabulku adaptérů v `docs/integration-contract.md`, větev `phase/07-inzerce`, PR.
