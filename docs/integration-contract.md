# Integrační kontrakt

Jak spolu mluví tři části systému. Kdo mění cokoli v tomto souboru, musí upravit všechny strany (aplikaci, plugin, prompt pro Lovable) ve stejném PR.

```
                 ┌───────────────────────────┐
  návštěvník ──▶ │ Prezentační web (Lovable) │ {BRAND.domain}
                 │  - demo pluginu            │──┐ POST /platform-signup
                 │  - registrace pilotů       │  │ odkaz /registrace, /demo
                 └───────────────────────────┘  │
                                                ▼
  bazar ───────▶ ┌───────────────────────────┐   ┌──────────────────────┐
                 │ Aplikace apps/app (PWA)   │◀─▶│ Supabase (EU)        │
                 │ app.{BRAND.domain}         │   │ Postgres+RLS, Auth,  │
                 └───────────────────────────┘   │ Storage, Edge Fn,    │
                                                 │ pg_cron, Vault       │
  web bazaru ──▶ ┌───────────────────────────┐   │                      │
  (zákazník)     │ Plugin apps/widget         │──▶│ /public-api/*        │
                 │ cdn.{BRAND.domain}         │   └──────────┬───────────┘
                 └───────────────────────────┘              │ adaptéry
                                              Sauto · TipCars · Vincario · Cebia · SMS · e-mail · AI
```

## 1. Domény a URL

| Co | URL | Kde se staví |
| --- | --- | --- |
| Prezentační web | `https://{BRAND.domain}` | Lovable (samostatné repo) |
| Aplikace | `https://app.{BRAND.domain}` | `apps/app`, Vercel |
| Plugin | `https://cdn.{BRAND.domain}/widget/v1/widget.js` | `apps/widget`, Vercel (statické soubory, cache 1 h, verze v cestě) |
| Veřejná stránka vozu (QR, bazary bez webu) | `https://app.{BRAND.domain}/v/{publicKey}/{vehicleId}` | `apps/app`, veřejná routa bez přihlášení, vykresluje detail z pluginu |
| API | `https://{SUPABASE_PROJECT}.supabase.co/functions/v1/…` | `supabase/functions` |

Do doby, než bude název a doména, platí hodnoty z `packages/brand/brand.ts`.

## 2. Odkazy z prezentačního webu do aplikace

| Akce na webu | Cíl | Parametry |
| --- | --- | --- |
| „Vyzkoušet zdarma“ | `app.{domain}/registrace` | `?plan=S|M|L`, všechny `utm_*` z adresy webu se předají dál |
| „Přihlásit se“ | `app.{domain}/prihlaseni` | – |
| „Prohlédnout demo“ | `app.{domain}/demo` | aplikace přihlásí sdíleného demo uživatele (jen čtení + reset každou noc) |

Aplikace uloží `utm_*` a `plan` do `companies.settings.signup` při `create_company`.

## 3. Registrace pilotů z webu

`POST /functions/v1/platform-signup`

```json
{
  "companyName": "Autobazar Novák s.r.o.",
  "ico": "12345678",
  "contactName": "Jan Novák",
  "email": "jan@novak.cz",
  "phone": "+420 777 123 456",
  "vehiclesInStock": 45,
  "region": "Plzeňský",
  "message": "Chceme zkusit pilot.",
  "wantsPilot": true,
  "consent": true,
  "utm": { "utm_source": "google" },
  "website": ""
}
```

- `website` je honeypot – musí být prázdný, jinak 200 bez uložení.
- Validace Zod, `consent` musí být `true`, IČO 8 číslic (nepovinné), e-mail povinný.
- Rate limit 5 požadavků / 10 min / IP.
- CORS: jen `https://{BRAND.domain}`, `https://www.{BRAND.domain}` a náhledové domény Lovable (`*.lovable.app`, `*.lovableproject.com`).
- Odpověď `201 {"ok": true}`; chyba `400 {"ok": false, "errors": {"email": "Neplatný e-mail"}}` (texty česky).
- Uloží do `platform_signups` a pošle e-mail na `BRAND.supportEmail`.

## 4. Veřejné API pluginu

Všechny požadavky nesou `key` = `companies.public_key`. Funkce `public-api` používá service role a vrací **jen** vozy firmy s `is_public = true` a stavem `advertised` nebo `reserved`, a jen bezpečné sloupce (nikdy nákupní cenu, náklady, marži, VIN celý – jen posledních 6 znaků, SPZ ne).

