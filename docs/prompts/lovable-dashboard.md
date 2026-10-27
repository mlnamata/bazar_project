# Aplikace (dashboard) v Lovable

Rozhraní aplikace pro bazary postavíme nejdřív v Lovable jako **klikací prototyp s mock daty** – rychle se ladí vzhled a jde ho hned ukazovat bazarům ve fázi 0. Potom ho Claude Code přenese do monorepa (`apps/app`) a napojí na Supabase podle fází 02–11.

Aby šel kód převzít bez přepisování, prompt drží stejný stack, tokeny, texty v jednom souboru a data za vrstvou hooků.

## Postup v Lovable

1. **Nový** projekt (ne ten s webem). Settings → Knowledge → vlož blok A.
2. První zpráva = blok B (kostra + Sklad + Karta vozu).
3. Pak bloky C1–C8 po jednom, po každém kontrola na desktopu, tabletu a mobilu.
4. Settings → GitHub → repo `mlnamata/bazar_app_ui`.
5. Supabase v Lovable **nepřipojuj** – data dodá Claude Code.

---

## A) Project Knowledge

```
CO TO JE
Webová aplikace (PWA) pro české autobazary: sklad vozů, výkup, příprava, inzerce na Sauto/TipCars/web, dotazy,
prodej se smlouvami a fakturami. Uživatelé: majitel bazaru, prodejce, výkupčí, účetní. Používají ji celý den na
počítači v kanceláři a na telefonu na ploše mezi auty. Je to pracovní nástroj: přehlednost, rychlost a hustota
informací mají přednost před efekty. Toto je klikací prototyp s mock daty; později se kód přenese do monorepa
a napojí na Supabase – proto drž pravidla níže doslova.

STACK A STRUKTURA (povinné)
React 18 + Vite + TypeScript strict + Tailwind + shadcn/ui (Radix) + React Router + TanStack Query +
React Hook Form + Zod + lucide-react + Recharts. Žádný Supabase, žádný jiný backend.
- src/i18n/cs.ts – VŠECHNY texty rozhraní (objekt podle obrazovek). V komponentách žádné české řetězce natvrdo.
- src/data/mock/*.ts – mock data; src/data/api.ts – async funkce (listVehicles, getVehicle, updateVehicle …)
  se zpožděním 200–400 ms nad mock daty v paměti; src/data/hooks.ts – TanStack Query hooky nad api.ts.
  Komponenty volají JEN hooky. Typy v src/data/types.ts podle datového modelu níže.
- src/config/brand.ts: name 'NÁZEV' (zobrazuj displayName 'Bazarník' – pracovní), widgetTag 'bazar-nabidka'.
- src/lib/format.ts: Kč „259 900 Kč“, km „128 400 km“, datum „27. 10. 2026“, Intl cs-CZ, tabular-nums.
- src/components/ui = shadcn; src/components/app = vlastní komponenty; src/pages = obrazovky.

DATOVÝ MODEL (zjednodušeně, názvy polí anglicky)
Vehicle: id, stockNo, status (buyout|preparation|ready|advertised|reserved|sold), vin, plate, make, model, variant,
body, fuel (petrol|diesel|lpg|hybrid|electric), transmission (manual|automatic), powerKw, year, mileageKm,
colorName, equipment[], purchasePrice, costs[] {category, description, amount}, targetPrice, minPrice, listPrice,
soldPrice, boughtAt, soldAt, photos[] (počet), verified (bool), checkFindings, mileageRecords[] {date, km, source},
listings[] {channel: sauto|tipcars|web, status: draft|queued|live|error|removed, error?, url?}, branch.
Odvozené: costsTotal, margin = (soldPrice ?? listPrice) − purchasePrice − costsTotal, marginPct, daysInStock.
Lead: id, vehicleId, source (web|qr|sauto|tipcars|phone|walk_in), status (new|contacted|viewing|offer|won|lost),
name, phone, email, message, assignedTo, createdAt, events[].
Customer, TestDrive, Sale, Invoice, Task (prep úkol), User (role owner|sales|buyer|accountant).

MOCK DATA
Firma „Autobazar Demo s.r.o.“, pobočka Plzeň. 25 vozů s realistickými českými daty (Škoda Octavia, Fabia,
Superb, Kodiaq, VW Golf, Passat, Tiguan, Hyundai i30, Kia Ceed, Toyota Corolla, Ford Focus, BMW 320d, Audi A4),
roky 2012–2022, 40–260 tis. km, ceny 120–650 tis. Kč; 5 výkup/příprava, 15 inzerováno, 2 rezervováno, 3 prodáno;
3 vozy nad 60 dní, 1 nad 90; jeden vůz se stočenými km (pokles na časové ose); 2 chyby publikace. 12 leadů,
4 uživatelé (Jan Novák – majitel, Petra Malá a Tomáš Král – prodejci, Eva Dvořáková – účetní).
Fotky: generované SVG siluety podle karoserie v barvě vozu (žádné cizí fotky).

DESIGN (stejné tokeny jako web)
Charakter: důvěryhodný pracovní nástroj + moderní lehké plochy + energie autosvěta.
CSS proměnné v HSL v index.css + Tailwind theme:
--background 220 20% 97% · --surface 0 0% 100% · --foreground 213 47% 11% · --muted 216 18% 94% ·
--muted-foreground 215 13% 41% · --border 216 20% 90% · --primary 213 63% 16% (#0F2742) ·
--accent 16 100% 56% (#FF5A1F, jen hlavní akce, aktivní stav, odznak; max 1–2× na obrazovce) ·
--success 145 80% 35% · --warning 39 91% 55% · --danger 359 76% 56% · --info 221 83% 53%.
Stavy vozu: buyout 262 60% 55%, preparation 39 91% 55%, ready 199 89% 48%, advertised 145 80% 35%,
reserved 16 100% 56%, sold 213 63% 16% – vždy štítek s textem, ne jen barva.
Tmavý režim (.dark): background 215 52% 8%, surface 214 45% 12%, foreground 213 33% 93%, border 215 37% 21%,
primary 213 70% 92% s primary-foreground 213 63% 16%.
Písmo Inter (UI, základ 14 px), Archivo condensed (font-stretch 85 %, 600–800) pro název vozu, ceny a KPI.
Zaoblení 10 px, karty bez těžkých stínů (1 px border + jemný stín), ikony lucide 1.75.
Zakázáno: gradienty, glassmorphism, ikony v barevných kruzích, emoji, ilustrace, prázdné „hero“ plochy v aplikaci.

ROZVRŽENÍ
Desktop: levý panel 248 px tmavě modrý (sbalitelný na ikony), položky: Přehled, Sklad, Výkup, Příprava, Leady,
Zákazníci, Prodej, Přehledy, Nastavení; dole firma a uživatel. Horní lišta: globální vyhledávání (VIN, SPZ,
jméno, telefon; Ctrl+K otevře command palette), přepínač pobočky, tmavý režim, avatar.
Mobil: spodní lišta Přehled · Sklad · + · Leady · Více; „+“ = sheet s volbou Výkup / Nový vůz.
Tabulky: řádek 44 px, sticky hlavička, čísla vpravo, první sloupec fotka 64×48 + název; na mobilu se mění
v karty. Dotykové cíle min 44 px. Hlavní akce obrazovky vpravo nahoře (desktop) / dole v dosahu palce (mobil).

TÓN
Česky, vykání v textech, tlačítka slovesem („Uložit vůz“, „Zveřejnit“), chyby říkají co se stalo a co dělat.
Prázdné stavy vždy s jednou akcí. Žádný vývojářský žargon.

VLASTNÍ KOMPONENTY (src/components/app)
VehicleStatusBadge, PriceTag (cena v Archivo + volitelně splátka pod ní), MarginCell (Kč a %, barva podle
znaménka), DaysInStock (od 60 warning, od 90 danger), VerifiedBadge, ChannelStatus (Sauto/TipCars/Web:
online/čeká/chyba + text chyby), VehiclePhoto (SVG silueta), DataTable (TanStack Table), EmptyState,
PageHeader, KpiCard, MileageTimeline (Recharts, pokles km červeně s popisem), Wizard (kroky, mobil),
SignaturePad (canvas), DocumentPreview (A4 náhled).
```

