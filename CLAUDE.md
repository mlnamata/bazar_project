# CLAUDE.md – kontext projektu pro Claude Code

## Co stavíme

SaaS pro české autobazary: vůz se zadá jednou při výkupu a odtud jde do přípravy, na portály (Sauto, TipCars), na web bazaru (plugin) i do kupní smlouvy. První produkt je **bazar** – servis a díly přijdou později a teď se nestaví.

- Specifikace produktu: `docs/spec/bazar-specifikace.md` (závazná, kódy funkcí B6.x, BZ.x, BZN.x, PL.x, FI.x, A9.x)
- Rozsah MVP a akceptační kritéria: sekce „Rozsah MVP“ ve specifikaci – **co tam není, nestav**
- Širší kontext platformy: `docs/spec/platforma-navrh.md` – definuje kódy V4.x, K5.x, O5.x, A9.x, SV.x, F7.x, na které se bazar odkazuje; jinak jen pro orientaci (technická rozhodnutí níže a rozsah MVP v bazar specifikaci mají přednost)
- Datový model: `supabase/migrations/*.sql` (zdroj pravdy) a `docs/data-model.md` (generovaný přehled)
- Design: `docs/design-system.md` + `packages/brand/tokens.css`
- Propojení aplikace, pluginu a prezentačního webu: `docs/integration-contract.md`
- Prompty pro jednotlivé fáze: `docs/prompts/` (pracuj vždy jen na jedné fázi)
- Průběh: `docs/progress.md` – po každé fázi doplň, co je hotové, co ne a proč

## Název produktu

Název zatím není. **Nikdy ho nepiš natvrdo.** Vše čti z `packages/brand/brand.ts` (`BRAND.name`, `BRAND.domain`, `BRAND.widgetTag` …). Logo zatím není – používej textové logo `BRAND.name` v písmu Archivo.

## Stack (rozhodnuto, neměnit bez dotazu)

| Vrstva | Technologie |
| --- | --- |
| Monorepo | pnpm workspaces, Node 22, TypeScript strict |
| Aplikace `apps/app` | React 18, Vite, TypeScript, Tailwind CSS + `@bazar/brand` preset, shadcn/ui (Radix), React Router, TanStack Query, React Hook Form + Zod, PWA (vite-plugin-pwa, Workbox) |
| Plugin `apps/widget` | web komponenta (Lit), Shadow DOM, build jako jeden ES modul do CDN, max 60 kB gzip |
| Backend | Supabase (EU region): Postgres + RLS, Auth, Storage, Edge Functions (Deno), pg_cron, Vault |
| Sdílené balíčky | `packages/brand` (název, tokeny, Tailwind preset), `packages/shared` (typy z DB, Zod schémata, formátování Kč/km/data, výpočet splátky a RPSN), `packages/documents` (PDF šablony přes @react-pdf/renderer) |
| Testy | Vitest (jednotky), Playwright (e2e), testy RLS proti lokálnímu Supabase |
| Hosting | Vercel (aplikace + plugin na `cdn.` doméně), Supabase cloud EU |
| Prezentační web | samostatně v Lovable (jiné repo) – viz `docs/prompts/lovable-web.md`, nic z něj se v tomto repu nestaví |

## Struktura repozitáře

```
apps/app/              React aplikace pro bazary (PWA)
apps/widget/           plugin na web bazaru (web komponenta)
packages/brand/        BRAND, tokeny, Tailwind preset
packages/shared/       typy, schémata, formátování, finanční výpočty
packages/documents/    PDF šablony smluv, faktur, protokolů
supabase/migrations/   SQL migrace (nikdy needituj starou, vždy přidej novou)
supabase/functions/    edge funkce; _shared/providers/ = adaptéry externích služeb
supabase/seed.sql      systémové šablony + demo firma
docs/                  specifikace, design, kontrakt, prompty, průběh
scripts/               pomocné skripty (gen-data-model.py)
```

## Pravidla

1. **Jazyk:** kód, názvy souborů, proměnných a DB anglicky. Vše, co vidí uživatel, česky – texty v `apps/app/src/i18n/cs.ts`, žádné řetězce natvrdo v komponentách. Formát: `259 900 Kč`, `128 400 km`, `27. 10. 2026`.
2. **Multitenance:** každá firemní tabulka má `company_id` a RLS. Nikdy neobcházej RLS z klienta. Service role jen v edge funkcích a jen tam, kde to kontrakt výslovně říká (veřejné API pluginu, registrace z webu, worker publikace).
3. **Externí služby jen přes adaptéry** v `supabase/functions/_shared/providers/<oblast>/` s rozhraním, implementací `mock` a skutečnou implementací. Volba přes env `PROVIDER_<OBLAST>=mock|real`. Bez klíčů musí celá aplikace běžet na mockech (demo režim = klikací prototyp).
4. **Tajemství:** API klíče jen v env edge funkcí; hesla k portálům v Supabase Vault (`channel_accounts.secret_id`). Nic tajného do klienta ani do gitu.
5. **Peníze a DPH:** `numeric(12,2)` v Kč. Ojeté vozy se standardně prodávají ve zvláštním režimu pro použité zboží (`vat_mode = 'margin'`) – faktura DPH nevyčísluje a nese text „Zvláštní režim – použité zboží“.
6. **AI texty:** každá věta musí mít zdroj v datech vozu (`ai_texts.sources`). Zakázané tvrzení bez dat (např. „nehavarované“ bez prověrky bez nálezu). Text vždy schvaluje člověk.
7. **Mobil:** výkup, focení a zkušební jízda musí fungovat na telefonu a přežít výpadek signálu (rozpracovaný stav v IndexedDB, odeslání po připojení).
8. **Přístupnost a výkon:** kontrast 4.5 : 1, ovládání klávesnicí, cíl první načtení aplikace < 2 s na 4G; plugin výpis < 2,5 s na mobilu.
9. **Bez scrapování** portálů ani jiných webů.
10. **Malé kroky:** každá fáze = vlastní větev `phase/NN-nazev`, malé commity, na konci PR s popisem, co je hotové a jak to otestovat.

## Příkazy (doplň v prompt 01, udržuj aktuální)

```
pnpm i                 instalace
pnpm dev               aplikace + plugin + lokální Supabase
pnpm test              Vitest ve všech balíčcích
pnpm test:e2e          Playwright
pnpm test:rls          testy izolace firem proti lokálnímu Supabase
pnpm db:reset          lokální DB z migrací + seed
pnpm db:types          vygeneruje packages/shared/src/db.types.ts
pnpm db:docs           přegeneruje docs/data-model.md
pnpm lint && pnpm typecheck
```

## Definice hotového pro každou fázi

- Splněná akceptační kritéria z promptu fáze, testy zelené, `pnpm lint && pnpm typecheck` bez chyb.
- Funguje na mocích bez jakýchkoli klíčů.
- Nové texty česky v `cs.ts`, nové tabulky s RLS a testem izolace.
- Aktualizovaný `docs/progress.md` a případně `docs/integration-contract.md`.
- Když něco ve specifikaci chybí nebo si odporuje, **zeptej se** – nevymýšlej obchodní pravidla.
