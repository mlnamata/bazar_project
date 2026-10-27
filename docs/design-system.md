# Design systém

Platí pro aplikaci (`apps/app`), plugin (`apps/widget`) i prezentační web (Lovable). Zdroj pravdy pro hodnoty je `packages/brand/tokens.css`. Název a logo zatím nejsou – všude se používá `BRAND` z `packages/brand/brand.ts` a textové logo (wordmark).

## Charakter

Kombinace tří poloh:

| Poloha | Co z ní bereme | Kde se projeví |
| --- | --- | --- |
| Důvěryhodný pracovní nástroj | tmavě modrá, klid, husté a čitelné tabulky, žádné efekty kvůli efektu | navigace, tabulky skladu, formuláře, dokumenty |
| Moderní tech produkt | světlé plochy, zaoblení 10 px, vzdušné karty, jemné stíny, rychlé mikrointerakce (150 ms) | karty vozů, dashboard, prezentační web |
| Autosvět | signální oranžová jako jediný akcent, kondenzované písmo pro velká čísla a nadpisy, diagonální řez v hero sekcích webu | ceny, marže, KPI, CTA, odznaky „Prověřeno“ |

Pravidlo: na obrazovce je oranžová nejvýš jednou až dvakrát (hlavní akce, aktivní stav). Všechno ostatní je modrá škála a neutrální šedé.

## Barvy

| Token | Světlý | Použití |
| --- | --- | --- |
| `--primary` | #0F2742 | hlavní tlačítka, navigace, text nadpisů na webu |
| `--accent` | #FF5A1F | hlavní CTA, aktivní záložka, odznak, zvýraznění ceny |
| `--background` | #F6F7F9 | plocha aplikace |
| `--surface` | #FFFFFF | karty, tabulky, dialogy |
| `--foreground` | #0F1C2B | text |
| `--muted-foreground` | #5B6676 | vedlejší text, popisky |
| `--border` | #E1E6ED | linky, okraje |
| `--success` | #12A150 | prověřeno, online, prodáno |
| `--warning` | #F5A524 | pozor, vůz dlouho na skladě |
| `--danger` | #E5383B | chyba importu, závada, odcizeno |
| `--info` | #2563EB | odkazy, informace |

Stavy vozu mají vlastní barvy štítků (`--status-*`), ale vždy s textem – barva nikdy nenese význam sama. Tmavý režim je v aplikaci od MVP (mechanici a prodejci večer na ploše), na webu není potřeba.

## Typografie

- **Inter** (400/500/600/700) – veškerý text rozhraní. Čísla v tabulkách a cenách vždy `tabular-nums`.
- **Archivo** kondenzované (`font-stretch: 85%`, 600–800) – nadpisy webu, velká čísla (cena, marže, KPI), název vozu na kartě.
- Velikosti aplikace: 12 / 14 (základ) / 16 / 20 / 24 / 32. Web: základ 17, hero 48–64.
- Ceny: `259 900 Kč` (mezera jako oddělovač tisíců, Kč za číslem), km: `128 400 km`, datum `27. 10. 2026`.

## Komponenty

Aplikace staví na **shadcn/ui** (Radix) s tokeny výše. Povinné vlastní komponenty:

- `VehicleStatusBadge` – stav vozu, barva + text + ikona.
- `PriceTag` – cena v Archivo, volitelně přeškrtnutá původní a měsíční splátka pod ní.
- `MarginCell` – marže v Kč a %, zelená / šedá / červená podle znaménka.
- `DaysInStock` – dny na skladě, od 60 dní warning, od 90 danger.
- `VerifiedBadge` – „Prověřeno“ s datem a zdrojem prověrky.
- `ChannelStatus` – stav inzerátu na portálu (online / čeká / chyba) s odkazem.
- `PhotoGrid` – mřížka fotek s přetahováním pořadí.
- `Wizard` – průvodce v mobilu (výkup), krokový, s offline uložením rozpracovaného stavu.
- `EmptyState` – každá prázdná obrazovka říká, co udělat jako první, s jedním tlačítkem.

Ikony: **lucide-react**, tloušťka 1.75. Žádné emoji v rozhraní.

## Rozvržení aplikace

- Počítač: levý panel navigace (tmavě modrý, 248 px, sbalitelný), horní lišta s vyhledáváním (VIN, SPZ, jméno, telefon) a přepínačem pobočky.
- Mobil (PWA): spodní lišta s 5 položkami – Přehled, Sklad, + (výkup / nový vůz), Leady, Více. Velké dotykové cíle min. 44 px, hlavní akce vždy dole v dosahu palce.
- Tabulky: hustota 44 px řádek, první sloupec fotka 64×48 + název vozu, čísla zarovnaná vpravo, sticky hlavička.

## Tón komunikace

- Česky, krátce, věcně. V aplikaci neutrální rozkazovací tvar na tlačítkách („Uložit vůz“, „Zveřejnit“), oslovení vykáním v textech. Prezentační web vyká.
- Chyby říkají, co se stalo a co udělat: „Sauto odmítlo inzerát: chybí počet dveří. Doplňte ho v kartě vozu.“ – nikdy „Error 400“.
- Žádný žargon vývojářů, žádné anglicismy, kde je běžné české slovo (inzerát, ne listing; vůz, ne vehicle).
- Na webu konkrétní přínosy s čísly („Vůz na 3 portálech za 10 minut“), žádné superlativy bez důkazu.

## Přístupnost a výkon

- Kontrast textu min. 4.5 : 1, focus ring vždy viditelný (`--ring`).
- Plugin: max. 60 kB JS (gzip) bez fotek, fotky WebP v 3 velikostech (480 / 960 / 1600), lazy loading.
- Aplikace: první načtení do 2 s na 4G, interakce do 100 ms.