---

## B) První prompt – kostra, Sklad, Karta vozu

```
Postav podle Project Knowledge kostru aplikace a dvě hlavní obrazovky. Ostatní položky navigace zatím vedou
na EmptyState s textem „Připravujeme“.

1) Kostra: rozvržení desktop/mobil, navigace, horní lišta, command palette (Ctrl+K: hledání vozů podle VIN/SPZ/
modelu a příkazy „Nový výkup“, „Nový vůz“), přepínač tmavého režimu, toasty (sonner), ErrorBoundary.
Přihlášení zatím ne – uživatel je Jan Novák (majitel); v menu avatara přepínač role (majitel/prodejce/výkupčí/
účetní), navigace skrývá, co role nesmí (výkupčí nevidí Prodej a Přehledy, účetní nevidí Výkup).

2) /sklad – Sklad vozů:
- nahoře souhrn v 4 KpiCard: vozů na skladě, hodnota skladu (nákupní ceny), průměrně dní na skladě, vozů nad 60 dní,
- filtry: stav (multi), značka, palivo, rok od–do, cena od–do, dny na skladě (>30/>60/>90), „bez fotek“;
  fulltext; filtry v URL; přepínač Tabulka / Dlaždice,
- tabulka: fotka+název (make model variant, pod tím rok · km · palivo), stav, cena, marže, dny, kanály (3 malé
  ikonky se stavem), akce (⋯: Otevřít, Zveřejnit, Zlevnit, Změnit stav),
- hromadný výběr → lišta dole: Zveřejnit, Stáhnout, Zlevnit o %, Změnit stav,
- dlaždice: velká silueta, název v Archivo, PriceTag, štítky stav/prověřeno/dny,
- tlačítka „Výkup“ (accent) a „Nový vůz“.

3) /vuz/:id – Karta vozu: hlavička (silueta, název v Archivo, stav s rozbalovací změnou a poznámkou, PriceTag,
další akce podle stavu – např. „Zveřejnit“). Záložky:
Údaje a výbava (formulář, výbava jako checkboxy ve skupinách) · Fotky (mřížka 16 slotů podle šablony záběrů,
chybějící čárkovaně) · Ekonomika (nákupní cena, tabulka nákladů s přidáním, cílová/minimální/inzerovaná cena,
živý výpočet marže, varování pod minimem) · Prověrka a km (souhrn prověrky, MileageTimeline) · Inzerce (ChannelStatus
pro 3 kanály, AI text inzerátu – viz C4) · Dokumenty (seznam, nahrát) · Historie (časová osa změn).

Ověř 375 / 768 / 1440 px a tmavý režim. Žádný horizontální scroll na mobilu.
```

