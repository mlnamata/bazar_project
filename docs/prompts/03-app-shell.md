# Fáze 03 – Přihlášení, onboarding a kostra aplikace

## Kontext

Přečti `CLAUDE.md`, `docs/design-system.md` (sekce Rozvržení, Komponenty, Tón), `docs/integration-contract.md` sekce 2 a ve specifikaci sekce „Obrazovky MVP“ a „Rozsah MVP“ (řádek Účet a firma).

## Cíl

Uživatel se zaregistruje, založí firmu, přihlásí se na počítači i telefonu a vidí navigaci se všemi 14 obrazovkami MVP (zatím prázdné stavy). Majitel pozve kolegy s rolemi.

## Postup

1. **Supabase klient** (`src/lib/supabase.ts`), `AuthProvider`, hook `useSession`, `useCompany` (aktuální firma v `localStorage` + přepínač, když je uživatel ve více firmách – R2).
2. **Routy (React Router):**
   - veřejné: `/prihlaseni` (e-mail + heslo, odkaz pro magic link), `/registrace` (jméno, e-mail, heslo, souhlas s podmínkami; čte `plan` a `utm_*` z URL), `/zapomenute-heslo`, `/pozvanka/:token`, `/demo`, `/v/:publicKey/:vehicleId` (zatím placeholder, plní fáze 09),
   - po přihlášení bez firmy: `/onboarding` – IČO → načtení z ARES (edge funkce `ares-lookup`, adaptér `ares` s mockem; ARES REST API je veřejné) → předvyplněný název, adresa, DIČ → `create_company` → uložit `plan` a `utm` do `companies.settings.signup`,
   - aplikace: `/` Přehled dne, `/sklad`, `/vuz/:id`, `/vykup/novy`, `/priprava`, `/leady`, `/prodej/:id`, `/zakaznici`, `/prehledy`, `/nastaveni/web`, `/nastaveni/firma` (+ podstránky uživatelé, portály, dokumenty, tarif).
3. **Rozvržení podle design systému:** levý tmavě modrý panel 248 px (sbalitelný, ikony lucide), horní lišta s globálním vyhledáváním (zatím jen UI: VIN, SPZ, jméno, telefon), přepínačem pobočky a menu uživatele; na mobilu spodní lišta Přehled · Sklad · + · Leady · Více, kde „+“ otevře volbu Výkup / Nový vůz. Tmavý režim přepínatelný a podle systému.
4. **Role:** hook `useRole()` a komponenta `<RequireRole roles={[…]}>`. Navigace skrývá, co role nesmí (výkupčí nevidí Prodej a Přehledy financí, účetní nevidí Výkup). Server to stejně hlídá RLS – UI je jen pohodlí.
5. **Uživatelé a pozvánky** (`/nastaveni/firma/uzivatele`, jen majitel): seznam členů, pozvat e-mailem s rolí (edge funkce `invite-member` přes `auth.admin.inviteUserByEmail` + řádek `memberships` po přijetí), změna role, deaktivace. Limit uživatelů podle tarifu z `@bazar/shared/pricing`.
6. **Demo přihlášení:** `/demo` zavolá edge funkci `demo-login`, která přihlásí sdíleného demo uživatele (heslo z env) a vrátí session; v aplikaci je pak nahoře pruh „Prohlížíte demo – změny se každou noc smažou“ s tlačítkem „Vyzkoušet na vlastních datech“ → `/registrace`.
7. **Společné komponenty:** `PageHeader`, `EmptyState` (každá prázdná obrazovka říká, co udělat jako první, jedno tlačítko), `ErrorBoundary` s českou hláškou, toasty, `ConfirmDialog`, `DataTable` (TanStack Table, sticky hlavička, řádek 44 px, čísla vpravo, tabular-nums), `VehicleStatusBadge`, `PriceTag`, `MarginCell`, `DaysInStock`, `VerifiedBadge`, `ChannelStatus` (podle `docs/design-system.md`). Storybook není potřeba – udělej `/dev/komponenty` dostupné jen v dev režimu.
8. **PWA:** manifest (název z `BRAND`, ikony = textové logo na tmavě modrém čtverci, generované), offline shell, stránka „Jste offline“ pro routy bez dat. Instalační výzva po 2. návštěvě.
9. **Texty:** vše do `src/i18n/cs.ts`; hlášky Supabase Auth přelož (neplatné heslo, e-mail už existuje …).

## Mimo rozsah

Obsah obrazovek (sklad, výkup …) – jen prázdné stavy. Platba tarifu.

## Akceptační kritéria

- [ ] Registrace → potvrzení e-mailu (lokálně Inbucket) → onboarding s IČO z ARES (mock i real) → přehled dne.
- [ ] Majitel pozve prodejce, ten se přihlásí a nevidí nastavení firmy.
- [ ] `/demo` přihlásí demo uživatele bez zadávání hesla a ukáže pruh demo režimu.
- [ ] Na telefonu (375 px) je spodní lišta, na počítači levý panel; ovládání klávesnicí funguje, focus je vidět.
- [ ] Playwright e2e: registrace + onboarding, přihlášení, odhlášení, demo, oprávnění podle role.

## Na konci

`docs/progress.md`, větev `phase/03-app-shell`, PR se screenshoty (desktop, mobil, tmavý režim).
