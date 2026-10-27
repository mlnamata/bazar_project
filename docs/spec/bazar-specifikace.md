# AutoCore Bazar – specifikace prvního produktu

2026-10-26 · @mlnamat

První placená verze AutoCore je systém pro autobazary: vůz se zadá jednou při výkupu a odtud jde do přípravy, na portály, na web bazaru i do kupní smlouvy. Servis a marketplace dílů přijdou až po bazarech. Název produktu zatím není („AutoCore“ je jen pracovní, koliduje s autocore.io); v kódu je na jednom místě jako placeholder. Celkový návrh platformy je v [platforma-navrh.md](platforma-navrh.md).

## Proč bazar jako první

Bazar je nejrychlejší cesta k platícím zákazníkům: jeho největší bolest (ruční inzerce na každém portálu, ocenění a prověrky mimo systém) vyřeší software sám, bez marketplace dílů a bez dodavatelů na druhé straně. Servis a díly přijdou až ve chvíli, kdy na platformě budou bazary a jejich vozy.
- **Z1 Rychlá hodnota:** bazar vidí úsporu první den – vůz zadá jednou a je na Sauto, TipCars a na svém webu.
- **Z2 Žádný problém dvou stran:** produkt funguje i pro jediného zákazníka; tržiště dílů potřebuje kupující i prodávající najednou.
- **Z3 Data od začátku:** každý výkup a prodej plní databázi cen, km a dnů do prodeje, ze které později stojí ocenění a tržní dashboard.
- **Z4 Měřitelná návratnost:** cena předplatného se porovná s jedním vozem prodaným o pár dní dřív nebo s ušetřenou hodinou denně na inzerci.

| Část                                        | Původní návrh                | Bazar jako první                                            |
|---------------------------------------------|------------------------------|-------------------------------------------------------------|
| Cílová skupina                              | servisy, hned za nimi bazary | bazary 5–150 vozů (C2), bazary s vlastní dílnou (C3)        |
| Sklad vozů, výkup, prodej (B6)              | MVP                          | MVP – jádro produktu                                        |
| Publikace na portály, AI texty (A9.8–A9.16) | MVP                          | MVP                                                         |
| Plugin na web (B6.10–B6.12)                 | MVP základ                   | MVP základ                                                  |
| VIN a prověrky (V4)                         | MVP                          | MVP                                                         |
| Kontrola km (K5)                            | v1                           | MVP základ: časová osa km, v1 semafor                       |
| Ocenění (O5)                                | v1                           | MVP základ: srovnatelné vozy, v1 odpočet oprav              |
| Fakturace, CRM (F7)                         | MVP pro servisy              | MVP jen pro prodej vozů: doklady, zvláštní režim DPH, leady |
| Servis (SV)                                 | MVP                          | v1 jen interní příprava vozu, plný servis v2                |
| Sklad dílů (S2)                             | MVP                          | v2                                                          |
| Marketplace dílů (M1)                       | MVP agregátor                | v2                                                          |

Kódy funkcí z původního návrhu zůstávají; nové funkce v tomto dokumentu mají kód **BZ**.

## Proces vozu

**Proces vozu (diagram v textu):**
1. Výkup (VIN, prověrka, km, ocenění, smlouva) → 2. Příprava (úkoly a náklady, předprodejní checklist) → 3. Inzerce (fotky, AI text, portály + web, QR) → 4. Zájemce (lead, prohlídka, zkušební jízda) → 5. Rezervace (záloha, lhůta, stav na portálech) → 6. Prodej (smlouva, faktura, marže se uzavře) → 7. Po prodeji (stažení z portálů, přepis, recenze).
- Smyčka: zrušená rezervace vrací vůz do kroku 3.
- Smyčka: protiúčet – vůz zákazníka z kroku 6 začíná vlastní cestu v kroku 1.

Zrušená rezervace vrací vůz do inzerce, vůz zákazníka v protiúčtu začíná vlastní cestu výkupem; vůz bez dotazu po 30–60 dnech dostane návrh zlevnění (A9.15) nebo jde do burzy mezi bazary (BZN.8).

## Funkce bod po bodu

Každý vůz má jednu kartu, na kterou se postupně skládá výkup, náklady, inzerce i prodej; marže a dny na skladě se počítají samy. Fáze: **MVP** = první verze k prodeji, **v1**, **v2**.

### Sklad vozů
- **B6.1 Karta a stavy vozu:** výkup → příprava → připraveno → inzerováno → rezervováno → prodáno / vráceno / odepsáno; u každého stavu datum a kdo ho změnil. MVP
- **BZ1.1 Ekonomika vozu:** nákupní cena, náklady (příprava, doprava, STK, prověrka, inzerce, provize), cílová a minimální prodejní cena, marže v Kč a %, dny na skladě. MVP
- **BZ1.2 Přehled skladu:** tabulka i dlaždice vozů, filtry (stav, značka, dny na skladě, marže), barevné upozornění na vozy nad 60 dní. MVP
- **BZ1.3 Umístění a klíče:** kde vůz stojí (plocha, pobočka, u servisu), kdo má klíče a kdy je vrátí. v1
- **BZ1.4 Dokumenty k vozu:** malý a velký technický průkaz, COC list, servisní kniha, výkupní smlouva, STK – sken mobilem, hlídání chybějícího dokladu. MVP

