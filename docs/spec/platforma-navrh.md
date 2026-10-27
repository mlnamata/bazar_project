# AutoCore – návrh platformy pro autobazary a autoservisy

Oct 26, 2026 · @mlnamat

## Shrnutí

AutoCore (pracovní název, změní se – stejný název už používá software pro autodealery autocore.io) je jedna SaaS platforma, kde autobazar nebo autoservis vyřeší celý den: nakoupí díly od více dodavatelů najednou, vede sklad, přijme auto do servisu přes tablet, podle VIN zjistí výbavu, barvu, historii a stav km, ocení vůz a jedním klikem ho inzeruje na portálech i na vlastním webu. Platforma pro obce (B2G) je samostatný sesterský projekt stejné mateřské firmy – ObecHub, viz část „Mateřská firma a sesterský projekt“.

**Prvním produktem je autobazar** (servis a díly přijdou později) – podrobná specifikace je v AutoCore Bazar – specifikace prvního produktu.

Peníze přicházejí ze tří zdrojů: měsíční předplatné, provize z prodeje použitých dílů a marže na přeprodávaných prověrkách vozů.

**Jak schvalovat:** každý bod má kód (např. **M1.4**). Na konci je checklist – co platí, odškrtni; k čemu máš výhradu, napiš komentář přímo k bodu a já ho přepracuji. U každého bodu je fáze: **MVP** (první verze k prodeji), **v1**, **v2**.

## Cílové skupiny a role