| Metoda a cesta | Účel | Cache |
| --- | --- | --- |
| `GET /public-api/vehicles?key=…&make=&model=&priceMax=&yearMin=&kmMax=&fuel=&transmission=&body=&sort=price_asc|price_desc|newest|km_asc&page=1&perPage=24` | výpis + facety (značky a modely s počty) | `s-maxage=60` |
| `GET /public-api/vehicles/{id}?key=…` | detail: fotky (3 velikosti), výbava po skupinách, prověrka (souhrn + datum + zdroj), časová osa km, kalkulace splátky, kontakty pobočky | `s-maxage=60` |
| `GET /public-api/company?key=…` | název, logo, pobočky, otevírací doba, nastavení pluginu (barvy, texty), F&I parametry pro kalkulačku | `s-maxage=300` |
| `POST /public-api/leads` | dotaz / prohlídka / zkušební jízda / zájem o financování; tělo `{key, vehicleId?, type: 'question'|'viewing'|'test_drive'|'finance', name, email?, phone?, message?, preferredTime?, finance?: {downPayment, termMonths}, consent: true, source: 'web'|'qr', website: ''}` | – |
| `POST /public-api/events` | měření `{key, vehicleId?, event, sessionId}` – bez osobních údajů, sendBeacon | – |

- CORS: `*` (plugin běží na libovolném webu), ale `POST /leads` s rate limitem 10 / 10 min / IP a honeypotem `website`.
- Demo firma má pevný `public_key = 'demo'` (nastaví seed) – používá ji prezentační web.

## 5. Vložení pluginu

```html
<script type="module" src="https://cdn.{BRAND.domain}/widget/v1/widget.js"></script>
<{BRAND.widgetTag} key="PUBLIC_KEY"></{BRAND.widgetTag}>
```

Volitelné atributy: `view="list|detail"`, `vehicle="{id}"`, `accent="#FF5A1F"`, `font="inherit"`, `per-page="12"`, `lang="cs"`. Plugin převezme písmo stránky (`font="inherit"`) a barvy z atributů nebo z `GET /company`. Události pro web bazaru: `CustomEvent('lead-submitted', {detail: {vehicleId}})`.

## 6. Sdílený vzhled

- Zdroj pravdy: `packages/brand/tokens.css` a `docs/design-system.md`.
- Prezentační web (Lovable) má hodnoty přepsané v promptu `docs/prompts/lovable-web.md`. Při změně tokenů pošli do Lovable krátký prompt „Aktualizuj tokeny na: …“.
- Název a doména: `packages/brand/brand.ts` ↔ sekce „Proměnné“ v promptu pro Lovable.

## 7. Ceník (sdílený obsah webu a aplikace)

| Tarif | Vozů na skladě | Uživatelů | Cena / měsíc bez DPH |
| --- | --- | --- | --- |
| S | do 20 | 2 | 990 Kč |
| M | do 60 | 5 | 1 990 Kč |
| L | do 150 | 15 | 3 990 Kč |
| Síť | nad 150 | neomezeně | od 5 990 Kč |

30 dní zdarma bez karty, roční platba = 2 měsíce zdarma, modul financování a pojištění v ceně. Zdroj pravdy: `packages/shared/src/pricing.ts` (aplikace) a stejná tabulka v promptu pro Lovable.

## 8. Externí služby (adaptéry)

| Oblast | Rozhraní (`_shared/providers/…`) | Mock | Skutečná implementace | Env |
| --- | --- | --- | --- | --- |
| VIN dekódování, odcizení, tržní ceny | `vin/` | vrací data z `fixtures/vin/*.json` podle VIN | Vincario | `VINCARIO_API_KEY`, `VINCARIO_SECRET` |
| Prověrka historie | `history/` | náhodně „bez nálezu“ / „stočené km“ podle posledního znaku VIN | Cebia | `CEBIA_*` (po podpisu smlouvy) |
| Inzerce Sauto | `portals/sauto` | ukládá payload do `listings`, vrací falešné ID a URL | XML-RPC import Sauto | heslo ve Vault |
| Inzerce TipCars | `portals/tipcars` | dtto | dealerský import TipCars | heslo ve Vault |
| AI texty a OCR VIN | `ai/` | šablonový text z dat vozu | Anthropic API | `ANTHROPIC_API_KEY`, `AI_MODEL` |
| SMS | `sms/` | zapíše do `outbound_messages` | česká SMS brána | `SMS_*` |
| E-mail | `email/` | zapíše do `outbound_messages` | Resend / Postmark (EU) | `EMAIL_*` |
| Firmy | `ares/` | fixture | ARES REST (veřejné) | – |
| Financování | `finance/` | e-mail partnerovi do `outbound_messages` | e-mail / API partnera | – |

Přepínač: `PROVIDER_<OBLAST>=mock|real`. Výchozí `mock`.
