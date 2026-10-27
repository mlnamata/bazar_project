#!/usr/bin/env python3
"""Vygeneruje docs/data-model.md ze všech SQL migrací (spouští `pnpm db:docs`)."""
import glob, re

sql = '\n'.join(open(f).read() for f in sorted(glob.glob('supabase/migrations/*.sql')))
groups = re.findall(r'-- -{60,}\n-- (.+?)\n-- -{60,}\n(.*?)(?=\n-- -{60,}|\Z)', sql, re.S)
out = ["# Datový model", "",
       "Generováno ze `supabase/migrations/*.sql` skriptem `scripts/gen-data-model.py` – needituj ručně. "
       "Všechny firemní tabulky mají `company_id` a RLS: člen firmy čte a zapisuje, maže jen majitel; "
       "prodej a faktury nevidí role výkupčí; přístupy k portálům jen majitel.", ""]
out.append("## Výčty\n\n| Typ | Hodnoty |\n| --- | --- |")
for name, vals in re.findall(r"create type (\w+)\s+as enum \(([^)]*)\)", sql):
    vals = ' '.join(vals.replace("'", '').split())
    out.append(f"| `{name}` | {vals.replace(',', ', ').replace(' ,', ',').replace(',  ', ', ')} |")
out.append("")
for title, body in groups:
    tables = re.findall(r'create table (\w+) \((.*?)\n\);', body, re.S)
    if not tables:
        continue
    out.append(f"## {title}\n")
    for name, cols in tables:
        out.append(f"### `{name}`\n\n| Sloupec | Typ | Poznámka |\n| --- | --- | --- |")
        for line in cols.split('\n'):
            line = line.strip()
            if not line or line.startswith(('primary key', 'unique', '--')):
                continue
            m = re.match(r'(\w+)\s+(.+?)(?:,\s*)?(?:--\s*(.*))?$', line)
            if m:
                typ = ' '.join(m.group(2).rstrip(',').split())
                out.append(f"| `{m.group(1)}` | `{typ}` | {m.group(3) or ''} |")
        out.append("")
out.append('''## Pohledy a funkce

- `vehicle_economics` – náklady, celková cena, marže a dny na skladě pro každý vůz.
- `is_member(company_id)`, `has_role(company_id, roles)` – základ RLS.
- `create_company(name, ico)` – onboarding: firma + výchozí pobočka + členství majitele.
- `next_number(company_id, kind)` – číselné řady bez děr (faktury, smlouvy), formát `RRRRNNNN` s prefixem.
- Triggery: `updated_at`, historie stavů vozu, audit log (vozy, prodeje, výkupy, faktury, zákazníci, členství).
''')
open('docs/data-model.md', 'w').write('\n'.join(out) + '\n')
print('docs/data-model.md aktualizován')