### Výkup
- **B6.2 Výkup v mobilu:** VIN z fotky (V4.12) → technické údaje a výbava (V4.1) → prověrka (V4.4) → checklist stavu (SV.3) → nabídka ceny → výkupní smlouva a plná moc k přepisu, podpis prstem. MVP
- **BZ2.1 Rychlé ocenění při výkupu:** srovnatelné vozy z trhu (O5.6), cena prověrky a odhad nákladů na přípravu; výsledek = doporučená výkupní cena a očekávaná marže. MVP základ, v1 s odpočtem oprav (O5.7)
- **BZ2.2 Výkupní lead z webu:** formulář „Kolik stojí moje auto“ (O5.9) pošle bazaru VIN, km a fotky; prodejce zavolá s nabídkou. v1
- **B6.4 Komisní prodej:** vůz cizího majitele, smlouva o komisi, provize, vyúčtování majiteli po prodeji. v1
- **BZ2.3 Protiúčet:** vykupovaný vůz se započte do ceny prodávaného – jedna smlouva, rozdíl k doplacení. MVP

### Příprava
- **B6.3 Příprava vozu:** úkoly k vozu (čištění, leštění, opravy, STK, nové pneu), dodavatel (vlastní dílna, externí servis) a cena; náklady se samy přičtou k vozu. MVP jednoduché úkoly, v1 zakázka do servisu na platformě
- **BZ3.1 Checklist před prodejem:** předprodejní kontrola s fotkami; bez dokončení nejde vůz zveřejnit (lze vypnout). MVP

### Inzerce
- **B6.6 Focení podle šablony:** 16 záběrů s vodítkem v mobilu, rozmazání SPZ, logo bazaru; ve v1 AI vyrovnání a výměna pozadí. MVP základ
- **A9.8–A9.12 AI texty:** popis, titulek a klíčová slova z dat vozu s kontrolou pravdivosti; čeština v MVP, SK, DE, EN ve v1. MVP
- **A9.13–A9.14 Publikace jedním klikem:** zaškrtnout portály → publikovat; změna ceny nebo fotek se propíše všude, po prodeji se vůz stáhne ze všech najednou; chyby importu srozumitelně. MVP Sauto, TipCars, vlastní web
- **B6.8 Odznak prověření:** výsledek prověrky a časová osa km v inzerátu i v pluginu. MVP
- **A9.15 Pravidla zviditelnění:** návrh topování nebo zlevnění, když vůz dlouho nemá dotaz; vždy s potvrzením. v1

