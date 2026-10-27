# Fáze 11 – Přehled dne, přehledy, nastavení firmy, registrace z webu a demo

## Kontext

Přečti `CLAUDE.md`, `docs/integration-contract.md` sekce 2, 3 a 7; ve specifikaci **A9.1, A9.2 (web)**, obrazovky 1, 12 a 14, ceník a pravidla CB.1–CB.5.

## Cíl

Majitel ráno na jedné obrazovce vidí, co má dnes dělat, a jednou za měsíc, jak bazar vydělává. Firma si sama nastaví vše potřebné. Prezentační web posílá registrace pilotů do systému a demo se každou noc samo obnoví.

## Postup

1. **Přehled dne (`/`, obrazovka 1):** karty – nové leady (nepřiřazené zvýrazněné), dnešní prohlídky a zkušební jízdy (časová osa), vozy nad 60 / 90 dní s návrhem akce, chyby publikace, úkoly přípravy po termínu, vozy bez fotek / bez textu / bez ceny, poptávky financování čekající na odpověď. Každá položka vede přímo k akci. Prodejce vidí jen svoje, majitel vše s filtrem pobočky.
2. **Přehledy (`/prehledy`, obrazovka 12, majitel a účetní):**
   - Moje firma (A9.1): tržby a marže po měsících (sloupcový graf), marže na voze (průměr, medián, rozložení), obrátka skladu, průměrné dny na skladě, prodeje a marže po prodejcích, hodnota skladu v čase,
   - Výkon inzerátů na webu (A9.2 web): zobrazení výpisu a detailů, kontakty a leady po vozech z `web_events` a `leads`, konverze detail → lead, vozy s mnoha zobrazeními a bez dotazu (kandidáti na slevu),
   - období (měsíc, kvartál, rok, vlastní), export CSV; grafy přes Recharts v barvách tokenů; agregace v SQL (pohledy nebo funkce novou migrací), ne v prohlížeči.
3. **Nastavení firmy (`/nastaveni/firma`, obrazovka 14):** údaje a logo (nahrání, ořez, použije se v PDF, pluginu a na fotkách), pobočky a otevírací doba, uživatelé (z fáze 03), portály (z fáze 07), financování (z fáze 10), šablony dokumentů (náhled systémových, nahrání vlastních HTML šablon schválených advokátem, verze), výchozí hodnoty (marže pro ocenění, paušály oprav, záruka 12/24, splatnost faktur, číselné řady a prefixy), notifikace, tarif (aktuální tarif, počet vozů vůči limitu, „Změnit tarif“ = žádost e-mailem; platba kartou je v1), export všech dat firmy (ZIP CSV + dokumenty) a zrušení účtu.
4. **Registrace z webu:** edge funkce `platform-signup` přesně podle kontraktu sekce 3 (Zod, honeypot, rate limit, CORS jen na domény webu a Lovable náhledy, české chybové hlášky), zápis do `platform_signups`, e-mail na `BRAND.supportEmail` a potvrzovací e-mail zájemci. Jednoduchý interní přehled registrací pro správce platformy (role `platform_admin` přes claim v JWT nebo seznam e-mailů v env – rozhodni a zdokumentuj).
5. **Demo:** pg_cron každou noc ve 3:00 smaže data demo firmy a znovu nahraje seed (funkce `reset_demo()` novou migrací); demo uživatel nemůže měnit nastavení firmy, portály ani uživatele (RLS + UI); veřejná ukázka `key="demo"` funguje vždy.
6. **Onboarding checklist:** pro novou firmu na přehledu dne karta „Začínáme“ – doplnit údaje a logo, importovat sklad, nastavit portály, vložit plugin na web, pozvat kolegy, nafotit první vůz; postup v procentech.

## Akceptační kritéria

- [ ] Přehled dne demo firmy ukáže všechny typy položek a každá vede k akci.
- [ ] Čísla v přehledech sedí s ručním výpočtem na demo datech (test na SQL funkcích).
- [ ] `curl` na `platform-signup` s platnými daty vrátí 201 a záznam; s honeypotem 200 bez záznamu; z cizí domény CORS odmítne.
- [ ] Po `reset_demo()` je demo ve výchozím stavu a cizí firmy nedotčené (test).
- [ ] Export dat firmy obsahuje všechny její tabulky a dokumenty a nic cizího.

## Na konci

`docs/progress.md`, větev `phase/11-prehledy`, PR.
