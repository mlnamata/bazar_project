# Fáze 10 – Kalkulačka splátek a poptávka financování (F&I MVP)

## Kontext

Přečti `CLAUDE.md`; ve specifikaci modul **F&I** – pro MVP jen **FI.5** a **FI.8 (poptávka k 1 partnerovi)**, pravidla **FI.1–FI.3** a **FI.32** jako omezení; v datovém modelu `finance_partners`, `company_finance_partners`, `finance_requests`. Ostatní body F&I (balíčky, pojištění, záruky, více partnerů, podpis) jsou v1 – **nestav je**, ale navrhni datový model tak, aby šly doplnit.

## Cíl

U každého vozu (karta, plugin, inzerát) je vidět orientační měsíční splátka se zákonnými údaji a zákazník nebo prodejce pošle poptávku financování partnerovi, kterého má bazar aktivního.

## Postup

1. **Výpočty v `packages/shared/src/finance.ts`** (čisté funkce, 100% pokrytí testy):
   - anuitní splátka z ceny, akontace, doby a úrokové sazby (měsíční složení),
   - RPSN z peněžních toků včetně poplatků (iterativně, Newton–Raphson s ošetřením nekonvergence), celková částka splatná spotřebitelem,
   - balónová splátka (parametr, pro v1 – připrav funkci, v UI nepoužívej),
   - zaokrouhlení na celé Kč nahoru u splátky, RPSN na 2 desetinná místa,
   - **reprezentativní příklad** jako text generovaný z parametrů partnera („Výše úvěru 250 000 Kč, doba 60 měsíců, úroková sazba 9,9 % p. a., RPSN 10,9 %, měsíční splátka 5 300 Kč, celková splatná částka 318 000 Kč.“) – formulaci nech ve `finance-texts.ts` k revizi advokátem.
2. **Pravidla zobrazení:** kalkulačka se zobrazí jen když firma má aktivního partnera s platnou registrací (`cnb_registered_until >= today`, FI.32), vůz splňuje jeho podmínky (max. stáří, min. cena) a firma ji v nastavení nevypnula. Jinak se splátka nikde neukazuje.
3. **UI:**
   - **karta vozu a obrazovka Prodej:** panel Financování – posuvníky akontace (0–50 %) a doby (12–84 měs. podle partnera), splátka, RPSN, celková částka, reprezentativní příklad; tlačítko „Poslat poptávku“ (vybere / vytvoří zákazníka z leadu),
   - **plugin:** na kartě „od X Kč/měs.“ (výchozí akontace a doba z nastavení), v detailu interaktivní kalkulačka a formulář typu `finance` (kontrakt sekce 4); `calc_open` událost,
   - **inzerát:** fáze 07 přidá větu se splátkou a reprezentativním příkladem do textu pro web a TipCars, je-li zapnuto (Sauto jen pokud to jeho podmínky dovolují – ověř).
4. **Poptávka (FI.8 základ):** `finance_requests` (stav `new` → `sent`), adaptér `finance/` – mock zapíše e-mail do `outbound_messages`, real pošle strukturovaný e-mail partnerovi (`finance_partners.request_email`) s údaji o voze a zákazníkovi a se souhlasem zákazníka; v kartě vozu a leadu je vidět stav poptávky, prodejce ho ručně mění (Schváleno / Zamítnuto / Podepsáno).
5. **Nastavení (`/nastaveni/firma/financovani`, jen majitel):** aktivní partneři z katalogu, registrace u ČNB do (datum + upozornění 30 dní před koncem), vlastní parametry kalkulace (pokud je partner povoluje), výchozí akontace a doba pro plugin, zapnout/vypnout zobrazení.

## Akceptační kritéria

- [ ] Výpočet splátky a RPSN sedí na 3 ručně ověřených příkladech (tabulka v testu) s tolerancí 0,01 %.
- [ ] Bez platné registrace se splátka nezobrazí v aplikaci, pluginu ani inzerátu (test).
- [ ] Poptávka z pluginu vytvoří lead typu finance, `finance_requests` a e-mail partnerovi (mock).
- [ ] Reprezentativní příklad je u každé zobrazené splátky.

## Na konci

`docs/progress.md`, větev `phase/10-fi`, PR.
