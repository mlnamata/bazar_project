# Prezentační web – opravy, aby nevypadal jako AI

Posílej do Lovable **po jednom** v tomto pořadí a po každém zkontroluj náhled na mobilu i desktopu. Kroky 1–3 jsou nutné opravy, 4–9 změní vzhled z „šablony“ na produkt pro autobazary.

---

## 1. Funkční nedostatky

```
Oprav tyto chyby, nic jiného neměň:
1) Sekce #pilot nemá formulář. Přidej ho přesně podle Project Knowledge (pole companyName, ico, contactName, email,
   phone, vehiclesInStock, region – select 14 krajů, message, wantsPilot, consent, honeypot website, utm) včetně stavů
   odesílání, úspěchu, chyb u polí a chyby sítě. Dokud není VITE_SIGNUP_URL, ulož odeslání do console.info a ukaž
   poděkování (označ v kódu TODO).
2) og:image míří na neexistující doménu. Vygeneruj public/og.png 1200×630 (tmavě modrá, textové logo, nadpis hero)
   a nastav og:image i twitter:image na relativní /og.png. Přidej favicon (oranžový čtverec 6×6 v tmavě modrém
   zaobleném čtverci) jako SVG + PNG 32 a apple-touch-icon 180.
3) Odstraň z patičky odkaz/odznak Lovable.
4) Odkazy do aplikace (app.nazev.cz) zatím nefungují. Dokud brand.appLive === false, všechna tlačítka
   „Vyzkoušet zdarma / 30 dní zdarma“ a „Přihlásit se“ veď na #pilot a „Prohlédnout demo“ na #demo.
   Přidej do src/config/brand.ts appLive: false.
```

## 2. Název na webu

```
Placeholder „NÁZEV“ nesmí být vidět. Do brand.ts přidej displayName: 'Bazarník' (pracovní, změníme)
a všude na webu zobrazuj displayName. Nadpis „S NÁZEV“ změň na „S {displayName}“.
```

> Místo „Bazarník“ dej jakýkoli pracovní název, který chceš ukazovat pilotům.

## 3. Jedna hlavní akce

```
Web má teď 6× „Vyzkoušet zdarma“ a 3× demo – rozmělňuje to rozhodnutí. Dokud appLive === false:
- hlavní akce všude = „Přihlásit bazar do pilotu“ (accent) → #pilot,
- vedlejší akce = „Ukázat, jak to vypadá“ (textový odkaz se šipkou) → #ukazka,
- v hlavičce jen jedno tlačítko „Do pilotu“, „Přihlásit se“ skryj,
- tlačítka v ceníku: „Chci tarif S/M/L do pilotu“ → #pilot s předvyplněným tarifem v poli message.
```

## 4. Hero = produkt, ne plakát

```
Přestavěj hero:
- Rozvržení asymetrické: vlevo text (zarovnaný vlevo, max 560 px), vpravo větší náhled aplikace, který přesahuje
  pravý okraj kontejneru a dolní hranu hero (bleed). Žádné centrování textu.
- Nadpis zůstává. Pod něj místo odstavce tři krátké řádky s ikonou check:
  „Vůz zadáte jednou při výkupu“ · „Sauto, TipCars a váš web jedním klikem“ · „Smlouva a faktura bez přepisování“.
- Náhled aplikace postav z komponent jako skutečnou obrazovku „Sklad vozů“: levý tmavě modrý panel navigace
  (ikony + popisky Přehled, Sklad, Výkup, Leady), tabulka 6 vozů (fotka = barevná silueta auta v SVG, značka model,
  rok, km, cena, marže, dny na skladě, ikonky kanálů), u jednoho vozu rozbalený řádek se stavem publikace
  Sauto/TipCars/Web. Česká realistická data (Škoda Octavia Combi 2019 128 400 km 329 900 Kč, Fabia, Superb,
  VW Golf, Hyundai i30, Kia Ceed). Čísla tabular-nums. Žádné rozmazání, žádné glow, žádná perspektiva/3D.
- Odstraň plovoucí kartu s dotazem z hero (přesune se do sekce Leady).
```

## 5. Podpisový prvek: cenovka za sklem

```
Přidej jeden výrazný, oborově autentický prvek a používej ho střídmě (hero, ceník, pilot):
„cenovka za sklem“ – bílý obdélník 160×110 px s jemným stínem a 2 px horním pruhem accent, uvnitř velká cena
v Archivo 800 condensed, pod ní drobně rok · km · palivo a vpravo dole malý QR čtvereček (SVG vzor, ne skutečný QR).
Lehce natočená o −3°. V hero leží přes roh náhledu aplikace. V ceníku nahradí karty tarifů: každý tarif je
taková cenovka (S, M, L, Síť) v řadě, M bez natočení a o 8 px výš. Nepoužívej ji nikde jinde.
```

## 6. Funkce: tři pracovní scény místo devíti stejných karet