---

## C) Navazující prompty

**C1 – Přehled dne (`/`)**
```
Obrazovka Přehled dne: pozdrav s datem, pak sloupce karet seřazené podle naléhavosti, každá položka vede k akci:
Nové dotazy (nepřiřazené zvýrazněné, tlačítko Přiřadit) · Dnes: prohlídky a zkušební jízdy (časová osa po hodinách) ·
Vozy dlouho na skladě (60/90 dní, návrh „Zlevnit o 3 %“) · Chyby publikace (text chyby + Opravit) ·
Příprava po termínu · Vozy bez fotek / textu / ceny · Karta „Začínáme“ pro novou firmu (checklist 6 kroků s %).
Prodejce vidí jen svoje položky (přepínač role z kostry).
```

**C2 – Výkup (`/vykup/novy`, mobil first)**
```
Průvodce výkupem (Wizard), 7 kroků s ukazatelem nahoře a hlavní akcí dole:
1 Vůz: „Vyfotit VIN“ (simuluj: po 1,5 s doplní VIN) nebo ruční zadání, SPZ, foto tachometru → km ·
2 Údaje: předvyplněné z „dekódování“, kontrola odcizení (zelený výsledek) ·
3 Prověrka: tlačítko „Prověřit historii (149 Kč)“ → výsledek: nálezy + MileageTimeline ·
4 Stav: checklist ve skupinách (Karoserie, Interiér, Motor a převodovka, Podvozek a brzdy, Pneu – dezén 4× mm,
  Doklady a klíče), každá položka OK / Pozor / Závada + poznámka + foto ·
5 Ocenění: srovnatelné vozy (medián, rozptyl, 6 nabídek), odhad přípravy ze závad, požadovaná marže 12 % →
  doporučená výkupní cena jako vysvětlený výpočet, pole Dohodnutá cena ·
6 Prodávající: osoba/firma, vyhledání, IČO → doplnění firmy ·
7 Smlouva: DocumentPreview výkupní smlouvy, SignaturePad prodávajícího a výkupčího, „Dokončit výkup“ → vůz
  ve stavu Výkup, toast, přesměrování na kartu vozu.
Ukazatel „Uloženo v telefonu“ u každého kroku. Na desktopu průvodce v užším sloupci 640 px uprostřed.
```

