# Bazar platforma (pracovní název)

Systém pro autobazary: vůz se zadá jednou při výkupu a odtud jde do přípravy, na Sauto, TipCars a web bazaru i do kupní smlouvy a faktury. Název produktu zatím není – je na jednom místě v `packages/brand/brand.ts`.

## Co je v repu teď

| Cesta | Obsah |
| --- | --- |
| `CLAUDE.md` | kontext a pravidla pro Claude Code (stack, struktura, konvence) |
| `docs/spec/` | specifikace produktu (bazar, MVP rozsah, F&I) a širší návrh platformy |
| `docs/prompts/` | 12 navazujících promptů pro Claude Code + prompt pro Lovable – začni `00-README.md` |
| `docs/integration-contract.md` | jak spolu mluví aplikace, plugin a prezentační web |
| `docs/data-model.md` | přehled tabulek a sloupců (generovaný) |
| `docs/design-system.md` | barvy, písmo, komponenty, tón |
| `supabase/migrations/` | výchozí SQL schéma s RLS (otestované) |
| `packages/brand/` | název, design tokeny, Tailwind preset |

## Jak začít

1. Otevři repo v Claude Code.
2. Napiš: `Přečti docs/prompts/01-bootstrap.md a proveď tuto fázi.`
3. Po schválení PR pokračuj další fází v nové konverzaci – pořadí a závislosti jsou v `docs/prompts/00-README.md`.
4. Prezentační web postav v Lovable podle `docs/prompts/lovable-web.md` (samostatné repo `bazar_web`).
