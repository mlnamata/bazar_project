# Prezentační web v Lovable

Web pro získání prvních bazarů: vysvětlí produkt, ukáže živé demo pluginu, ceník a sbírá přihlášky do pilotního programu. Je napojený na aplikaci jen přes odkazy a jeden formulář (viz `docs/integration-contract.md` sekce 2, 3, 5 a 7) – **v Lovable nepřipojuj Supabase**.

## Postup v Lovable

1. Nový projekt → vlož **Project Knowledge** (Settings → Knowledge) – blok A níže.
2. První zpráva v chatu = **hlavní prompt** – blok B.
3. Postupně doladit **navazujícími prompty** – blok C (po jednom, vždy zkontrolovat náhled).
4. Settings → GitHub → Connect → vytvoř repo `mlnamata/bazar_web` (Lovable si ho založí sám a synchronizuje oběma směry).
5. Až poběží fáze 11, nastav v Lovable env `VITE_SIGNUP_URL` na produkční adresu funkce.

---

## A) Project Knowledge (vložit do Settings → Knowledge)

```
PRODUKT
SaaS pro české autobazary. Vůz se zadá jednou při výkupu a odtud jde do přípravy, na portály Sauto a TipCars,
na web bazaru (plugin) i do kupní smlouvy a faktury. Funguje i v mobilu. Cílovka: majitelé malých a středních
autobazarů (5–150 vozů) v ČR. Tento web je jen prezentační; aplikace běží jinde.

NÁZEV A KONFIGURACE
Název zatím není. Všechny hodnoty drž v jediném souboru src/config/brand.ts a nikde jinde je nepiš natvrdo:
  name: 'NÁZEV'
  legalName: 'NÁZEV s.r.o.'
  domain: 'nazev.cz'
  appUrl: 'https://app.nazev.cz'
  widgetUrl: 'https://cdn.nazev.cz/widget/v1/widget.js'
  widgetTag: 'bazar-nabidka'
  supportEmail: 'podpora@nazev.cz'
  supportPhone: '+420 000 000 000'
  tagline: 'Vůz zadáte jednou. Prodá se všude.'
Logo zatím není: textové logo = name v písmu Archivo, font-weight 800, font-stretch 85 %, za ním malý
oranžový čtverec 6×6 px se zaoblením 1 px.

DESIGN (stejné tokeny jako aplikace – neměnit bez pokynu)
Charakter: důvěryhodný pracovní nástroj (tmavě modrá) + moderní lehké plochy (světlé, zaoblené, vzdušné)
+ energie autosvěta (signální oranžová jako jediný akcent, kondenzované písmo pro nadpisy a čísla,
diagonální řez sekcí v hero a v závěrečné výzvě).
Barvy (CSS proměnné v HSL v index.css, Tailwind theme z nich):
  --primary 213 63% 16% (#0F2742)   tmavě modrá: nadpisy, tmavé sekce, sekundární tlačítka
  --accent 16 100% 56% (#FF5A1F)    oranžová: JEN hlavní CTA, zvýraznění ceny, aktivní stav; max 2× na obrazovce
  --background 220 20% 97% (#F6F7F9), --surface 0 0% 100%, --foreground 213 47% 11% (#0F1C2B)
  --muted-foreground 215 13% 41% (#5B6676), --border 216 20% 90% (#E1E6ED)
  --success 145 80% 35% (#12A150), --warning 39 91% 55%, --danger 359 76% 56%
Písmo: Inter 400–700 pro text (základ 17 px, řádkování 1.6), Archivo (wdth 75–100, 600–800,
font-stretch 85 %) pro nadpisy a velká čísla. Google Fonts, display=swap.
Zaoblení 10 px (karty), 16 px (velké panely), tlačítka 10 px. Stíny jemné. Ikony lucide-react, stroke 1.75.
Žádné gradienty přes celé plochy, žádné emoji, žádné stockové fotky lidí. Ilustrace = stylizované UI
aplikace stavěné z HTML/Tailwind komponent (karty vozů, štítky stavů, tabulka skladu), ne obrázky.

TÓN TEXTŮ
Česky, vykání, krátké věty, konkrétní přínosy. Mluví jako zkušený kolega z oboru, ne jako reklama.
Žádné superlativy bez důkazu („nejlepší“, „revoluční“), žádné vymyšlené statistiky, žádné
vymyšlené reference, recenze, loga zákazníků ani citace – dokud nejsou skuteční piloti, sekce referencí
neexistuje. Ceny „bez DPH“. Formát čísel: 1 990 Kč, 128 400 km.

TECHNIKA
React + Vite + TypeScript + Tailwind + shadcn/ui (výchozí Lovable). NEPŘIPOJOVAT Supabase ani jiný backend.
Proměnné prostředí: VITE_SIGNUP_URL (POST registrace pilotů), VITE_APP_URL (fallback brand.appUrl).
Všechny odkazy do aplikace přenášejí utm_* parametry z aktuální adresy (helper withUtm(url)).
Žádné analytické ani reklamní cookies → žádná cookie lišta. Výkon: Lighthouse mobile ≥ 90 ve všech kategoriích,
obrázky lazy, žádné těžké knihovny animací (jen CSS a Intersection Observer). Přístupnost: kontrast 4.5:1,
viditelný focus, ovládání klávesnicí, alt texty, jeden h1 na stránku. SEO: title, description, Open Graph,
JSON-LD SoftwareApplication s nabídkami z ceníku, sitemap.xml, robots.txt, kanonické URL.
```

