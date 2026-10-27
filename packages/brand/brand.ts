/**
 * JEDINÉ místo, kde je název produktu.
 * Až bude název vybraný, změň hodnoty tady (a stejné hodnoty v prompts/lovable-web.md).
 * Nikde jinde v kódu se název nesmí psát natvrdo – vždy import { BRAND } from '@bazar/brand'.
 */
export const BRAND = {
  name: 'NÁZEV',                 // zobrazovaný název, např. "Najeto"
  legalName: 'NÁZEV s.r.o.',     // provozovatel (mateřská firma)
  slug: 'nazev',                 // malými písmeny bez diakritiky – prefixy, localStorage klíče
  domain: 'nazev.cz',            // prezentační web (Lovable)
  appUrl: 'https://app.nazev.cz',
  cdnUrl: 'https://cdn.nazev.cz',
  supportEmail: 'podpora@nazev.cz',
  supportPhone: '+420 000 000 000',
  widgetTag: 'bazar-nabidka',    // název web komponenty pluginu (musí obsahovat pomlčku)
  tagline: 'Vůz zadáte jednou. Prodá se všude.',
} as const;

export type Brand = typeof BRAND;