```
Sekci „Všechno, co bazar potřebuje“ s 9 stejnými kartami nahraď třemi střídavými scénami (text vlevo/vpravo,
vizuál z komponent na druhé straně, každá jiná kompozice):
1) „Výkup na ploše“ – vizuál: telefon (rámeček 300×620, zaoblení 36) s krokem průvodce: VIN z fotky,
   výsledek prověrky „Bez nálezu · 6 záznamů km“ a mini graf km (stoupající čára, body podle zdroje).
   Text: odcizení, historie km, checklist stavu, doporučená výkupní cena, podpis prstem. Funguje i bez signálu.
2) „Jedno zadání, tři inzeráty“ – vizuál: karta vozu a vedle tři řádky kanálů se stavy (online/odesílám/chyba
   s českou hláškou „Sauto: chybí počet dveří“). Text: AI popis jen z ověřených údajů, změna ceny všude, prodaný
   vůz zmizí sám.
3) „Prodej bez papírů“ – vizuál: náhled kupní smlouvy (A4 v měřítku, šedé řádky textu, zvýrazněná pole
   vyplněná z karty vozu) a faktura s textem „Zvláštní režim – použité zboží“. Text: zkušební jízda, smlouva,
   protokol, faktura, export do Pohody.
Pod scénami jen jednoduchý dvousloupcový seznam (bez karet a ikon v bublinách) zbylých funkcí:
Sklad a marže · Plugin na váš web · Dotazy u správného vozu a prodejce · Splátky u každého vozu ·
QR štítky na vozy · Přehledy a dny na skladě.
Smaž sekci „Jak to funguje“ (4 kroky) – scény ji nahrazují. Sekce „Znáte to?“ zkrať na jeden řádek
„Dnes“ vs „S {displayName}“ jako tabulka o 4 řádcích, bez ikon a bez barevných pozadí.
```

## 7. Ukázka a financování

```
- Sekce #demo přejmenuj na #ukazka „Takhle vypadá nabídka na webu bazaru“. Dokud plugin z CDN neběží, postav
  statickou interaktivní ukázku přímo v projektu: mřížka 6 karet vozů s filtrem značky (funguje lokálně),
  klik otevře detail v panelu (galerie z SVG siluet, parametry, splátka, formulář dotazu – jen ukázka, nic
  neodesílá, napiš „Ukázka – formulář na vašem webu pošle dotaz do aplikace“). Kód k vložení nech pod tím.
- Sekci „Splátka u každého vozu“ spoj do ukázky: v detailu vozu je posuvník akontace a doby a splátka
  s drobným reprezentativním příkladem. Samostatnou sekci smaž.
```

## 8. Důvěra: kdo za tím stojí

```
Před FAQ přidej sekci „Kdo za tím stojí“: vlevo místo pro fotku (šedý obdélník 4:5 s textem „fotka“ – doplním
skutečnou), vpravo krátký text v první osobě:
„Jsem [JMÉNO] a stavím {displayName} v [REGION]. Sedím s bazary u stolu, dívám se, kde ztrácí čas, a podle toho
systém upravuju. Do pilotu beru prvních pár bazarů, se kterými to chci dotáhnout do konce.“
Pod tím telefon a e-mail jako odkazy (tel:, mailto:) a tlačítko „Domluvit ukázku u vás na place“ → #pilot.
Žádné reference, loga zákazníků ani hodnocení.
```

> Text si uprav podle sebe – osobní a konkrétní věta tady udělá víc než celý zbytek webu.

## 9. Typografie, rytmus a detaily

```
Projdi celý web a sjednoť:
- Nadpisy H2 zarovnané vlevo, Archivo 700 condensed, 40/44 px desktop, 30/34 mobil; žádné centrované nadpisy
  kromě závěrečné výzvy. Nad každým H2 malý štítek (eyebrow) jen tam, kde nese informaci, jinak žádný.
- Rytmus sekcí: 120 px desktop / 72 px mobil, ne všude stejné pozadí – střídej background a surface,
  tmavě modrá jen hero, pilot a patička.
- Zakaž: gradienty, glassmorphism, ikony v barevných kruzích, emoji, stíny větší než shadow-pop, text-gradient,
  animované počítadla čísel, „sparkles“.
- Pohyb: jen fade+posun 8 px při prvním zobrazení sekce (200 ms, ease-out), respektuj prefers-reduced-motion.
- Odstavce max 65 znaků, text 17/28 px.
- Diagonální řez nech jen u hero a pilotu, jinde rovné hrany.
- Ověř mobil 375 px: hero akce viditelná bez scrollu, náhled aplikace zmenšený a oříznutý zprava, žádný
  horizontální scroll.
```

---

## Po úpravách

Pošli mi screenshoty (desktop 1440 a mobil 375) nebo odkaz po publikaci – udělám druhé kolo kontroly a doladění.