---

## B) Hlavní prompt (první zpráva)

```
Postav prezentační web podle Project Knowledge. Jedna hlavní stránka + stránky /obchodni-podminky,
/ochrana-osobnich-udaju a 404. Všechny texty níže použij doslova (můžeš je jen typograficky upravit).

1) HLAVIČKA (sticky, při scrollu bílé pozadí se stínem)
Textové logo. Navigace: Funkce · Jak to funguje · Demo · Ceník · Pilotní program · Otázky.
Vpravo: odkaz „Přihlásit se“ (→ {appUrl}/prihlaseni) a tlačítko accent „Vyzkoušet zdarma“ (→ {appUrl}/registrace).
Na mobilu hamburger s celoobrazovkovým menu.

2) HERO (tmavě modré pozadí, spodní hrana diagonálně seříznutá)
Nadpis H1 (Archivo, 56–64 px desktop, 40 px mobil, bílá): „Vůz zadáte jednou. Prodá se všude.“
Podnadpis (bílá 80 %): „Systém pro autobazary: výkup v mobilu, prověrka historie, inzerce na Sauto, TipCars
a vašem webu, smlouvy i faktury. Všechno v jedné aplikaci.“
Tlačítka: accent „Vyzkoušet 30 dní zdarma“ (→ {appUrl}/registrace), obrysové bílé „Prohlédnout demo“ (→ {appUrl}/demo).
Pod tlačítky drobně: „Bez karty. Převod skladu z CSV za pár minut.“
Vpravo vizuál z komponent: karta vozu „Škoda Octavia Combi 2.0 TDI Style, 2019, 128 400 km“,
cena „329 900 Kč“ (Archivo, oranžová), odznak „Prověřeno“ (zelený), pod ní tři řádky kanálů
„Sauto – online“, „TipCars – online“, „Váš web – online“ se zelenými tečkami, a malá plovoucí karta
„Nový dotaz: Jan N. – zkušební jízda v sobotu“. Jemná animace: stavy kanálů postupně naskočí z „Odesílám…“ na „online“.

3) PRUH FAKTŮ (4 sloupce, na mobilu 2×2, Archivo čísla)
„1× zadat“ – vůz zadáte jednou, propíše se všude
„3 kanály“ – Sauto, TipCars a váš web jedním klikem
„16 záběrů“ – focení podle šablony přímo v mobilu
„od 990 Kč“ – měsíčně bez DPH, 30 dní zdarma

4) PROBLÉM (sekce „Znáte to?“, dvousloupcově: vlevo dnes, vpravo s námi)
Dnes:
– Stejné auto přepisujete na Sauto, TipCars i na web. A po prodeji ho zase ručně mažete.
– Prověrka je v jednom systému, smlouva ve Wordu, marže v Excelu.
– Nevíte přesně, kolik vás který vůz stál a jak dlouho už stojí.
– Dotazy chodí na telefon, e-mail i Messenger a některé se ztratí.
S {name}:
– Vůz založíte při výkupu, údaje se doplní podle VIN.
– Cena, fotky a text se změní všude najednou. Prodaný vůz zmizí ze všech portálů sám.
– Marže a dny na skladě vidíte u každého vozu.
– Každý dotaz má svůj vůz a svého prodejce.

5) JAK TO FUNGUJE (id „jak-to-funguje“, 4 kroky na časové ose, na mobilu svisle)
1. Výkup v mobilu – Vyfoťte VIN, systém doplní údaje vozu. Prověřte historii a stav km, projděte checklist,
   podívejte se na doporučenou výkupní cenu a nechte prodávajícího podepsat smlouvu prstem.
2. Příprava a fotky – Úkoly přípravy s cenou se samy připočtou k nákladům. Fotíte podle šablony 16 záběrů,
   SPZ rozmažete jedním tahem.
3. Inzerce jedním klikem – Text inzerátu připraví AI jen z ověřených údajů o voze, vy ho schválíte.
   Zaškrtnete portály a vůz je na Sauto, TipCars i na vašem webu.
4. Prodej bez papírování – Zkušební jízda, kupní smlouva, předávací protokol a faktura ve zvláštním režimu
   DPH se vyplní z karty vozu. Vůz se po prodeji stáhne ze všech portálů.

6) FUNKCE (id „funkce“, mřížka 3×3 karet s ikonou, nadpisem a 1–2 větami)
Sklad a marže – Přehled všech vozů s náklady, marží a dny na skladě. Vozy, které stojí příliš dlouho, uvidíte hned.
Výkup v mobilu – Průvodce krok za krokem, funguje i bez signálu a odešle se po připojení.
Prověrka a kilometry – Historie vozu a časová osa km na jednom místě. Podezřelý pokles km systém označí.
AI texty inzerátů – Popis, titulek a klíčová slova z výbavy a stavu vozu. Jen pravdivá tvrzení, vždy je schválíte.
Publikace na portály – Sauto, TipCars a váš web jedním klikem, včetně srozumitelných chyb, když portál něco odmítne.
Plugin na váš web – Nabídka vozů s filtry a formulářem na vašem webu. Vložíte jedním řádkem kódu.
Dotazy a prodejci – Všechny dotazy z webu, QR kódů i telefonu u správného vozu a prodejce.
Smlouvy a faktury – Výkupní a kupní smlouva, protokoly, faktura ve zvláštním režimu DPH a export do účetnictví.
Splátky u každého vozu – Kalkulačka splátky v inzerátu i na webu a poptávka financování partnerovi.

7) ŽIVÉ DEMO (id „demo“, světle šedé pozadí)
Nadpis: „Takhle vypadá nabídka na webu bazaru“
Text: „Ukázkový bazar s 25 vozy. Stejný plugin vložíte na svůj web jedním řádkem – funguje s WordPressem,
Wixem, Webnode i webem na míru.“
Vlož plugin: načti skript {widgetUrl} jako type="module" (dynamicky v useEffect, jen jednou) a vykresli
element <{widgetTag} key="demo"></{widgetTag}> v rámečku s okrajem a zaoblením 16 px.
Pokud se skript nenačte do 5 s, zobraz místo něj kartu „Demo nabídky se právě připravuje“ s tlačítkem
„Prohlédnout demo aplikace“ (→ {appUrl}/demo).
Pod rámečkem blok s kódem k vložení (monospace, tlačítko Kopírovat):
<script type="module" src="{widgetUrl}"></script>
<{widgetTag} key="VÁŠ-KLÍČ"></{widgetTag}>

8) FINANCOVÁNÍ (dvousloupcově, vlevo text, vpravo vizuál kalkulačky z komponent)
Nadpis: „Splátka u každého vozu“
Text: „Zákazník vidí měsíční splátku přímo v inzerátu a na vašem webu a může poslat poptávku financování.
Vy ji máte u vozu a prodejce ví, co nabídnout. Modul je v ceně všech tarifů.“
Drobně: „Financování poskytují partneři. Bazar musí být registrovaný zprostředkovatel; s nastavením pomůžeme.“
Vizuál: posuvníky „Akontace 20 %“ a „Doba 60 měsíců“, výsledek „5 290 Kč / měsíc“ a pod tím šedě
„Ilustrativní výpočet“.

9) CENÍK (id „cenik“)
Přepínač Měsíčně / Ročně (ročně = 10× měsíční cena, štítek „2 měsíce zdarma“).
4 karty, prostřední M zvýrazněná (okraj accent, štítek „Nejčastější volba“):
S – do 20 vozů, 2 uživatelé – 990 Kč – Sklad a výkup, prověrky, dokumenty, Sauto + TipCars, plugin na web, AI texty
M – do 60 vozů, 5 uživatelů – 1 990 Kč – Vše ze S + dotazy a prodejci, přehledy, QR štítky
L – do 150 vozů, 15 uživatelů – 3 990 Kč – Vše z M + více poboček, vlastní doména nabídky, API
Síť – nad 150 vozů, neomezeně uživatelů – od 5 990 Kč – Vše + individuální napojení, prioritní podpora
Ceny měsíčně bez DPH. Tlačítka „Vyzkoušet zdarma“ → {appUrl}/registrace?plan=S|M|L, u Sítě „Domluvit schůzku“ → kotva #pilot.
Pod kartami: „30 dní zdarma bez karty. Prověrky historie se platí zvlášť podle počtu. Financování a pojištění v ceně.“

10) PILOTNÍ PROGRAM (id „pilot“, tmavě modrá sekce s diagonálním řezem nahoře)
Nadpis: „Hledáme první bazary do pilotního programu“
Text: „Tři měsíce zdarma, pak polovina ceny na celý první rok. Za to od vás chceme týdenní zpětnou vazbu
a možnost systém doladit podle vaší praxe.“
Formulář (shadcn Form + zod, bílá karta):
– Název bazaru* (companyName), IČO (ico, 8 číslic), Jméno a příjmení* (contactName), E-mail* (email),
  Telefon (phone), Kolik máte vozů na skladě (vehiclesInStock, číslo), Kraj (region, select se 14 kraji ČR),
  Zpráva (message), checkbox „Chci do pilotního programu“ (wantsPilot, výchozí zaškrtnuto),
  checkbox* „Souhlasím se zpracováním osobních údajů“ s odkazem na /ochrana-osobnich-udaju (consent),
  skryté pole website (honeypot, vizuálně skryté, tabIndex -1, autocomplete off),
  utm = objekt utm_* z URL.
– Odeslání: POST JSON na import.meta.env.VITE_SIGNUP_URL přesně v tomto tvaru:
  {companyName, ico, contactName, email, phone, vehiclesInStock, region, message, wantsPilot, consent, utm, website}
  201 → poděkování „Děkujeme, ozveme se do dvou pracovních dnů.“; 400 → chyby z odpovědi { errors: {pole: text} }
  zobraz u polí; síťová chyba nebo chybějící VITE_SIGNUP_URL → „Odeslání se nepovedlo. Napište nám na {supportEmail}.“
– Tlačítko accent „Přihlásit bazar do pilotu“, během odesílání disabled se spinnerem.

11) ČASTÉ OTÁZKY (id „otazky“, accordion)
Musím kvůli tomu měnit web? – Ne. Plugin s nabídkou vložíte do stávajícího webu jedním řádkem kódu. Pokud web nemáte, dostanete hotovou stránku s nabídkou.
Jak dlouho trvá převod skladu? – Vozy nahrajete z CSV nebo exportu, který dnes používáte, včetně fotek. U běžného bazaru je to otázka minut.
Funguje to se Sauto a TipCars? – Ano, vůz zveřejníte, změníte i stáhnete přímo z aplikace. Další portály postupně přidáváme.
Kde jsou moje data? – Na serverech v EU. Každý bazar vidí jen svoje data, oddělení hlídá databáze, ne jen aplikace.
Potřebuji vlastní smlouvu na prověrky? – Ne, prověrky historie zaplatíte přímo v aplikaci podle počtu.
Funguje to v mobilu? – Ano. Výkup, focení i zkušební jízdu uděláte v telefonu, i když na ploše zrovna není signál.
Můžu kdykoli skončit? – Ano, tarif platíte měsíčně a svoje data si kdykoli stáhnete.
Kdo nám pomůže s nastavením? – My. Při spuštění vám pomůžeme s převodem skladu, napojením portálů i pluginem.

12) ZÁVĚREČNÁ VÝZVA (accent oranžový pruh s diagonálním řezem, bílý text)
„Zkuste to na svých autech.“ + tlačítko bílé „Vyzkoušet 30 dní zdarma“ + odkaz „nebo si prohlédněte demo“.

13) PATIČKA (tmavě modrá)
Textové logo + tagline. Sloupce: Produkt (Funkce, Ceník, Demo, Přihlásit se) · Firma (Pilotní program,
Kontakt: {supportEmail}, {supportPhone}) · Právní (Obchodní podmínky, Ochrana osobních údajů).
Spodní řádek: „© 2026 {legalName}“.

PRÁVNÍ STRÁNKY
/obchodni-podminky a /ochrana-osobnich-udaju: nadpis, žlutý rámeček „Pracovní verze – text připravuje advokát“,
pod ním osnova kapitol (bez vymyšleného právního textu). Ochrana osobních údajů: osnova pro formulář pilotů
(správce {legalName}, účel: odpověď na zájem o pilotní program, doba uložení, práva subjektu, kontakt).

SEO
title „{name} – systém pro autobazary: výkup, inzerce, smlouvy“, description „Vůz zadáte jednou a prodá se
všude: výkup v mobilu, prověrka, inzerce na Sauto, TipCars a vašem webu, smlouvy i faktury. 30 dní zdarma.“
Open Graph obrázek vygeneruj jako 1200×630 z textového loga a hero nadpisu na tmavě modré.
```