**C3 – Příprava a focení**
```
/priprava: kanban Čeká · Probíhá · Hotovo (karty úkolů s vozem, dodavatelem, cenou, termínem), přepínač na seznam
podle vozů, filtr. Dokončení úkolu se zeptá na skutečnou cenu a přidá náklad k vozu.
V kartě vozu záložka Fotky: režim „Nafotit podle šablony“ (mobil, fullscreen, obrys auta přes náhled kamery –
simuluj placeholderem, postup 1/16, Přeskočit), přetahování pořadí, nástroj „Rozmazat SPZ“ (obdélník na fotce).
Předprodejní checklist s pravidlem „bez dokončení nejde zveřejnit“ (tlačítko Zveřejnit zablokované s vysvětlením).
```

**C4 – Inzerce a AI text**
```
Záložka Inzerce v kartě vozu: panel „Text inzerátu“ – volba tónu (Věcný / Prodejní / Prémiový), Vygenerovat
(simuluj 1,5 s), editor textu; po najetí na větu tooltip se zdrojem („Z výbavy: vyhřívaná sedadla“, „Z prověrky:
bez nálezu“); věta bez zdroje se podtrhne červeně; tlačítko „Schválit text“. Pod tím kanály Sauto, TipCars, Web:
zaškrtnout → „Zveřejnit na vybraných“ → stavy odesílám → online (s odkazem) nebo chyba („Sauto odmítlo inzerát:
chybí počet dveří.“ + Opravit → skočí na pole). Na Skladu hromadné Zveřejnit / Stáhnout používá stejné stavy.
```

**C5 – Leady, zkušební jízda, zákazníci**
```
/leady: kanban i tabulka (Nový · Kontaktován · Prohlídka · Nabídka · Vyhráno · Ztraceno), filtr prodejce/vůz/zdroj.
Detail leadu v pravém panelu (sheet): kontakt, vůz s cenou, časová osa událostí, rychlé akce Zavolat, SMS a e-mail
ze šablon, Naplánovat prohlídku/jízdu, Ztraceno s důvodem. Zkušební jízda (mobil): termín, foto řidičáku, km
a palivo na začátku/konci, souhlas s podpisem. /zakaznici: seznam a detail (koupené a prodané vozy, leady, dokumenty).
```

**C6 – Prodej a doklady**
```
/prodej/:id – průvodce prodejem: zákazník → cena a režim DPH (výchozí zvláštní režim) → protiúčet (vybrat vůz
z výkupu, odečíst) → záloha a platba → odpovědnost za vady (24 nebo dohodou 12 měsíců – vysvětlení u volby)
→ známé vady (předvyplněné z checklistů) → náhled kupní smlouvy → podpisy → předávací protokol → faktura
(DocumentPreview, text „Zvláštní režim – použité zboží“, QR platba) → checklist přepisu. Dokončení = vůz Prodáno,
inzeráty stažené, toast. Seznam faktur s filtrem a „Označit jako zaplacené“, export (tlačítko, simulace).
```

**C7 – Přehledy**
```
/prehledy (majitel, účetní): období (měsíc/kvartál/rok/vlastní), KPI, grafy Recharts v barvách tokenů:
tržby a marže po měsících (sloupce), rozložení marže na voze, dny na skladě po vozech, prodeje po prodejcích,
výkon webu (zobrazení → dotazy po vozech, konverze), seznam „hodně zobrazení, žádný dotaz“. Export CSV (simulace).
Grafy přístupné (popisky, tabulka dat pod grafem rozbalitelně).
```

**C8 – Nastavení**
```
/nastaveni: Firma (údaje, logo, pobočky a otevírací doba) · Uživatelé (seznam, pozvat s rolí, změna role) ·
Portály (Sauto, TipCars: přihlášení, Ověřit připojení → stav) · Web a plugin (živý náhled pluginu s 6 vozy,
barva akcentu, zaoblení, kód k vložení s Kopírovat, tisk QR štítků – náhled A4) · Financování (partner, registrace
ČNB do, výchozí akontace a doba, zapnout zobrazení splátky) · Dokumenty (šablony, náhled) · Tarif (aktuální tarif,
vozy vůči limitu, změnit tarif) · Export dat.
```

---

## Po dokončení

Pošli mi odkaz nebo screenshoty – udělám kritiku stejně jako u webu. Až bude UI hotové, Claude Code ho převezme z repa `bazar_app_ui` do `apps/app` a fáze 03–11 se změní z „postav UI“ na „napoj UI na data a dotáhni logiku“.