### Prodej
- **B6.13 Leady na jednom místě:** dotazy z portálů, webu, telefonu a e-mailu se přiřadí k vozu a prodejci; stav leadu (nový, kontaktován, prohlídka, nabídka, prodáno, ztraceno). MVP
- **BZ4.1 Zkušební jízda:** rezervace termínu, foto řidičáku, podpis souhlasu a předávací údaje (km, palivo). MVP
- **BZ4.2 Rezervace se zálohou:** viz nové funkce BZN.2. v1
- **B6.14 Dokumenty prodeje:** kupní smlouva, předávací protokol, faktura ve zvláštním režimu DPH pro použité zboží, podklady k přepisu; vše vyplněné z karty vozu. MVP
- **BZ4.3 Odpovědnost za vady ve smlouvě:** u spotřebitele platí 24 měsíců od převzetí a u ojetého vozu jde dohodou zkrátit na 12 měsíců ([ARROWS](https://arws.cz/novinky-v-arrows/ktere-vady-lze-u-ojeteho-automobilu-z-autobazaru-reklamovat)); šablona smlouvy s výčtem známých vad z checklistu – ověří advokát. MVP
- **B6.15 Financování a pojištění:** podrobně v modulu F&I (FI.1–FI.34). MVP kalkulačka, v1 žádosti, pojištění a záruky

### Po prodeji
- **BZ5.1 Přepis vozu:** checklist kroků a dokumentů; online přepis přes Portál dopravy chystá vláda převážně od 1. 7. 2027, zákon ještě projednává sněmovna ([Advokátní deník](https://advokatnidenik.cz/2026/07/28/navrh-na-prevody-vozidel-on-line-bez-navstevy-uradu-vlada-schvalila/)) – sledovat a napojit, jakmile bude rozhraní. MVP checklist, v2 napojení
- **BZ5.2 Reklamace vozu:** evidence reklamace s vazbou na kupní smlouvu a checklist, lhůty a řešení. v1
- **BZ5.3 Péče o zákazníka:** po prodeji hodnocení na Google, připomínka STK a nabídka výkupu za 3–4 roky. v1

### Analytika
- **A9.1 Moje firma:** tržby, marže na voze, obrátka skladu, výkon prodejců. MVP
- **A9.2 Výkon inzerátů:** zobrazení a dotazy po vozech a portálech, konverze dotaz → prodej. MVP web, v1 portály
- **A9.3–A9.7 Tržní panely:** nejžádanější modely, vývoj cen, dny do prodeje, skóre vozu a „co vykupovat“ – až od cca 30 bazarů na platformě. v1–v2

## Nové funkce

Osm funkcí, které v původním návrhu nebyly; dvě z nich (BZN.1 a BZN.3) navrhuji rovnou do MVP, protože zkracují nasazení a přinášejí leady bez práce navíc.

| Kód   | Funkce                 | Co dělá                                                                                                                                        | Proč                                                                                                                                                                                        | Fáze |
|-------|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------|
| BZN.1 | Převzetí skladu za den | import vozů z exportu Sauto / TipCars, z CSV nebo z webu bazaru včetně fotek                                                                   | bazar nezačíná od nuly – nejčastější důvod, proč systém nezmění; možnosti exportu z portálů ověřit                                                                                          | MVP  |
| BZN.2 | Rezervace se zálohou   | zákazník z pluginu zaplatí zálohu kartou, vůz se sám přepne na rezervováno na webu a portálech, kde to portál umí; po lhůtě se rezervace zruší | méně „ještě si to rozmyslím“; peníze jdou rovnou na účet bazaru přes jeho platební bránu, platforma je nedrží                                                                               | v1   |
| BZN.3 | QR kód na voze         | štítek za sklem: zákazník na ploše naskenuje a vidí cenu, výbavu, prověrku a pošle dotaz i mimo otevírací dobu                                 | lead z lidí, kteří chodí po ploše večer a o víkendu                                                                                                                                         | MVP  |
| BZN.4 | Hlídací pes poptávek   | zákazník zadá model, rozpočet a km; při novém vhodném voze dostane upozornění on i prodejce; neuspokojené poptávky ukazují, co vykupovat       | prodej vozu, který bazar ještě nemá, a podklad pro výkup (A9.7)                                                                                                                             | v1   |
| BZN.5 | Dovoz z Německa        | z odkazu na mobile.de nebo z VIN: historie přes carVertical, kalkulace ceny s dopravou, evidenční kontrolou a registrací, checklist dokladů    | dovezené auto tvoří asi polovinu prověřovaných ojetin a Německo je hlavní zdroj; 87 % aut z Německa mělo záznam o škodě ([Autojournal / carVertical](https://www.autojournal.cz/?p=315998)) | v1   |
| BZN.6 | Video a osobní nabídka | prodejce natočí krátké video vozu s komentářem a pošle zájemci stránku s vybranými vozy                                                        | prodej na dálku, zájemce z druhého konce republiky přijede už rozhodnutý                                                                                                                    | v1   |
| BZN.7 | Provize prodejců       | provize z marže nebo pevnou částkou za vůz, měsíční výpis                                                                                      | majitel nemusí počítat v Excelu, prodejci vidí svůj výkon                                                                                                                                   | v1   |
| BZN.8 | Burza vozů mezi bazary | bazary si nabízejí vozy za velkoobchodní ceny – ležáky, vozy mimo jejich segment                                                               | rychlé uvolnění skladu a síťový efekt, který jiné systémy nemají                                                                                                                            | v2   |

Dovoz roste: v lednu a únoru 2026 se v ČR zaregistrovalo 22 647 dovezených ojetin, o 3,3 % víc než rok předtím ([Kurzy.cz / TipCars](https://zpravy.kurzy.cz/852662-komentar-tipcars-k-dovozu-ojetych-vozu-v-unoru-2026/)).

## Modul F&I: financování, pojištění a upsell

Ke každému prodanému vozu bazar nabídne financování, pojištění, záruku a služby jako jeden balíček s měsíční splátkou. Zprostředkovatelem vůči ČNB je bazar, AutoCore dodává technologii a vydělává na poplatcích od partnerů – bazar má modul v tarifu zdarma. Schváleno hlasováním 26. 10. 2026.

**Fáze:** MVP = kalkulačka splátek v inzerátu, pluginu a u prodejce + poptávka k jednomu partnerovi; v1 = porovnání partnerů, online podpis, pojištění, záruky, balíčky, compliance; v2 = služby pro bazar a automatický životní cyklus.

**F&I – role a tok peněz (diagram v textu):**
- Zákazník kupuje vůz od bazaru; splátky a pojistné platí zákazník přímo partnerovi.
- Bazar (zprostředkovatel registrovaný u ČNB) posílá žádost / smlouvu partnerovi (banka, leasing, pojišťovna, záruky); partner platí bazaru provizi.
- AutoCore (software v tarifu, peníze nedrží) dostává buď A: poplatek za smlouvu od partnera, nebo B: podíl z provize od bazaru.

U každého partnera platí jen jedna varianta: A, pokud partner platí AutoCore poplatek, jinak B (FI.2).

### Pravidla
- **FI.1 Regulační model:** bazar se registruje u každého partnera – u úvěru jako zprostředkovatel vázaného spotřebitelského úvěru (registraci podává poskytovatel, ČNB zapíše do 5 pracovních dnů, [zákon 257/2016, § 37–40](https://www.podnikatel.cz/zakony/zakon-o-spotrebitelskem-uveru/f5851471/)), u pojištění podle zákona 170/2018 o distribuci pojištění. AutoCore smlouvy nezprostředkovává a nedrží peníze zákazníků. Typ registrace u pojištění ověří advokát. v1
- **FI.2 Provize podle partnera:** kde partner platí AutoCore technologický poplatek za smlouvu uzavřenou v systému, bazar si nechá celou provizi; kde poplatek není, bazar odvede AutoCore podíl ze své provize (výši vyjednat, návrh 10–20 %). F&I je ve všech tarifech bez příplatku. v1
- **FI.3 Férové řazení:** nabídky partnerů se řadí podle RPSN a celkové částky, kterou zákazník zaplatí; provize na pořadí nemá vliv. v1

### Financování zákazníka
- **FI.4 Produkty:** spotřebitelský úvěr na auto, finanční leasing (podnikatelé a firmy), operativní leasing ojetin, úvěr s balónovou splátkou. v1
- **FI.5 Kalkulačka všude:** měsíční splátka u každého vozu v pluginu, v kartě vozu, na obrazovce prodeje a v inzerátu, kde to portál dovolí; s povinným reprezentativním příkladem a RPSN od partnera. MVP
- **FI.6 Více partnerů najednou:** jedna žádost jde 2–4 partnerům, nabídky se zobrazí vedle sebe; vyšší podíl schválených žádostí. v1
- **FI.7 Předschválení z webu:** měkká kontrola z příjmů a výdajů bez zápisu do registrů, plná kontrola až v žádosti – ověřit, který partner to umí. v1
- **FI.8 Žádost až po podpis online:** kalkulace → předschválení → žádost s doklady → schválení → elektronický podpis; stav žádosti vidí prodejce v kartě vozu i v leadu. MVP poptávka k 1 partnerovi, v1 celý proces

### Pojištění a záruky
- **FI.9 Povinné ručení a havarijní:** srovnání více pojišťoven a sjednání při předání; zákazník odjíždí pojištěný a zelená karta jde rovnou do podkladů k přepisu. v1
- **FI.10 GAP:** dorovnání rozdílu mezi kupní cenou a plněním při totální škodě nebo krádeži; nabízí se ke každému úvěru a leasingu. v1
- **FI.11 Pojištění schopnosti splácet:** spolu s úvěrem, vždy jako volitelné. v1
- **FI.12 Asistence a skla:** levné připojištění k povinnému ručení. v1
- **FI.13 Prodloužená záruka:** pojištění záruky od partnera na 12–36 měsíců, cena podle vozu, stáří a km se spočítá sama a nabídne se u každého prodeje. v1

### Služby, balíčky a další nápady
- **FI.14 Doplňkové služby:** přepis a doprava vozu domů, detailing, keramika, druhá sada pneu, servisní balíček na 2–3 roky, plná prověrka a protokol pro kupujícího; ceník si bazar nastaví sám. v1
- **FI.15 Balíčky Základ / Komfort / Premium:** systém z vozu a profilu zákazníka sestaví tři balíčky (financování + pojištění + záruka + služby) s jednou měsíční splátkou; zákazník volí mezi celky. v1
- **FI.16 Splacení starého úvěru při výkupu:** u protiúčtu nový úvěr splatí zbytek starého a zákazník má jednu splátku. v1
- **FI.17 Garantovaný zpětný výkup:** bazar předem garantuje výkupní cenu za 3 roky; navazuje na balónovou splátku a vrací zákazníka do bazaru. v2
- **FI.18 Auto na předplatné:** měsíční paušál s pojištěním a servisem na 6–24 měsíců z vozů na skladě. v2
- **FI.19 Splátky na přípravu a opravy:** financování oprav, až přibude servis. v2

### Služby pro bazar
- **FI.20 Skladové financování:** partner financuje vozy na ploše, bazar splácí při prodeji; AutoCore hlídá každý financovaný vůz (stav, dny na skladě, splatnost). v2
- **FI.21 Financování výkupu a dovozu:** rychlé peníze na výkup nebo nákup v Německu zajištěné vozem (navazuje na BZN.5). v2
- **FI.22 Pojištění skladu a odpovědnosti:** vozy na ploše, vůz při zkušební jízdě, odpovědnost bazaru. v2
- **FI.23 Flotila bazaru:** leasing a pojištění vozů, které bazar sám používá. v2

### Po prodeji
- **FI.24 Výročí pojištění:** 6 týdnů předem srovnání a nabídka levnějšího pojištění. v2
- **FI.25 Konec úvěru nebo leasingu:** před poslední splátkou nabídka výkupu a nového vozu se splátkou. v2
- **FI.26 Konec záruky:** nabídka prodloužení. v2
- **FI.27 STK a servis:** připomínky, později objednání do servisu v AutoCore. v2

### Prodejci
- **FI.28 Provize z F&I:** podíl z úvěrů, pojištění a záruk se přičte do výpisu provizí (BZN.7). v1
- **FI.29 Žebříček a cíle:** podíl prodejů s úvěrem, pojištěním nebo zárukou po prodejcích, měsíční cíl. v1
- **FI.30 Nápověda u prodeje:** systém doporučí, co nabídnout (například GAP u úvěru nad 300 tis. Kč) a proč. v1

### Compliance
- **FI.31 Záznam z jednání:** potřeby a možnosti zákazníka, co mu bylo nabídnuto a co si vybral; podepsané PDF ke smlouvě. v1
- **FI.32 Hlídání registrace a odbornosti:** bez platné registrace bazaru u ČNB a odbornosti prodejce nejde úvěr ani pojištění nabídnout. v1
- **FI.33 Ověření totožnosti (AML):** sken dokladu a online ověření, kontrola sankčních seznamů u vyšších částek. v1
- **FI.34 Archiv a souhlasy:** všechny dokumenty nejméně 5 let; souhlas se zpracováním a marketingový souhlas zvlášť. v1

## Rozsah MVP

MVP je hotové, když bazar zvládne celý život vozu od výkupu po prodej v jednom systému a vůz zveřejní na Sauto, TipCars a svém webu jedním klikem. Co není v tabulce „V MVP“, se nestaví – i když je to ve specifikaci označené jako MVP z původního návrhu.

| Oblast          | V MVP                                                                                                                                     | Až později                                                       |
|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| Účet a firma    | registrace, firma s IČO z ARES, 1 pobočka, uživatelé a role (majitel, prodejce, výkupčí, účetní), audit log                               | víc poboček v UI, vlastní role (v1)                              |
| Sklad vozů      | karta vozu, stavy, ekonomika a marže, přehled s filtry, dokumenty k vozu (B6.1, BZ1.1, BZ1.2, BZ1.4)                                      | umístění a klíče BZ1.3 (v1)                                      |
| Převzetí skladu | import z CSV + fotky z URL (BZN.1)                                                                                                        | import přímo z portálů, pokud to rozhraní dovolí (v1)            |
| Výkup           | průvodce v mobilu, VIN ručně i z fotky, prověrka, checklist, smlouva s podpisem, protiúčet (B6.2, BZ2.1 základ, BZ2.3)                    | komise B6.4, výkupní leady BZ2.2 (v1)                            |
| VIN a historie  | Vincario (dekódování, odcizení), Cebia prověrka, časová osa km, protokol vozu PDF                                                         | DAT výbava, carVertical, km semafor (v1)                         |
| Příprava        | úkoly s nákladem, předprodejní checklist (B6.3 jednoduché, BZ3.1)                                                                         | zakázka do servisu na platformě (v2)                             |
| Fotky           | 16 záběrů s vodítkem, pořadí, komprese, ruční rozmazání SPZ, logo                                                                         | automatické rozmazání SPZ a pozadí (v1)                          |
| Inzerce         | AI text v češtině s kontrolou pravdivosti, publikace na Sauto + TipCars + web, stav a chyby, stažení po prodeji, odznak prověření         | další portály, jazyky, pravidla zviditelnění (v1)                |
| Leady a prodej  | leady z pluginu, QR štítků a ručně, zkušební jízda, kupní smlouva, předávací protokol, faktura ve zvláštním režimu DPH, checklist přepisu | dotazy z portálů automaticky, rezervace se zálohou, EET 2.0 (v1) |
| Plugin          | vložení jedním řádkem, výpis s filtry, detail, dotaz a prohlídka, měření (PL.1, PL.5–PL.9)                                                | WordPress, API, SEO stránky (v1)                                 |
| F&I             | kalkulačka splátek v kartě vozu, pluginu a inzerátu, poptávka k 1 partnerovi (FI.5, FI.8 základ)                                          | vše ostatní z F&I (v1–v2)                                        |
| Přehledy        | přehled dne, moje firma, výkon inzerátů na webu (A9.1, A9.2 web)                                                                          | tržní panely (v1)                                                |
| Účetnictví      | export dokladů (ISDOC, CSV pro Pohodu)                                                                                                    | obousměrně (v1)                                                  |
| Provoz          | PWA na mobil, demo režim se vzorovými daty, předplatné fakturované ručně                                                                  | platba kartou za tarif (v1)                                      |

**Akceptační kritéria MVP** – bez nich se nespouští piloti:

1.  Nový bazar se zaregistruje a nahraje sklad z CSV do 30 minut.

2.  Vůz projde od výkupu po zveřejnění na Sauto, TipCars a webu za méně než 15 minut práce.

3.  Změna ceny se propíše na všechny kanály do 5 minut; prodej vůz stáhne všude.

4.  Kupní smlouva, předávací protokol a faktura vzniknou bez ručního přepisování.

5.  Plugin jde vložit jedním řádkem a výpis se na mobilu načte do 2,5 s.

6.  Automatické testy dokazují, že firma nikdy nevidí data jiné firmy.

7.  Výkup, focení a zkušební jízda fungují na telefonu a snášejí výpadek signálu.

Všechna placená napojení mají testovací náhražku (mock), takže aplikace běží v demo režimu bez smluv – to je zároveň klikací prototyp pro fázi 0.

## Obrazovky MVP

MVP má 14 obrazovek: sedm pro kancelář (počítač), tři mobilní pro plochu, kde se vůz fotí, vykupuje a předává, a čtyři na obojím.

| \#  | Obrazovka                | Kdo               | Zařízení  | Co na ní je                                                                                      |
|-----|--------------------------|-------------------|-----------|--------------------------------------------------------------------------------------------------|
| 1   | Přehled dne              | majitel, prodejce | PC, mobil | nové leady, dnešní prohlídky a zkušební jízdy, vozy nad 60 dní, chyby publikace                  |
| 2   | Sklad vozů               | všichni           | PC        | tabulka a dlaždice, filtry, hromadné akce (publikovat, zlevnit, stáhnout)                        |
| 3   | Karta vozu               | všichni           | PC, mobil | záložky: údaje a výbava, fotky, ekonomika, příprava, prověrka a km, inzerce, dokumenty, historie |
| 4   | Výkup – průvodce         | výkupčí           | mobil     | VIN z fotky → údaje → prověrka → checklist → ocenění → smlouva a podpis                          |
| 5   | Focení                   | prodejce          | mobil     | 16 záběrů s vodítkem, pořadí fotek, rozmazání SPZ                                                |
| 6   | Příprava                 | vedoucí           | PC, mobil | úkoly po vozech, dodavatel, cena, stav; předprodejní checklist                                   |
| 7   | Inzerát a publikace      | prodejce          | PC        | AI text s úpravami, výběr portálů, stav a chyby po portálech                                     |
| 8   | Leady                    | prodejce          | PC, mobil | seznam podle stavu, detail s historií komunikace, přiřazení k vozu a prodejci                    |
| 9   | Zkušební jízda a předání | prodejce          | mobil     | foto řidičáku, km a palivo, podpis zákazníka                                                     |
| 10  | Prodej                   | prodejce, účetní  | PC        | kupní smlouva, protiúčet, faktura ve zvláštním režimu DPH, checklist přepisu                     |
| 11  | Zákazníci                | prodejce          | PC        | kontakty, koupené a prodané vozy, leady, dokumenty                                               |
| 12  | Přehledy                 | majitel           | PC        | tržby, marže na voze, obrátka, dny na skladě, výkon inzerátů a prodejců                          |
| 13  | Nastavení webu           | majitel           | PC        | vzhled pluginu, kód k vložení, doména, formuláře, QR štítky (BZN.3)                              |
| 14  | Nastavení firmy          | majitel           | PC        | pobočky, uživatelé a role, portály a jejich klíče, šablony dokumentů, tarif a platby             |

Modul F&I přidá ve v1 dvě obrazovky: **15 Nabídka F&I** (balíčky Základ / Komfort / Premium, porovnání partnerů, záznam z jednání, podpis) a **16 Žádosti a provize** (stav žádostí po partnerech, vyplacené a čekající provize, žebříček prodejců).

Wireframy připravím po schválení tohoto seznamu.

## Datový model

**Datový model** – úplná definice je v `supabase/migrations/20261027000001_init.sql` a přehled v `docs/data-model.md`. Vůz je středem: firma (tenant) → pobočky, uživatelé, portálové účty; obchod (zákazník, lead, zkušební jízda, rezervace, výkup, prodej) a karta vozu (prověrky, záznamy km, fotky, dokumenty, náklady a úkoly, inzeráty) odkazují na vůz.

Každá tabulka nese ID firmy a databáze ho hlídá řádkovým zabezpečením, takže bazar nikdy nevidí data jiného; inzerát odkazuje i na portálový účet, přes který byl zveřejněn. Záznamy km a prověrky se ukládají k VIN, ne jen k vozu firmy, aby je šlo počítat do sdílené databáze km (K5.4).

## Plugin na web bazaru

Nabídka na webu bazaru se plní ze stejné karty vozu jako portály, takže nikdo nepřepisuje inzeráty dvakrát; MVP stačí jeden řádek kódu, SEO stránky přijdou ve v1.
- **PL.1 Vložení jedním řádkem:** `<script>` + vlastní HTML prvek s nabídkou (web komponenta, název prvku podle značky); převezme písmo a barvy webu, jde vložit do Wixu, Webnode, WordPressu i vlastního webu. *MVP*
- **PL.2 WordPress plugin:** instalace z administrace, shortcode a blok pro editor, nastavení vzhledu bez kódu. v1
- **PL.3 API a feed:** REST API a XML/JSON feed nabídky pro weby na míru a pro agentury, které bazarům dělají weby. v1
- **PL.4 SEO stránky vozů:** každý vůz má vlastní adresu na subdoméně bazaru (např. auta.bazar.cz/skoda-octavia-2019-123), vykreslenou na serveru se strukturovanými daty pro Google (schema.org Car); widget čistě v JavaScriptu Google indexuje hůř. v1
- **PL.5 Výpis a filtry:** značka, model, cena, rok, km, palivo, převodovka, karoserie; řazení, uložení filtru do adresy (sdílení odkazu). MVP
- **PL.6 Detail vozu:** galerie, výbava podle skupin, odznak prověření a časová osa km, protokol vozu v PDF, podobné vozy. MVP
- **PL.7 Akce zákazníka:** dotaz na vůz, rezervace prohlídky a zkušební jízdy, kalkulačka splátek, „Kolik stojí moje auto“ (O5.9), záloha (BZN.2), hlídací pes (BZN.4). MVP dotaz a prohlídka, v1 zbytek
- **PL.8 Měření:** zobrazení, prokliky a odeslané formuláře po vozech do A9.2; s cookies jen se souhlasem návštěvníka. MVP
- **PL.9 Výkon:** nabídka se načítá z CDN, fotky ve formátu WebP v několika velikostech, cíl načtení výpisu pod 2 s na mobilu. MVP
- **PL.10 Více poboček a značek:** jeden bazar může mít několik webů nebo jeden web s filtrem podle pobočky. v1

## Portály, prověrky a dokumenty

MVP potřebuje pět smluv: Sauto, TipCars, Vincario, Cebia a SMS bránu; ostatní napojení počkají na v1. U každého partnera je potřeba ve fázi 0 získat cenovou nabídku a testovací přístup.

| Oblast             | Partner                                           | Napojení                                                                                                                                                                                                                                                                      | Fáze       |
|--------------------|---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|
| Inzerce            | Sauto.cz                                          | importní rozhraní XML-RPC: vložení, úprava, smazání inzerátu, fotky, topování; softwarový klíč a testovací účet přidělí Seznam ([dokumentace](https://napoveda.seznam.cz/soubory/Sauto.cz/Importni_dokumentace_Sauto.pdf))                                                    | MVP        |
| Inzerce            | TipCars                                           | dealerský import; s roční licencí přeposílá inzeráty na cca 30 webů ([nápověda](https://www.tipcars.com/napoveda.html))                                                                                                                                                       | MVP        |
| Inzerce            | autobazar.eu, Facebook Marketplace, Bazoš, Sbazar | formát importu ověřit; kde import není, připravený text a fotky ke zkopírování                                                                                                                                                                                                | v1         |
| Inzerce            | mobile.de                                         | rozhraní pro prodejce – ověřit podmínky pro české bazary                                                                                                                                                                                                                      | v2         |
| VIN a trh          | Vincario                                          | dekódování VIN, kontrola odcizení, tržní statistiky cen ([Make](https://apps.make.com/vincario-vindecoder?hl=fr-FR))                                                                                                                                                          | MVP        |
| Prověrka ČR        | Cebia                                             | B2B smlouva na prověrky; Cebia nabízí bazarům program Cebia Verify (sleva na prověření v AUTOTRACER, certifikát Cebia REPORT u inzerátu) ([Cebia](https://www.cebia.cz/novinky/novinky-z-cebia/existuje-seznam-prodejcu-ojetych-vozu-kteri-poskytuji-na-svem-webu-provereni)) | MVP        |
| Prověrka zahraničí | carVertical                                       | B2B API, nutné pro dovoz (BZN.5) ([carVertical](https://www.carvertical.com/pl/business/api))                                                                                                                                                                                 | v1         |
| Výbava a lak       | DAT SilverDAT                                     | licence, za dotaz ([DAT](https://www.datgroup.com/products/vehicle-identification/))                                                                                                                                                                                          | v1         |
| Platby záloh       | Stripe / GoPay / Comgate                          | brána na účet bazaru                                                                                                                                                                                                                                                          | v1         |
| Firmy              | ARES                                              | doplnění firmy podle IČO                                                                                                                                                                                                                                                      | MVP        |
| SMS a e-mail       | SMS brána, transakční e-mail                      | potvrzení prohlídek, odpovědi na leady                                                                                                                                                                                                                                        | MVP        |
| Účetnictví         | Pohoda, Money S3, ABRA Flexi                      | export dokladů                                                                                                                                                                                                                                                                | MVP export |
| Přepis             | Portál dopravy                                    | online přepis se chystá převážně od 1. 7. 2027 – napojit, až bude rozhraní ([Advokátní deník](https://advokatnidenik.cz/2026/07/28/navrh-na-prevody-vozidel-on-line-bez-navstevy-uradu-vlada-schvalila/))                                                                     | v2         |

### Dokumenty, které systém vyplní sám

Všechny šablony musí před spuštěním zkontrolovat advokát (P14.8).
- **D1** Výkupní smlouva a plná moc k přepisu
- **D2** Smlouva o komisním prodeji a vyúčtování komitentovi
- **D3** Kupní smlouva s výčtem známých vad a dohodou o odpovědnosti za vady (BZ4.3)
- **D4** Předávací protokol (km, palivo, klíče, doklady, příslušenství)
- **D5** Souhlas se zkušební jízdou
- **D6** Faktura ve zvláštním režimu DPH pro použité zboží / běžná faktura
- **D7** Potvrzení o záloze a podmínky rezervace
- **D8** Protokol vozu v PDF (výbava, prověrka, časová osa km, fotky)

## Ceník pro bazary

Cena roste s počtem vozů na skladě, protože ten nejlíp odpovídá velikosti bazaru i hodnotě, kterou mu systém přináší. Jde o hypotézu k ověření v rozhovorech (fáze 0); částky v Kč bez DPH.

| Tarif   | Vozů na skladě | Uživatelů | Obsah                                                           | Cena / měsíc |
|---------|----------------|-----------|-----------------------------------------------------------------|--------------|
| Bazar S | do 20          | 2         | sklad vozů, výkup, dokumenty, Sauto + TipCars, plugin, AI texty | 990 Kč       |
| Bazar M | do 60          | 5         | vše z S + leady a CRM, přehledy, QR štítky                      | 1 990 Kč     |
| Bazar L | do 150         | 15        | vše z M + víc poboček, vlastní doména pluginu, API              | 3 990 Kč     |
| Síť     | nad 150        | neomezeně | vše + individuální napojení, prioritní podpora                  | od 5 990 Kč  |
- **CB.1 Prověrky na kredit:** Cebia a carVertical přes platformu, marže 20–40 % (P13.3); kredit se dobíjí zvlášť.
- **CB.2 Co platí bazar sám:** licence TipCars a placené topování na portálech – AutoCore je jen přenáší.
- **CB.3 SMS:** v tarifu 200 SMS měsíčně, další za běžnou cenu brány.
- **CB.4 Piloti:** první tři bazary 3 měsíce zdarma výměnou za týdenní zpětnou vazbu, pak 50 % na prvních 12 měsíců.
- **CB.5 Zkušební verze:** 30 dní zdarma bez karty; roční platba se slevou 2 měsíce (P13.5). Modul F&I je ve všech tarifech bez příplatku (FI.2).

## Roadmapa

**Roadmapa bazar-first:**
| Fáze | Termín | Obsah | Brána na konci |
| --- | --- | --- | --- |
| 0 – validace | 11–12/2026 | 15 rozhovorů s bazary, klikací prototyp (demo režim), testy Sauto a TipCars, nabídky dat (Cebia), LOI od 5 bazarů | 3 pilotní bazary |
| MVP Bazar | 1–4/2027 | sklad vozů, výkup, VIN, prověrka Cebia, Sauto + TipCars + web, AI texty, dokumenty, QR štítky, převzetí skladu, kalkulačka splátek | 20 platících bazarů |
| v1 | 5–9/2027 | rezervace se zálohou, dovoz z Německa, další portály, ocenění s opravami, km semafor, tržní panely (30+ bazarů), F&I balíčky a záruky | 60 platících bazarů |
| v2 | od 10/2027 | servis a sklad dílů, burza mezi bazary, Slovensko + mobile.de, auto na předplatné, online přepis, B2B financování | – |

Termíny počítají s týmem 2–3 vývojářů a posunu je podle odpovědi na QB5. EET 2.0 startuje 1. 1. 2027, tedy před MVP: bazar, který bere hotovost nebo kartu na místě, do nasazení použije svou pokladnu.

## Otázky a checklist ke schválení

**Otázky pro tebe** (odpověz komentářem k bodu):
- **QB1 Piloti:** máš už bazary, se kterými můžu udělat rozhovory a které by byly ochotné pilotovat?
- **QB2 Velikost:** cílit jen na menší bazary do 60 vozů, nebo hned i na větší s více pobočkami?
- **QB3 Území:** začít v jednom kraji (osobní obchod, rychlé reference), nebo hned po celé ČR online?
- **QB4 Dovoz:** je dovoz z Německa (BZN.5) pro tvoje první zákazníky důležitý natolik, aby šel do MVP?
- **QB5 Tým a termín:** kdo bude MVP programovat a do kdy chceš mít první platící bazar?
- **QB6 Ceník:** souhlasíš s tarify podle počtu vozů na skladě?
- **QB7 Značka:** prodávat jako „AutoCore Bazar“, nebo jako samostatnou značku?

**Checklist** – odškrtni, co platí; k bodu s výhradou napiš komentář.
- Bazar jako první produkt, servis ve v1–v2, díly ve v2 (tabulka změn)
- Proces vozu podle diagramu
- Sklad vozů a ekonomika vozu (B6.1, BZ1.1–BZ1.4)
- Výkup a rychlé ocenění (B6.2, B6.4, BZ2.1–BZ2.3)
- Příprava vozu (B6.3, BZ3.1)
- Inzerce a publikace na portály (B6.6, B6.8, A9.8–A9.15)
- Prodej a dokumenty (B6.13–B6.15, BZ4.1–BZ4.3, D1–D8)
- Po prodeji (BZ5.1–BZ5.3)
- Nové funkce BZN.1–BZN.8 a jejich fáze (modul F&I FI.1–FI.34 schválen hlasováním)
- 14 obrazovek MVP
- Datový model podle diagramu
- Plugin PL.1–PL.10
- Partneři a napojení podle tabulky
- Ceník S / M / L / Síť a pravidla CB.1–CB.5
- Roadmapa a brány
- Odpovědi na QB1–QB7

Po schválení připravím wireframy 14 obrazovek, podrobný datový model (sloupce a typy) a backlog úkolů pro MVP.

## Zdroje
- [Sauto – importní dokumentace](https://napoveda.seznam.cz/soubory/Sauto.cz/Importni_dokumentace_Sauto.pdf)
- [TipCars – nápověda](https://www.tipcars.com/napoveda.html)
- [Cebia – prodejci s prověřením na webu (Cebia Verify)](https://www.cebia.cz/novinky/novinky-z-cebia/existuje-seznam-prodejcu-ojetych-vozu-kteri-poskytuji-na-svem-webu-provereni)
- [Vincario VIN Decoder (Make)](https://apps.make.com/vincario-vindecoder?hl=fr-FR)
- [carVertical – API pro firmy](https://www.carvertical.com/pl/business/api)
- [DAT – identifikace vozidla podle VIN](https://www.datgroup.com/products/vehicle-identification/)
- [Advokátní deník – online převody vozidel](https://advokatnidenik.cz/2026/07/28/navrh-na-prevody-vozidel-on-line-bez-navstevy-uradu-vlada-schvalila/)
- [ARROWS – reklamace ojetého vozu z autobazaru](https://arws.cz/novinky-v-arrows/ktere-vady-lze-u-ojeteho-automobilu-z-autobazaru-reklamovat)
- [Autojournal – ojetiny z Německa (carVertical)](https://www.autojournal.cz/?p=315998)
- [Kurzy.cz – TipCars k dovozu ojetin v únoru 2026](https://zpravy.kurzy.cz/852662-komentar-tipcars-k-dovozu-ojetych-vozu-v-unoru-2026/)

<!-- -->
- [Zákon o spotřebitelském úvěru – zprostředkovatel vázaného úvěru (§ 37–45)](https://www.podnikatel.cz/zakony/zakon-o-spotrebitelskem-uveru/f5851471/)
- [ARROWS – zákon o distribuci pojištění](https://arws.cz/novinky-v-arrows/zakon-o-distribuci-pojisteni-a-zajisteni)