Platforma má dvě strany: **kupující** (bazary, servisy) platí předplatné, **prodávající** (velkoobchody, vrakoviště) přinášejí nabídku dílů. V ČR působí zhruba 400 autobazarů, kterými ročně projde kolem 300 tisíc ojetin ([iROZHLAS](https://www.irozhlas.cz/zpravy-tag/autobazar)).

| Kód | Segment | Hlavní bolest dnes | Co dostane | Fáze |
| --- | --- | --- | --- | --- |
| C1 | Nezávislý autoservis (1–15 zvedáků) | díly objednává u 3–5 dodavatelů zvlášť, papírový zakázkový list | jeden košík dílů, digitální příjem a zakázka, faktura s EET | MVP |
| C2 | Malý a střední autobazar (5–150 vozů) | ruční inzerce na každém portálu, prověrky a ocenění mimo systém | sklad vozů, ocenění, prověrka, export na portály, plugin na web | MVP |
| C3 | Bazar s vlastním servisem | dva oddělené systémy | oba moduly propojené (příprava vozu = interní zakázka) | MVP |
| C4 | Vrakoviště a prodejci použitých dílů | malý dosah, ruční inzerce dílů | prodej servisům na platformě, poptávky dílů | v1 |
| C5 | Velkoobchody nových dílů | – (dodavatel) | další prodejní kanál přes API | MVP (1–2 partneři) |

**R1 – Role uživatelů:** majitel/admin, vedoucí pobočky, přijímací technik, mechanik, skladník, prodejce vozů, účetní, dodavatel, koncový zákazník (jen náhled své zakázky).

**R2 – Model účtů:** jedna firma = jeden tenant, pod ní pobočky a sklady; uživatel může patřit do více firem (externí účetní).

## Modul 1: Marketplace dílů

Návrh: v MVP je marketplace hlavně **agregátor velkoobchodů** (servis se napojí svým vlastním zákaznickým účtem, takže vidí své nákupní ceny), v1 přidá **provizní tržiště použitých a repasovaných dílů**. Tím se vyhneme problému „prázdného tržiště“ na začátku.

- **M1.1 Vyhledávání dílu** podle VIN, SPZ, OE čísla, čísla výrobce, EAN nebo kategorie (stromem „brzdy → kotouče“). Vůz z otevřené zakázky se předvyplní sám. *MVP*
- **M1.2 Katalog a kompatibilita** přes TecDoc (standard trhu s náhradními díly). Licence je komerční a TecDoc říká jen, co pasuje – ne cenu ani sklad, ty jdou z ceníků dodavatelů ([dev-opla](https://dev-opla.com/resources/what-is-tecdoc-auto-parts-ecommerce-guide)). *MVP*
- **M1.3 Zdroje nabídky:** (a) velkoobchody přes API – Inter Cars nabízí API na ceny, dostupnost a objednávky ([Inter Cars](https://intercars.com/en/business-solutions-inter-cars/business-services/software/api-and-csv-client-inter-cars)), další (Auto Kelly, LKQ, Elit) vyjednat; (b) vrakoviště – ruční nahrávání, import CSV, případně napojení přes Ovoko, které má REST API ([Packagist](https://packagist.org/packages/andyts93/laravel-ovoko)); (c) repasované díly; (d) ležáky ze skladů ostatních uživatelů. *MVP (a), v1 (b–d)*
- **M1.4 Porovnání nabídek v jedné tabulce:** cena s DPH i bez, dostupnost (skladem / dnes / zítra), dodací čas na adresu, záruka, stav (nový / použitý A–C / repas), hodnocení prodejce. Řazení „nejlevnější“ a „nejrychleji u mě“. *MVP*
- **M1.5 Jeden košík, více dodavatelů:** objednávka se sama rozdělí na dílčí objednávky; doprava rozvozem dodavatele nebo přes PPL, DPD, Zásilkovnu. *MVP*
- **M1.6 Platby:** nové díly na fakturu přímo od dodavatele (platforma peníze nedrží); použité díly platbou přes platformu s pozdrženou výplatou prodejci do převzetí – přes platební instituci typu Stripe Connect / GoPay / Comgate. *v1*
- **M1.7 Poptávka dílu (reverzní aukce):** servis zadá VIN + díl, vrakoviště a prodejci pošlou nabídky do 2 hodin. *v1*
- **M1.8 Reklamace a vratky:** RMA proces s fotkami, stavy a lhůtami. *v1*
- **M1.9 Hodnocení a ověření prodejců:** ověření IČO přes ARES, hodnocení po každé objednávce. *v1*
- **M1.10 Objednávka ze zakázky:** chybějící díl se objedná přímo ze servisní zakázky a po doručení se na ni sám napáruje. *MVP*

## Modul 2: Sklad

Sklad dílů je propojený s marketplace i se zakázkami, takže většinu pohybů nikdo nezadává ručně.

- **S2.1 Skladová karta:** název, OE číslo, číslo výrobce, EAN, umístění (regál/police/přihrádka), minimální zásoba, nákupní a prodejní cena, fotky. *MVP*
- **S2.2 Příjem:** automaticky z objednávky z marketplace; ručně skenem EAN/QR mobilem; z dodacího listu v PDF (AI vytáhne položky, člověk potvrdí). *MVP (auto + sken), v1 (PDF)*
- **S2.3 Výdej:** na servisní zakázku, prodejem přes pult, interní spotřeba (příprava vozu v bazaru). *MVP*
- **S2.4 Oceňování zásob:** vážený průměr (doporučení; jednodušší než FIFO a běžné v účetních programech). *MVP*
- **S2.5 Hlídání zásob:** upozornění pod minimem a návrh objednávky do košíku. *MVP*
- **S2.6 Inventura mobilem:** sken po regálech, rozdíly, inventurní protokol. *v1*
- **S2.7 Více skladů a poboček:** převodky mezi sklady, sklad v autě mobilního mechanika. *v1*
- **S2.8 Pneuhotel:** uskladnění pneu zákazníků, štítky s QR, připomínka přezutí. *v1*
- **S2.9 Prodej ležáků:** díl bez pohybu přes 180 dní jde jedním klikem na marketplace. *v1*
- **S2.10 Přehledy:** hodnota skladu, obrátkovost, ležáky, marže na dílech. *MVP*

## Modul 3: Servis – příjem vozu a zakázka

Celá zakázka běží od rezervace po předání v jednom záznamu; papír zmizí, ale zákazník dostane vše, co dnes podepisuje na zakázkovém listu.

*(Diagram servisní zakázky – 9 kroků se smyčkou schválení; servis není v MVP bazaru.)*

Po předání systém sám naplánuje připomínku (STK, olej, přezutí), takže se zákazník vrací.

- **SV.1 Online rezervace:** widget na web servisu, kapacita podle zvedáků a mechaniků, potvrzení SMS. *MVP*
- **SV.2 Příjem na tabletu:** foto SPZ a VIN → OCR → automatické doplnění vozu z VIN (Modul 4); stav km s fotkou tachometru; stav paliva; poškození klepnutím do schématu karoserie + fotky; věci ve voze; požadavky zákazníka; podpis prstem. Zakázkový list má zachytit požadované opravy, stav tachometru a paliva, termín a cenu ([TN.cz](https://tn.nova.cz/magazin/auta/novinky/poradna-10-rad-jak-predejit-problemum-v-autoservisech.html)). *MVP*
- **SV.3 Checklisty jako šablony:** servisní prohlídka, příprava na STK, předprodejní kontrola, výkup do bazaru, sezónní prohlídka; každá položka OK / pozor / závada + fotka, u pneu hloubka dezénu v mm. Šablony si servis upravuje sám. *MVP*
- **SV.4 Digitální nabídka ke schválení:** zákazník dostane odkaz s fotkami závad a cenou a schválí položky jednotlivě. Servis nesmí bez souhlasu navýšit cenu o víc než 10 % ([Finance.cz](https://www.finance.cz/clanky/266417-na-co-si-dat-pozor-v-autoservisech/), článek z 2010 – ověřit u právníka); systém bez schválení nepustí práci dál. *MVP*
- **SV.5 Plánovač dílny:** tabule podle zvedáků a mechaniků, přetahování zakázek, stavy (čeká na díl / v práci / hotovo). *MVP*
- **SV.6 Časomíra a normohodiny:** mechanik mačká start/stop v mobilu; vlastní katalog úkonů s časy, později licencovaná data výrobců (Autodata, HaynesPro). *MVP vlastní, v2 licence*
- **SV.7 Díly na zakázce:** výdej ze skladu skenem, chybějící díl se objedná z marketplace (M1.10). *MVP*
- **SV.8 Faktura a platba:** karta, QR, hotovost, převod; evidence tržeb EET 2.0 (F7.3). *MVP*
- **SV.9 Historie a připomínky:** servisní kniha vozu, automatické SMS/e-mail před STK, výměnou oleje a přezutím. *MVP*
- **SV.10 Portál zákazníka:** stav zakázky živě, fotky, faktury, historie vozu – přes odkaz, bez registrace. *v1*
- **SV.11 Náhradní vozy:** evidence zápůjček, předávací protokol, km a palivo. *v1*
- **SV.12 Záruka na opravu:** reklamace s vazbou na původní zakázku a díl, reklamace dílu u dodavatele přes M1.8. *v1*

## Modul 4: VIN – výbava, barva, historie

Jedno VIN otevře **kartu vozu**, kterou sdílí servis, sklad, ocenění i inzerce. Data skládáme z více zdrojů „vodopádem“: nejdřív levné a vlastní, placené prověrky až když je uživatel potřebuje – a výsledek se k VIN ukládá, aby se neplatilo dvakrát.

| Kód | Vrstva dat | Zdroj (návrh) | Co dává | Placení | Fáze |
| --- | --- | --- | --- | --- | --- |
| V4.1 | Dekódování VIN | [Vincario / vindecoder.eu](https://apps.make.com/vincario-vindecoder?hl=fr-FR) | značka, model, motor, převodovka, rok; u evropských aut v průměru \~40 údajů | za dotaz | MVP |
| V4.2 | Výbava a kód barvy z výroby | [DAT SilverDAT VIN](https://www.datgroup.com/products/vehicle-identification/) | tovární výbava, balíčky, typ motoru a převodovky, kód a název laku; DAT kód pokrývá i ČR | za dotaz ([DAT](https://www.dat.de/fileadmin/de/download/rechtliches/produktbeschreibung-silverdat-3-pro-english-version.pdf)) | v1 |
| V4.3 | Kontrola odcizení | Vincario | dotaz do policejních databází ČR, SK, HU, LT, RO, SI | za dotaz | MVP |
| V4.4 | Historie (km, havárie, servisy, financování) | [Cebia](https://www.cebia.cz/novinky/tiskove-zpravy/cebia-nove-umoznuje-zakladni-provereni-aut-zdarma-na-portalu-sauto) | historie km, odcizení, leasing/úvěr, taxi; plná verze i havárie, servisní záznamy, barva, výbava | B2B smlouva | MVP |
| V4.5 | Historie aut ze zahraničí | [carVertical API](https://www.carvertical.com/pl/business/api) | zprávy o historii, dovoz z USA; B2B balíčky na míru | B2B smlouva | v1 |
| V4.6 | Záznamy STK | [kontrolatachometru.cz](https://www.denik.cz/cesko/auto-rodokmen-vady-kilometry/) (MD ČR) | km a závady z prohlídek STK víc než 10 let zpětně | zdarma – **ověřit, zda existuje API** | MVP odkaz, v1 napojení |
| V4.7 | Registr vozidel ČR | [Datová kostka](https://zpravy.kurzy.cz/626964-ministerstvo-dopravy-zpristupnuje-data-z-registru-vozidel-i-udaje-o-technickych-prohlidkach) (dataovozidlech.cz) | veřejná data a statistiky z registru, export CSV | zdarma | v1 |
| V4.8 | Vlastní data platformy | AutoCore | každá zakázka a výkup = záznam km, prací a fotek k VIN | – | MVP |

- **V4.9 Karta vozu v aplikaci:** technické údaje, výbava (zaškrtávací seznam pro inzerát), kód barvy (pro objednávku laku/dílu v barvě), historie zakázek, prověrky, fotky, dokumenty. *MVP*
- **V4.10 Protokol vozu v PDF:** jedním klikem pro zákazníka nebo do inzerátu. *MVP*
- **V4.11 Přeprodej prověrek:** uživatel zaplatí prověrku přes platformu (kredit), my nakupujeme velkoobchodně – zdroj marže. *MVP*
- **V4.12 Dekódování z fotky:** OCR VIN ze štítku nebo z technického průkazu. *MVP*

## Modul 5: Kontrola km a ocenění vozu

Ocenění propojuje tři věci, které konkurence dělá zvlášť: stav z checklistu, historii z VIN a **cenu opravy spočítanou z reálných cen dílů na marketplace**. Výsledek je výkupní a prodejní cena se zdůvodněním, ne jedno číslo.

### Kontrola stočených km

Podle Cebia má stočený tachometr asi třetina ojetin v ČR ([iROZHLAS](https://www.irozhlas.cz/zpravy-tag/autobazar)) a u individuálně dovezených vozů je to častější, často ještě před první českou STK ([Cebia](https://www.cebia.cz/novinky/tiskove-zpravy/prinos-planovanych-opatreni-reseni-staceni-tachometru)).

- **K5.1 Časová osa km:** všechny záznamy z V4.4–V4.8 na jedné ose (STK, servisy, inzeráty, výkupy, záznamy v AutoCore). *MVP*
- **K5.2 Detekce anomálií:** pokles km mezi záznamy, nepřirozeně nízký roční nájezd vůči věku a typu motoru, mezera v historii, dovoz bez zahraniční historie, nesoulad km s opotřebením z checklistu (pedály, volant, sedadlo). *v1*
- **K5.3 Semafor:** zelená / oranžová / červená + vysvětlení, co přesně je podezřelé. Vždy s upozorněním, že jde o indikaci, ne znalecký posudek. *v1*
- **K5.4 Sdílená databáze km mezi uživateli:** každý servis přispívá anonymizovanými záznamy VIN + km + datum. Největší dlouhodobá výhoda platformy – **vyžaduje právní posouzení GDPR** (P14.2). *v1*

### Ocenění

- **O5.5 Vstupy:** specifikace a výbava z VIN, km, rok, stav z checklistu (body za karoserii, interiér, motor, podvozek, pneu), historie havárií, počet majitelů, původ. *v1*
- **O5.6 Srovnatelné vozy:** stejný model, motor a výbava, rok ±1, km ±20 %. Zdroje: tržní data Vincario (statistiky cen a km na trhu, [Make](https://apps.make.com/vincario-vindecoder?hl=fr-FR)), oceňovací systém Cebia ([Cebia](https://www.cebia.cz/files/analyza-vyvoje-cen-vozidel-2019.pdf)) nebo licence Eurotax; postupně i vlastní data z inzerátů na platformě. **Scrapování portálů nenavrhuji** (právní riziko a blokace). *v1*
- **O5.7 Odpočet za vady:** každá závada z checklistu se přepočte na cenu dílu z marketplace + normohodiny servisu. Bazar tak hned vidí, kolik stojí příprava vozu. *v1*
- **O5.8 Výstup:** výkupní cena, doporučená prodejní cena, odhad dnů do prodeje, seznam levnějších a dražších podobných nabídek s rozdíly ve výbavě. *v1*
- **O5.9 Ocenění pro koncového zákazníka:** widget „Kolik stojí moje auto“ na webu bazaru = generátor výkupních leadů. *v2*

## Modul 6: Autobazar – sklad vozů, inzerce, web plugin

Vůz se v systému založí jednou (při výkupu) a odtud jde na portály, na web bazaru i do kupní smlouvy – bez přepisování.

### Sklad vozů a výkup

- **B6.1 Životní cyklus vozu:** výkup → příprava → inzerce → rezervace → prodáno / vráceno; u každého vozu nákupní cena, náklady na přípravu, cílová cena, marže a dny na skladě. *MVP*
- **B6.2 Výkup v mobilu:** checklist příjmu (SV.3) + ocenění (Modul 5) + výkupní smlouva + plná moc k přepisu, podpis na tabletu. *MVP*
- **B6.3 Příprava vozu:** interní zakázka do vlastního nebo externího servisu na platformě; náklady se samy přičtou k vozu. *MVP*
- **B6.4 Komisní prodej:** vůz cizího majitele, provize, smlouva o komisi. *v1*

### Inzerce

- **B6.5 Export jedním klikem (detail A9.13–A9.16):** Sauto přes importní XML-RPC rozhraní (Seznam přidělí softwarový klíč a zapůjčí testovací účet, [Sauto](https://napoveda.seznam.cz/soubory/Sauto.cz/Importni_dokumentace_Sauto.pdf)); TipCars (s roční licencí přeposílá inzeráty na cca 30 webů, [TipCars](https://www.tipcars.com/napoveda.html)); autobazar.eu; Facebook Marketplace přes katalogový feed. Pro německý trh mobile.de – **ověřit podmínky API**. *MVP Sauto + TipCars, v1 ostatní*
- **B6.6 Fotky:** mobilní focení podle šablony úhlů (16 záběrů), automatické vyrovnání, rozmazání SPZ, logo bazaru, volitelně výměna pozadí. *MVP základ, v1 AI úpravy*
- **B6.7 AI popis inzerátu (detail A9.8–A9.12):** text z výbavy, historie a stavu; čeština v MVP, další jazyky ve v1. *MVP*
- **B6.8 Odznak prověření:** výsledek prověrky (V4.4) a km semaforu přímo v inzerátu – zvyšuje důvěru. *v1*
- **B6.9 Statistiky inzerce (detail A9.2, A9.6):** zobrazení a dotazy po portálech, cena vůči trhu, doporučení zlevnit. *v1*

### Plugin na web bazaru

- **B6.10 Tři způsoby napojení:** (a) vložení jedním řádkem `<script>` (web komponenta, převezme barvy webu); (b) plugin pro WordPress; (c) REST API + XML/JSON feed pro vlastní weby. *MVP (a), v1 (b, c)*
- **B6.11 Hostovaná stránka nabídky pro SEO:** samostatné stránky vozů na subdoméně bazaru (např. auta.bazar.cz), protože čistě JS widget Google indexuje hůř. *v1*
- **B6.12 Funkce pluginu:** filtry, detail s galerií, výbava, protokol vozu, poptávkový formulář, rezervace zkušební jízdy, kalkulačka splátek, „Kolik stojí moje auto“ (O5.9). *MVP filtry + detail + poptávka*

### Prodej

- **B6.13 Leady na jednom místě:** dotazy z portálů, webu a telefonu do CRM (F7.5) s přiřazením prodejci. *MVP*
- **B6.14 Dokumenty prodeje:** kupní smlouva, předávací protokol, faktura ve zvláštním režimu DPH pro použité zboží (F7.2), podklady k přepisu. *MVP*
- **B6.15 Financování a pojištění:** napojení na leasingové a pojišťovací partnery, provize z každé smlouvy. *v2*

## Modul 8: Prodejní analytika, AI texty a publikace na portály

Bazar na jedné obrazovce vidí, která auta se prodávají a za kolik, která mu stojí na skladě, a jedním klikem je s vygenerovaným textem pošle na všechny portály. Data o trhu jsou to nejcennější, co platforma s každým dalším bazarem nasbírá.

### Tržní dashboard

Oblíbenost měříme poptávkou (dotazy, zobrazení, dny do prodeje), ne jen tím, co je v nabídce. Trh je navíc soustředěný: deset nejprodávanějších modelů ojetin tvořilo v 1. čtvrtletí 2026 asi třetinu trhu ([Cebia](https://www.cebia.cz/novinky/tiskove-zpravy/informace-statistiky-a-zajimavosti-z-oblasti-prodeje-ojetych-vozidel-cebia-summary-1q-2026)), takže užitečný přehled dá už menší vzorek dat.

| Kód | Panel | Co ukazuje | Zdroj dat | Fáze |
| --- | --- | --- | --- | --- |
| A9.1 | Moje firma | tržby, marže na voze, obrátka skladu, výkon prodejců; u servisu vytížení dílny | data firmy | MVP |
| A9.2 | Výkon inzerátů | zobrazení, uložení, kontakty po portálech a po vozech; konverze dotaz → prodej | vlastní plugin a CRM; statistiky portálů, kde je rozhraní vydá (ověřit) | MVP web, v1 portály |
| A9.3 | Nejžádanější modely | modely seřazené podle rychlosti prodeje a počtu dotazů; filtr cena, palivo, rok, kraj | anonymizovaná data bazarů na platformě | v1 |
| A9.4 | Vývoj cen | průměrná prodejní cena a nájezd modelu v čase, trend za 3 / 6 / 12 měsíců | data platformy + tržní statistiky Vincario | v1 |
| A9.5 | Dny do prodeje | doba prodeje podle modelu, ceny a stáří; moje firma vs. trh | data platformy | v1 |
| A9.6 | Hodnocení vozu na skladě | skóre 0–100 z ceny vůči trhu, poptávky po modelu, dnů na skladě a kvality inzerátu (fotky, text) + doporučení „zlevnit o X Kč“ nebo „doplnit fotky“ | výpočet AutoCore z A9.2–A9.5 | v1 |
| A9.7 | Co vykupovat | modely, které se v kraji prodávají rychle a je jich v nabídce málo – tip pro výkup a dovoz | data platformy + statistiky registrací dovezených ojetin | v2 |

Tržní panely (A9.3–A9.7) se zapnou až při dostatku dat (návrh: 30 aktivních bazarů); data jiných firem jsou vždy jen souhrnná, nikdy jednotlivé vozy nebo ceny konkrétního bazaru (P14.11).

### AI texty k prodeji

- **A9.8 Popis inzerátu jedním klikem:** z výbavy podle VIN, historie, km semaforu a checklistu; vyzdvihne silné stránky (servisní historie, výbava), slabiny popíše pravdivě; délka a styl podle portálu. *MVP*
- **A9.9 Kontrola pravdivosti:** AI smí uvést jen to, co je v datech vozu – každá věta má zdroj (výbava, prověrka, checklist); zakázané fráze typu „nehavarované“ bez prověrky; text před zveřejněním potvrdí prodejce. *MVP*
- **A9.10 Titulek a klíčová slova:** název inzerátu a hledané pojmy, aby se vůz našel ve vyhledávání portálu. *MVP*
- **A9.11 Tón a jazyk:** věcný / prodejní / prémiový; čeština, slovenština, němčina, angličtina. *MVP čeština, v1 ostatní*
- **A9.12 Další texty:** příspěvek na sociální sítě, odpověď zájemci z portálu, nabídka podobného vozu e-mailem, text výkupní nabídky. *v1*

### Přímá publikace na portály

- **A9.13 Jedna karta, všechny portály:** zaškrtnout portály → publikovat; změna ceny, fotek nebo textu se propíše všude; po prodeji se vůz stáhne ze všech portálů najednou. *MVP*
- **A9.14 Stav a chyby:** u vozu je vidět, kde je online, odkaz na každý inzerát a srozumitelná chyba importu („chybí počet dveří“) s tím, co opravit. *MVP*
- **A9.15 Pravidla zviditelnění:** např. po 30 dnech bez dotazu navrhne topování nebo zlevnění o 3 %; vždy s potvrzením prodejce. *v1*
- **A9.16 Poptávky zpět do CRM:** dotazy z portálů (přes rozhraní, jinak z e-mailu) se přiřadí k vozu a prodejci. *MVP*

| Portál | Napojení | Fáze |
| --- | --- | --- |
| Sauto.cz | importní XML-RPC rozhraní: vložení a úprava inzerátu, topování; softwarový klíč a testovací účet od Seznamu ([Sauto](https://napoveda.seznam.cz/soubory/Sauto.cz/Importni_dokumentace_Sauto.pdf)) | MVP |
| TipCars | dealerský import; s roční licencí přeposílá na cca 30 webů ([TipCars](https://www.tipcars.com/napoveda.html)) | MVP |
| Vlastní web bazaru | plugin (B6.10) | MVP |
| autobazar.eu | dealerský import – ověřit formát | v1 |
| Facebook Marketplace | katalogový feed vozů – ověřit podmínky pro ČR | v1 |
| Bazoš, Sbazar | oficiální import ověřit; jinak připravený text a fotky ke zkopírování | v1 |
| mobile.de | rozhraní pro prodejce – ověřit podmínky | v2 |

## Modul 7: Fakturace, CRM, komunikace

EET 2.0 je pro servisy tvrdý termín: evidence tržeb startuje 1. ledna 2027, plný provoz od 1. února 2027 ([epravo.cz](https://www.epravo.cz/top/clanky/eet-20-poslanecka-snemovna-schvalila-novou-podobu-evidence-trzeb-121668.html)), a eviduje se hotovost, karta i QR platba při osobním kontaktu ([BusinessInfo](https://www.businessinfo.cz/navody/tip-pro-podnikatele-jak-na-modernizovane-eet/)). Kdo má fakturaci s EET hotovou, má prodejní argument.

- **F7.1 Doklady:** faktury, zálohy, dobropisy, účtenky, QR platba, export ISDOC. *MVP*
- **F7.2 Režimy DPH:** standardní, zvláštní režim pro použité zboží (ojeté vozy, použité díly), přenesená daňová povinnost kde platí. *MVP*
- **F7.3 EET 2.0:** odeslání tržby při platbě na pobočce, certifikát firmy, offline fronta při výpadku. *MVP – nutné k 1/2027*
- **F7.4 Platby a banka:** platební terminál / softPOS, párování plateb z banky (Fio API, další přes PSD2), upomínky. *MVP párování, v1 terminál*
- **F7.5 CRM:** zákazníci, jejich vozy, zakázky, leady z bazaru, poznámky, úkoly. *MVP*
- **F7.6 Komunikace:** SMS, e-mail, WhatsApp šablony (zakázka připravena, nabídka ke schválení, připomínka STK); automatické kampaně. *MVP SMS + e-mail*
- **F7.7 Recenze:** po předání vozu žádost o hodnocení s odkazem na Google. *v1*
- **F7.8 Účetnictví:** export do Pohody, Money S3, ABRA Flexi; doplnění firem z ARES podle IČO. *MVP export, v1 obousměrně*
- **F7.9 Oprávnění a audit:** role (R1), kdo co změnil, mazání jen stornem. *MVP*
- **F7.10 Přehledy:** tržby, marže podle mechanika, zakázky, vozy, díly. *MVP základní, v1 vlastní reporty*

## Mateřská firma a sesterský projekt

AutoCore je jeden ze dvou samostatných projektů mateřské firmy; druhým je platforma pro obce ObecHub (ObecHub – návrh platformy pro obce). Každý má vlastní značku, zákazníky a ceník.

- **H1 Sdílený základ:** přihlašování a role, fakturace předplatného, SMS a e-mail, úložiště souborů, monitoring, design systém a hosting v EU; data projektů jsou oddělená.
- **H2 Sdílený tým a provoz:** vývoj, podpora, účetnictví, jedna sada směrnic pro GDPR a bezpečnost.
- **H3 Jediný styčný bod:** obce mohou přes ObecHub objednávat opravy svých vozů u servisů v AutoCore a nabízet vyřazené vozy bazarům.

## Integrace a datové zdroje

Každá integrace je samostatný adaptér za jednotným rozhraním, takže dodavatele dat lze vyměnit bez zásahu do modulů. Ceny placených zdrojů jsou smluvní – před MVP je potřeba získat nabídky (otevřená otázka Q3).

| Oblast | Zdroj | Přístup | Fáze |
| --- | --- | --- | --- |
| Katalog dílů | TecDoc (TecAlliance) | komerční licence, API | MVP |
| Nové díly – ceny, sklad, objednávky | Inter Cars; vyjednat Auto Kelly, LKQ, Elit | API / CSV ceníky | MVP (1–2) |
| Použité díly | vlastní nahrávání; partnersky Ovoko | REST API | v1 |
| Dekódování VIN, odcizení, tržní ceny | Vincario (vindecoder.eu) | API, za dotaz | MVP |
| Výbava a lak z výroby | DAT SilverDAT | licence, za dotaz | v1 |
| Historie vozu ČR | Cebia | B2B smlouva | MVP |
| Historie vozu zahraničí | carVertical | B2B API | v1 |
| STK a registr | kontrolatachometru.cz, Datová kostka MD | web / CSV, API ověřit | v1 |
| Inzerce | Sauto (XML-RPC), TipCars, autobazar.eu, mobile.de | import API / feed | MVP Sauto + TipCars |
| Evidence tržeb | EET 2.0 (Finanční správa) | povinné rozhraní | MVP |
| Platby | Stripe Connect / GoPay / Comgate; Fio API | API | MVP banka, v1 tržiště |
| Účetnictví | Pohoda, Money S3, ABRA Flexi | export / API | MVP export |
| Firmy | ARES | veřejné API | MVP |
| Doprava | PPL, DPD, Zásilkovna | API | MVP |
| SMS a e-mail | SMS brána, transakční e-mail | API | MVP |
| Normohodiny a postupy | Autodata / HaynesPro | licence | v2 |

## Technická architektura

Jedna aplikace, jedna databáze s oddělením firem a samostatná integrační vrstva: žádný modul nevolá Cebia ani Sauto přímo, takže výměna dodavatele dat neznamená přepisovat moduly.

*(Diagram architektury: klienti – web aplikace, PWA, plugin, portál zákazníka, API partnerů → moduly → integrační vrstva s adaptéry → externí služby. Aktuální technické rozhodnutí je v CLAUDE.md.)*

- **T12.1 Frontend:** React 18 + TypeScript + Vite + Tailwind; tablet a mobil jako PWA (fotoaparát, offline fronta při výpadku signálu v dílně), nativní aplikace (Expo) až když bude potřeba skener na pozadí. *MVP*
- **T12.2 Backend:** Node.js + TypeScript (NestJS), REST + WebSocket pro živé stavy zakázek a plánovač dílny. *MVP*
- **T12.3 Data:** PostgreSQL s řádkovým zabezpečením podle firmy (např. Supabase v regionu EU), Redis na cache a fronty, úložiště fotek kompatibilní s S3, Meilisearch pro rychlé vyhledávání dílů. *MVP*
- **T12.4 Plugin:** samostatný balíček (web komponenta) z CDN nad veřejným API nabídky vozů; WordPress plugin je jen obal. *MVP*
- **T12.5 Provoz a bezpečnost:** hosting v EU, denní zálohy, šifrování, 2FA, auditní log, cíl dostupnosti 99,5 %. *MVP*
- **T12.6 AI funkce:** OCR SPZ a VIN, čtení dodacích listů, popisy inzerátů – přes externí jazykový model s oddělením dat firem. *v1*
- **T12.7 Veřejné API pro partnery:** OAuth, webhooky, dokumentace. *v2*

## Ceník a monetizace

Návrh cen je výchozí hypotéza k ověření v rozhovorech se zákazníky (fáze 0), ne finální ceník. Pro první produkt platí ceník bazarů podle počtu vozů ve specifikaci AutoCore Bazar. Částky v Kč bez DPH.

| Tarif | Pro koho | Obsah | Cena / měsíc |
| --- | --- | --- | --- |
| Start | servis do 3 zvedáků nebo bazar do 20 vozů, 2 uživatelé | servis nebo bazar, sklad, faktury s EET, marketplace | 990 Kč |
| Profi | do 10 uživatelů | vše z B2B, export na portály, web plugin, CRM automatizace | 2 490 Kč |
| Kombi | více poboček, bazar + servis | vše + API, vlastní doména pluginu, prioritní podpora | od 5 990 Kč |

**Transakční příjmy:**

- **P13.1** Provize z prodeje použitých dílů: 8–12 % z ceny, platí prodávající. *v1*
- **P13.2** Nové díly přes vlastní účet zákazníka u velkoobchodu: 0 % pro servis; vyjednat partnerskou provizi 1–3 % od dodavatele. *MVP*
- **P13.3** Prověrky vozů (Cebia, carVertical, DAT): prodej kreditů s marží 20–40 %. *MVP*
- **P13.4** Provize z financování a pojištění vozů prodaných přes bazar. *v2*
- **P13.5** Zkušební verze 30 dní zdarma, bez karty; roční platba se slevou 2 měsíce. *MVP*

## Právo a compliance

Nejsem právník – body níže jsou seznam témat, která musí před spuštěním projít advokát; nejvíc práce je kolem tržiště a sdílení dat.

- **P14.1 GDPR:** AutoCore je zpracovatel dat zákazníků servisů a bazarů → smlouva o zpracování s každou firmou; fotky SPZ a osob, doba uchování, export a výmaz dat.
- **P14.2 Sdílená databáze km (K5.4):** posoudit, zda VIN + km + datum jsou osobní údaj, a nastavit anonymizaci a souhlas v obchodních podmínkách.
- **P14.3 Provozovatel tržiště:** povinnosti online platforem podle nařízení o digitálních službách (DSA) a P2B nařízení – ověření prodejců (IČO, kontakt), pravidla řazení nabídek, řešení stížností.
- **P14.4 Peníze přes platformu:** AutoCore nesmí sám držet cizí peníze bez licence → výplaty prodejcům přes platební instituci (Stripe Connect, GoPay, Comgate).
- **P14.5 EET 2.0 a DPH:** správná evidence tržeb, zvláštní režim DPH u ojetin a použitých dílů.
- **P14.6 Licence dat:** TecDoc, DAT, Cebia, carVertical mají omezení, komu a jak se data smí zobrazit – hlídat při přeprodeji prověrek a v pluginu na webu bazaru.
- **P14.7 Odpovědnost za ocenění a km:** výsledky jen jako indikace s jasným upozorněním, omezení odpovědnosti v podmínkách.
- **P14.8 Smluvní dokumenty:** obchodní podmínky, SLA dostupnosti, vzory zakázkového listu, výkupní a kupní smlouvy – ověřené advokátem.
- **P14.10 Značka:** rešerše a registrace ochranné známky a domény pro finální název.
- **P14.11 Tržní data (A9.3–A9.7):** v podmínkách souhlas firem se souhrnným využitím jejich prodejních dat; nikdy nezveřejňovat údaje jednoho bazaru; ověřit soutěžní právo (sdílení cen mezi konkurenty).

## Roadmapa

Navrhuji ověřit zájem dřív, než vznikne první řádek kódu: fáze 0 trvá dva měsíce a končí třemi platícími piloty. Termíny počítají s týmem 2–3 vývojářů; podle odpovědi na Q4 je posunu.

*(Původní roadmapa se servisem v MVP – nahrazena roadmapou bazar-first v bazar-specifikace.md.)*

Platí roadmapa bazar-first ze specifikace AutoCore Bazar; diagram výše je původní varianta se servisem v MVP. Bez splněné brány se nepřidávají nové moduly – místo toho se upravuje produkt pro stávající zákazníky. MVP v lednu nestihne start EET 2.0; první servisy proto do nasazení používají svou pokladnu.

## Rizika a otevřené otázky

Největší riziko je rozsah: celý systém je práce na 2–3 roky týmu, proto MVP stojí na servisu a bazaru a marketplace začíná jako agregátor.

| Riziko | Dopad | Opatření |
| --- | --- | --- |
| Ceny placených dat (Cebia, DAT, carVertical) sníží marži | vysoký | vodopád zdrojů, ukládání výsledků k VIN, prověrky placené kredity |
| Velkoobchody nedají API novému hráči | vysoký | začít s Inter Cars (API veřejně nabízí), jinde CSV ceníky; přivést jim zákazníky jako argument |
| Prázdné tržiště použitých dílů | střední | nejdřív SaaS nástroj pro servisy, tržiště až s uživateli; import skladů vrakovišť |
| Konkurence: zavedené dealerské systémy (např. [CARIS DMS](https://www.teas.cz/carisdms.html) s příjmem na tabletu), Ovoko, TipCars | střední | „vše v jednom“ + VIN, km a ocenění s cenou opravy, které nikdo nespojuje |
| Termín EET 2.0 (1/2027) | střední | pokud MVP nestihne leden, servis do té doby používá svou pokladnu, migrace při nasazení |
| Právo kolem tržiště a sdílení km | střední | advokát před spuštěním v1, anonymizace |

**Otázky pro tebe** (odpověz komentářem):

- **Q1 Název a doména:** AutoCore se kvůli kolizi s autocore.io měnit bude; nový název doplníme později.
- **Q2 Na koho cílit první:** **rozhodnuto – autobazary, servis a díly později (specifikace AutoCore Bazar)**.
- **Q3 Rozpočet na data:** kolik jsi ochoten dát měsíčně za licence (TecDoc, Cebia, Vincario) před prvními zákazníky?
- **Q4 Tým:** programuješ sám, nebo s kým? Podle toho upravím rozsah MVP.
- **Q5 Trhy:** jen ČR, nebo hned SK a DE (němčina, mobile.de)?
- **Q6 Financování:** vlastní zdroje, investor, nebo dotace?
- **Q7 Marketplace:** souhlasíš s modelem agregátor (MVP) → provizní tržiště (v1)?

## Checklist ke schválení

Odškrtni, co platí; k bodu s výhradou napiš komentář a přepracuji ho.

- [ ] **Cílové skupiny a role** (C1–C5, R1–R2)
- [ ] **M1 Marketplace:** agregátor velkoobchodů v MVP, provizní tržiště použitých dílů ve v1 (M1.1–M1.10)
- [ ] **S2 Sklad** propojený se zakázkami a marketplace (S2.1–S2.10)
- [ ] **SV Servis:** proces podle diagramu, digitální schválení nabídky (SV.1–SV.12)
- [ ] **V4 VIN:** vodopád zdrojů Vincario → Cebia → DAT → carVertical, ukládání k VIN (V4.1–V4.12)
- [ ] **K5 Kontrola km:** časová osa, detekce anomálií, semafor, sdílená databáze km (K5.1–K5.4)
- [ ] **O5 Ocenění** s odpočtem ceny opravy z marketplace (O5.5–O5.9)
- [ ] **B6 Autobazar:** sklad vozů, výkup, export Sauto + TipCars, plugin `<script>` + WordPress + API (B6.1–B6.15)
- [ ] **A9 Prodejní analytika:** tržní dashboard a hodnocení vozů, AI texty s kontrolou pravdivosti, publikace na Sauto, TipCars a další portály jedním klikem (A9.1–A9.16)
- [ ] **F7 Fakturace a CRM** včetně EET 2.0 (F7.1–F7.10)
- [ ] **Integrace** podle tabulky
- [ ] **Architektura a technologie** podle diagramu
- [ ] **Ceník:** 990 / 2 490 / od 5 990 Kč (pro bazary platí ceník S / M / L / Síť ve specifikaci AutoCore Bazar); provize 8–12 % (P13.1–P13.5)
- [ ] **Právní body** předat advokátovi (P14.1–P14.8, P14.10–P14.11)
- [ ] **Roadmapa** fáze 0 → MVP → v1 → v2
- [ ] **Odpovědi na Q1–Q7**

Po schválení připravím: datový model (tabulky a vztahy), seznam obrazovek MVP s wireframy a backlog úkolů pro vývoj.

## Zdroje

- [Inter Cars – API pro klienty](https://intercars.com/en/business-solutions-inter-cars/business-services/software/api-and-csv-client-inter-cars)
- [TecDoc – licence a integrace (dev-opla)](https://dev-opla.com/resources/what-is-tecdoc-auto-parts-ecommerce-guide)
- [Ovoko REST API (Packagist)](https://packagist.org/packages/andyts93/laravel-ovoko)
- [Vincario VIN Decoder (Make)](https://apps.make.com/vincario-vindecoder?hl=fr-FR)
- [DAT – identifikace vozidla podle VIN](https://www.datgroup.com/products/vehicle-identification/)
- [DAT – popis produktu SilverDAT 3 Pro](https://www.dat.de/fileadmin/de/download/rechtliches/produktbeschreibung-silverdat-3-pro-english-version.pdf)
- [Cebia – základní prověření na Sauto](https://www.cebia.cz/novinky/tiskove-zpravy/cebia-nove-umoznuje-zakladni-provereni-aut-zdarma-na-portalu-sauto)
- [Cebia – stáčení tachometrů a STK](https://www.cebia.cz/novinky/tiskove-zpravy/prinos-planovanych-opatreni-reseni-staceni-tachometru)
- [Cebia – analýza vývoje cen vozidel 2019](https://www.cebia.cz/files/analyza-vyvoje-cen-vozidel-2019.pdf)
- [carVertical – API pro firmy](https://www.carvertical.com/pl/business/api)
- [Deník – záznamy STK na kontrolatachometru.cz](https://www.denik.cz/cesko/auto-rodokmen-vady-kilometry/)
- [Kurzy.cz – MD zpřístupňuje data z registru vozidel](https://zpravy.kurzy.cz/626964-ministerstvo-dopravy-zpristupnuje-data-z-registru-vozidel-i-udaje-o-technickych-prohlidkach)
- [Sauto – importní dokumentace](https://napoveda.seznam.cz/soubory/Sauto.cz/Importni_dokumentace_Sauto.pdf)
- [TipCars – nápověda](https://www.tipcars.com/napoveda.html)
- [iROZHLAS – autobazary](https://www.irozhlas.cz/zpravy-tag/autobazar)
- [epravo.cz – EET 2.0 termíny](https://www.epravo.cz/top/clanky/eet-20-poslanecka-snemovna-schvalila-novou-podobu-evidence-trzeb-121668.html)
- [BusinessInfo – EET 2.0](https://www.businessinfo.cz/navody/tip-pro-podnikatele-jak-na-modernizovane-eet/)
- [TN.cz – zakázkový list](https://tn.nova.cz/magazin/auta/novinky/poradna-10-rad-jak-predejit-problemum-v-autoservisech.html)
- [Finance.cz – navýšení ceny v servisu](https://www.finance.cz/clanky/266417-na-co-si-dat-pozor-v-autoservisech/)
- [TEAS – CARIS DMS](https://www.teas.cz/carisdms.html)
