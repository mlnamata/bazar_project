# Průběh

| Fáze | Stav | Datum | Poznámka |
| --- | --- | --- | --- |
| 00 Podklady | hotovo | 2026-10-27 | specifikace, SQL schéma (otestované v PostgreSQL 16 se stubem Supabase auth: izolace firem, historie stavů, marže, číselné řady), design tokeny, kontrakt, prompty |
| 01 Bootstrap | – | | |
| 02 Databáze | – | | |
| 03 Kostra aplikace | – | | |
| 04 Sklad a karta vozu | – | | |
| 05 Výkup, VIN, prověrka | – | | |
| 06 Příprava a fotky | – | | |
| 07 Inzerce a publikace | – | | |
| 08 Leady, prodej, doklady | – | | |
| 09 Plugin | – | | |
| 10 F&I kalkulačka | – | | |
| 11 Přehledy a nastavení | – | | |
| 12 QA a nasazení | – | | |
| Lovable web | – | | |

## Otevřené otázky

- Název produktu a doména (placeholder v `packages/brand/brand.ts`).
- Logo.
- QB1–QB7 ze specifikace (piloti, velikost bazarů, území, dovoz, tým a termín, ceník, značka) – prompty počítají s výchozími hodnotami ze specifikace.
- Dokumentace importu Sauto a TipCars a testovací přístupy (fáze 07).
- Smlouvy s Vincario a Cebia (fáze 05 běží na mocích).
- Advokát: šablony dokumentů D1–D8, odpovědnost za vady, F&I registrace, GDPR.