---

## C) Navazující prompty (po jednom)

1. `Projdi celý web na šířce 375 px a 768 px. Oprav vše, co přetéká, je menší než 44 px na dotyk nebo má kontrast pod 4.5:1. Vypiš, co jsi změnil.`
2. `Zkontroluj, že oranžová (accent) je na každé obrazovce použitá nejvýš dvakrát a jen na hlavní akci nebo ceně. Kde je navíc, nahraď ji tmavě modrou nebo neutrální.`
3. `Ověř, že všechny odkazy do aplikace jdou přes withUtm() a nesou utm_* z aktuální URL. Přidej k tomu jednoduchý test.`
4. `Spusť Lighthouse (mobile) a oprav vše pod 90 ve všech kategoriích. Hlavně LCP hero a CLS při načtení písma.`
5. `Formulář pilotu: zkus odeslání bez VITE_SIGNUP_URL, s chybou 400 {errors:{email:"Neplatný e-mail"}} (mock) a s úspěchem 201. Ověř, že honeypot website je pro člověka neviditelný a pro čtečku obrazovky skrytý.`
6. Až bude název: `Změň v src/config/brand.ts name na „X“, legalName na „X s.r.o.“ a domain na „x.cz“ (appUrl, widgetUrl a e-mail odvoď z domény). Nic jiného neměň.`
7. Až budou skuteční piloti: `Přidej sekci referencí s těmito citacemi a logy: … (jen se svolením bazarů).`
