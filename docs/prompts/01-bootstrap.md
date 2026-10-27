# Fáze 01 – Monorepo a nástroje

## Kontext

Přečti `CLAUDE.md`, `docs/integration-contract.md` a `docs/design-system.md`. Repo už obsahuje `packages/brand/` (brand.ts, tokens.css, tailwind-preset.ts), `supabase/migrations/20261027000001_init.sql`, `docs/` a `scripts/gen-data-model.py` – **nepřepisuj je**, jen je zapoj.

## Cíl

Funkční pnpm monorepo, ve kterém `pnpm dev` spustí prázdnou aplikaci, prázdný plugin a lokální Supabase, a CI na GitHubu kontroluje lint, typy a testy.

## Postup

1. **Kořen:** `package.json` (pnpm workspaces `apps/*`, `packages/*`), `pnpm-workspace.yaml`, `.nvmrc` (22), `.editorconfig`, `.gitignore` (node_modules, dist, .env*, supabase/.temp), `tsconfig.base.json` (strict, `noUncheckedIndexedAccess`, path aliasy `@bazar/*`).
2. **Kvalita:** ESLint (flat config, typescript-eslint, react-hooks, jsx-a11y), Prettier (single quotes, šířka 110), skripty `lint`, `typecheck`, `format`. Husky + lint-staged na pre-commit.
3. **`packages/brand`:** z existujících souborů udělej balíček `@bazar/brand` (exporty `BRAND`, `tailwindPreset`, cesta k `tokens.css`).
4. **`packages/shared`:** balíček `@bazar/shared` s kostrou: `format.ts` (Kč, km, datum, telefon – Intl `cs-CZ`, mezera jako oddělovač tisíců), `pricing.ts` (tarify přesně podle `docs/integration-contract.md` sekce 7), `db.types.ts` (zatím prázdný, plní fáze 02), Vitest testy formátování.
5. **`packages/documents`:** prázdný balíček `@bazar/documents` s `@react-pdf/renderer` a jedním testovacím dokumentem (hlavička s `BRAND.name`, písmo Inter s českou diakritikou – font registruj z lokálních souborů, ověř „ěščřžýáíéůú“).
6. **`apps/app`:** Vite + React 18 + TS, Tailwind s presetem `@bazar/brand`, import `tokens.css`, shadcn/ui inicializované (komponenty do `src/components/ui`), React Router, TanStack Query, Zod, React Hook Form, lucide-react, `src/i18n/cs.ts` se základními texty, `vite-plugin-pwa` (zatím jen manifest s `BRAND.name`, barvy z tokenů). Úvodní stránka zobrazí textové logo a „Aplikace běží“.
7. **`apps/widget`:** Vite library build jednoho ES modulu `widget.js`, Lit, vlastní element s názvem `BRAND.widgetTag`, Shadow DOM, zatím vypíše „Plugin běží“ a atribut `key`. Hlídání velikosti: skript `size-check` selže nad 60 kB gzip.
8. **Supabase:** `supabase init` (pokud chybí `supabase/config.toml`), zachovej existující migraci. Skripty `db:start`, `db:reset`, `db:types` (→ `packages/shared/src/db.types.ts`), `db:docs` (`python3 scripts/gen-data-model.py`).
9. **`pnpm dev`:** paralelně Supabase, aplikace (port 5173) a plugin s ukázkovou HTML stránkou (`apps/widget/demo.html`, port 5174).
10. **Env:** `apps/app/.env.example` (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_PUBLIC_API_URL`), `apps/widget/.env.example`, `supabase/functions/.env.example` se všemi proměnnými z kontraktu sekce 8 (hodnoty prázdné, `PROVIDER_*=mock`).
11. **CI:** `.github/workflows/ci.yml` – pnpm install s cache, lint, typecheck, test, build obou aplikací, size-check pluginu. E2e a RLS testy přidají pozdější fáze.
12. **Dokumentace:** doplň skutečné příkazy do `CLAUDE.md` (sekce Příkazy) a v `docs/progress.md` označ fázi 01.

## Mimo rozsah

Žádné obrazovky, přihlášení ani byznys logika. Žádné úpravy SQL migrace.

## Akceptační kritéria

- [ ] `pnpm i && pnpm dev` na čistém stroji s Dockerem spustí Supabase, aplikaci a demo pluginu.
- [ ] `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build` projdou; CI je zelené.
- [ ] Název produktu se nikde nevyskytuje natvrdo (`grep -ri "NÁZEV" apps packages` najde jen `brand.ts`).
- [ ] Testovací PDF vykreslí českou diakritiku správně.
- [ ] Plugin build ≤ 60 kB gzip.

## Na konci

Aktualizuj `docs/progress.md`, commituj na větev `phase/01-bootstrap`, otevři PR s popisem a seznamem příkazů k vyzkoušení.
