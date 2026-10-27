# Fáze 02 – Databáze, storage, seed a testy izolace

## Kontext

Přečti `CLAUDE.md`, `supabase/migrations/20261027000001_init.sql`, `docs/data-model.md` a sekce 4 a 8 v `docs/integration-contract.md`. Migrace je otestovaná – **neměň ji**, změny dělej novými migracemi.

## Cíl

Lokální Supabase se schématem, storage buckety s politikami, seed s realistickou demo firmou a automatické testy, které dokazují, že firma nikdy nevidí data jiné firmy.

## Postup

1. **Granty:** nová migrace `…_grants.sql` – `grant usage on schema public to anon, authenticated`; tabulky a sekvence pro `authenticated` (RLS dál chrání řádky); `anon` nesmí nic kromě explicitně povolených funkcí. `execute` na `create_company`, `next_number`, `is_member`, `has_role` jen pro `authenticated`.
2. **Storage:** migrace s buckety `vehicle-photos` (public read) a `documents` (private). Politiky `storage.objects`: insert/update/delete jen když `(storage.foldername(name))[1]::uuid` je firma, kde je uživatel členem (`is_member`); čtení `documents` stejně, `vehicle-photos` čte kdokoli.
3. **Profil:** trigger na `auth.users` (after insert) založí řádek v `profiles` s `full_name` z `raw_user_meta_data`.
4. **Seed `supabase/seed.sql`:**
   - systémové šablony checklistů: výkupní (cca 40 položek ve skupinách Karoserie, Interiér, Motor a převodovka, Podvozek a brzdy, Pneu – u pneu měření hloubky dezénu v mm, Doklady a klíče) a předprodejní (cca 20 položek); položky v češtině,
   - systémové šablony dokumentů D1–D8 jako jednoduché HTML s proměnnými (`{{vehicle.make}}`) a jasnou hlavičkou „VZOR – ke kontrole advokátem“,
   - jeden mock F&I partner („Demo Finance“, úvěr 9,9 % p. a., 12–84 měsíců, akontace od 0 %, max. stáří vozu 12 let),
   - **demo firma** `Autobazar Demo s.r.o.` s `is_demo = true` a `public_key = 'demo'`, pobočka v Plzni s otevírací dobou, demo uživatel `demo@{BRAND.domain}` (role sales) a majitel `majitel@{BRAND.domain}`, heslo z env `DEMO_PASSWORD`,
   - **25 vozů** s realistickými českými daty (Škoda Octavia, Fabia, Superb, Kodiaq, VW Golf, Passat, Tiguan, Hyundai i30, Kia Ceed, Toyota Corolla, Ford Focus, BMW 320d, Audi A4 …), ročníky 2012–2022, km 40–260 tis., ceny 120–650 tis. Kč, různé stavy (5 výkup/příprava, 15 inzerováno, 2 rezervováno, 3 prodáno), náklady na přípravu, záznamy km (2–5 na vůz, jeden vůz se stočenými km), prověrky (mock), 3–8 leadů, 1 dokončený prodej s fakturou,
   - fotky: zástupné obrázky ve `supabase/seed/photos/` (vygeneruj jednoduché SVG→WebP siluety aut s barvou vozu, ne cizí fotky) a skript, který je nahraje do storage.
5. **Typy:** `pnpm db:types` a export pohodlných typů v `@bazar/shared` (`Vehicle`, `VehicleStatus`, `Lead` …) + Zod schémata pro formuláře (VIN regex bez I, O, Q; IČO s kontrolním součtem; telefon CZ/SK/DE).
6. **Testy RLS** (`supabase/tests/rls.test.ts`, Vitest proti lokálnímu Supabase, skript `pnpm test:rls`): dvě firmy, uživatelé ve všech rolích. Pro **každou** firemní tabulku ověř: cizí firma nečte, nevloží, neupraví, nesmaže; výkupčí nevidí `sales`/`invoices`; jen majitel vidí `channel_accounts` a `audit_log`; anon nevidí nic; storage cesta jiné firmy je zakázaná. Test musí selhat, když se přidá tabulka s `company_id` bez RLS (kontrola přes `pg_tables` + `pg_policies`).
7. **CI:** přidej job s `supabase start`, `db:reset` a `test:rls`.
8. `pnpm db:docs` a commit vygenerovaného `docs/data-model.md`.

## Akceptační kritéria

- [ ] `pnpm db:reset` vytvoří schéma, buckety a demo data bez chyb.
- [ ] Testy RLS pokrývají všechny tabulky s `company_id` a jsou zelené v CI.
- [ ] Přihlášení jako demo uživatel (přes Supabase Studio nebo test) vidí 25 vozů demo firmy, cizí uživatel 0.
- [ ] Typy v `@bazar/shared` odpovídají DB, `pnpm typecheck` projde.

## Na konci

`docs/progress.md`, větev `phase/02-database`, PR.
