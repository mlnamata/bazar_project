# Prompty – jak s nimi pracovat

Sada promptů staví celý systém postupně: 12 fází v Claude Code (aplikace, plugin, backend) a jeden prompt pro Lovable (prezentační web). Všechny čtou stejné zdroje pravdy, takže do sebe zapadají:

- `CLAUDE.md` – stack, pravidla, struktura (Claude Code ho načte sám)
- `docs/spec/bazar-specifikace.md` – co a proč
- `docs/integration-contract.md` – URL, API, sdílený ceník a vzhled mezi aplikací, pluginem a webem
- `supabase/migrations/` + `docs/data-model.md` – data
- `docs/design-system.md` + `packages/brand/` – vzhled a název

## Pořadí

| # | Soubor | Výsledek | Závisí na |
| --- | --- | --- | --- |
| 01 | `01-bootstrap.md` | monorepo, nástroje, CI, kostry aplikace a pluginu | – |
| 02 | `02-database.md` | Supabase lokálně, migrace, storage, seed s demo firmou, testy RLS, typy | 01 |
| 03 | `03-app-shell.md` | přihlášení, onboarding firmy, rozvržení, navigace, role, PWA, demo přihlášení | 02 |
| 04 | `04-sklad-karta-vozu.md` | sklad vozů, karta vozu, ekonomika, dokumenty, import CSV | 03 |
| 05 | `05-vykup-vin-proverka.md` | průvodce výkupem, VIN, prověrka, km, ocenění, výkupní smlouva | 04 |
| 06 | `06-priprava-fotky.md` | úkoly přípravy, předprodejní checklist, focení 16 záběrů | 04 |
| 07 | `07-inzerce-publikace.md` | AI texty, publikace Sauto + TipCars + web, fronta, stavy a chyby | 05, 06 |
| 08 | `08-leady-prodej-doklady.md` | leady, zkušební jízda, prodej, smlouvy, faktury, export | 07 |
| 09 | `09-plugin.md` | plugin na web, veřejné API, veřejná stránka vozu, QR | 07 |
| 10 | `10-fi-kalkulacka.md` | kalkulačka splátek, poptávka financování | 08, 09 |
| 11 | `11-prehledy-nastaveni.md` | přehled dne, přehledy, nastavení, portálové účty, registrace z webu, demo reset | 10 |
| 12 | `12-qa-release.md` | e2e testy akceptačních kritérií, bezpečnost, výkon, nasazení | vše |
| – | `lovable-web.md` | prezentační web v Lovable | kdykoli; formulář funguje po fázi 11 |
| – | `lovable-web-fix.md` | opravy webu, aby nevypadal jako AI (9 kroků) | po `lovable-web.md` |
| – | `lovable-dashboard.md` | UI aplikace v Lovable jako klikací prototyp s mock daty; pak převezme Claude Code do `apps/app` | před fází 03 |

Fáze 05 a 06 jdou paralelně (různé větve). Lovable web můžeš stavět hned – do fáze 11 formulář jen ukáže hlášku a demo pluginu se zobrazí po fázi 09.

## Jak spustit jednu fázi

1. V Claude Code otevři repo a napiš: `Přečti docs/prompts/NN-….md a proveď tuto fázi.` (nebo obsah souboru vlož celý).
2. Nech Claude nejdřív předložit plán; schval ho nebo oprav.
3. Po dokončení zkontroluj PR podle sekce „Akceptační kritéria“ v promptu, spusť `pnpm dev` a proklikej.
4. Mergni a pokračuj další fází v **nové konverzaci** (čistý kontext, CLAUDE.md se načte znovu).

## Co budeš potřebovat

| Kdy | Co |
| --- | --- |
| hned | Node 22, pnpm, Docker (lokální Supabase), účet Supabase (projekt v regionu EU – Frankfurt), účet Vercel |
| fáze 07 | Anthropic API klíč pro AI texty (jinak běží mock) |
| fáze 07 | testovací přístup Sauto (softwarový klíč od Seznamu) a TipCars – do té doby mock |
| fáze 05 | Vincario API klíč, smlouva s Cebia – do té doby mock |
| fáze 08 | SMS brána a e-mailová služba – do té doby mock |
| fáze 12 | doména (až bude název), DNS pro `app.` a `cdn.` |

## Až bude název

1. Změň `packages/brand/brand.ts`.
2. V Lovable pošli: „Změň název produktu na X a doménu na Y všude na webu.“
3. Zaregistruj doménu, nastav DNS podle `docs/integration-contract.md`.
