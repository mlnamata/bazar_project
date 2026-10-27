# Fáze 12 – Kontrola kvality, bezpečnost a nasazení MVP

## Kontext

Přečti `CLAUDE.md`, ve specifikaci „Rozsah MVP“ a **akceptační kritéria MVP 1–7**, `docs/integration-contract.md` a `docs/progress.md`.

## Cíl

Prokázat automatickými testy, že MVP splňuje všech 7 akceptačních kritérií, opravit nalezené problémy a nasadit produkční prostředí pro první 3 pilotní bazary.

## Postup

1. **Revize stavu:** projdi `docs/progress.md` a ve specifikaci každý bod označený v „Rozsah MVP“ jako V MVP. Vytvoř `docs/mvp-audit.md`: bod → hotovo / částečně / chybí → odkaz na kód a test. Chybějící doplň nebo se zeptej.
2. **E2e test pro každé akceptační kritérium** (`e2e/acceptance/*.spec.ts`, Playwright, mock adaptéry):
   1. registrace a import 100 vozů z CSV do 30 min (měř čas běhu kroků, ne reálných 30 min),
   2. výkup → zveřejnění na 3 kanálech, měř počet kroků a čas,
   3. změna ceny propsaná na všechny kanály do 5 min a stažení po prodeji (worker spouštěný v testu),
   4. smlouva, protokol a faktura bez ručního přepisu (kontrola obsahu PDF),
   5. plugin na prázdné stránce + Lighthouse mobile,
   6. izolace firem – `test:rls` + pokus o čtení cizích dat přes UI a API,
   7. výkup, focení a zkušební jízda na mobilním viewportu s výpadkem sítě.
3. **Bezpečnost:** kontrola, že service role klíč není v klientu ani v buildu; všechny edge funkce ověřují JWT kromě veřejných podle kontraktu; rate limity; CSP hlavičky aplikace; závislosti (`pnpm audit`); hesla jen ve Vault; logy bez osobních údajů a tajemství; Supabase Advisors (security + performance) bez kritických nálezů; záloha a obnova DB vyzkoušená.
4. **GDPR:** zpracovatelská smlouva (šablona v `docs/legal/` k doplnění advokátem), záznam o činnostech zpracování, retenční lhůty (dokumenty prodeje 10 let kvůli dani, leady 3 roky – potvrdí advokát) jako konfigurace a noční úloha mazání, export a výmaz na žádost (fáze 08).
5. **Monitoring:** Sentry (aplikace, plugin, edge funkce) se scrubováním osobních údajů, uptime kontrola `public-api` a `platform-signup`, upozornění při chybách publikace nad 5 % a frontě starší 15 min.
6. **Nasazení:**
   - Supabase produkční projekt v EU (Frankfurt), migrace přes CI (`supabase db push` jen z `main`), secrets, pg_cron úlohy, Vault,
   - Vercel: `apps/app` na `app.{BRAND.domain}`, `apps/widget` build na `cdn.{BRAND.domain}/widget/v1/` (immutable cache pro verzované soubory, 1 h pro `widget.js`), preview prostředí pro PR,
   - prostředí `staging` s vlastním Supabase projektem a mocky,
   - `docs/runbook.md`: nasazení, rollback, rotace klíčů, obnova zálohy, co dělat při výpadku portálu.
7. **Pilotní provoz:** feature flag `pilot` pro první 3 firmy, in-app tlačítko „Nahlásit problém“ (screenshot + popis do e-mailu/GitHub issue), týdenní export metrik (počet vozů, publikací, leadů, chyb) pro schůzku s piloty.

## Akceptační kritéria

- [ ] Všech 7 akceptačních testů zelených v CI na stagingu.
- [ ] `docs/mvp-audit.md` bez položky „chybí“ (nebo s vědomým rozhodnutím majitele).
- [ ] Produkce běží na doménách z `BRAND`, plugin z CDN, demo funguje, registrace z webu doručí e-mail.
- [ ] Runbook vyzkoušený: rollback aplikace a obnova DB ze zálohy na stagingu.

## Na konci

`docs/progress.md` (MVP hotovo), tag `v1.0.0-mvp`, release notes v češtině pro piloty.
