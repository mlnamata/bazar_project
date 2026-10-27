# Datový model

Generováno ze `supabase/migrations/*.sql` skriptem `scripts/gen-data-model.py` – needituj ručně. Všechny firemní tabulky mají `company_id` a RLS: člen firmy čte a zapisuje, maže jen majitel; prodej a faktury nevidí role výkupčí; přístupy k portálům jen majitel.

## Výčty

| Typ | Hodnoty |
| --- | --- |
| `member_role` | owner, sales, buyer, accountant |
| `plan_tier` | trial, S, M, L, network |
| `vehicle_status` | buyout, preparation, ready, advertised, reserved, sold, returned, written_off |
| `fuel_type` | petrol, diesel, lpg, cng, hybrid, plugin_hybrid, electric, other |
| `transmission_type` | manual, automatic |
| `body_type` | hatchback, sedan, combi, suv, mpv, coupe, cabrio, pickup, van, other |
| `vat_mode` | margin, standard |
| `cost_category` | preparation, repair, transport, stk, vehicle_check, advertising, commission, other |
| `task_status` | todo, doing, done |
| `document_type` | tp_small, tp_big, coc, service_book, stk, buyout_contract, power_of_attorney, sale_contract, handover_protocol, test_drive_consent, invoice, vehicle_report, check_report, other |
| `vin_provider` | vincario, cebia, carvertical, dat, manual, mock |
| `vin_report_kind` | decode, stolen, history, equipment |
| `job_status` | queued, running, done, failed |
| `mileage_source` | buyout, stk, vehicle_check, service, listing, sale, manual |
| `checklist_kind` | buyout, pre_sale |
| `customer_type` | person, company |
| `lead_source` | web, qr, sauto, tipcars, phone, email, walk_in, finance, other |
| `lead_status` | new, contacted, viewing, offer, won, lost |
| `payment_method` | cash, card, transfer, financing |
| `sale_status` | draft, signed, completed, cancelled |
| `invoice_type` | invoice, proforma, credit_note |
| `channel` | web, sauto, tipcars |
| `listing_status` | draft, queued, live, error, removed |
| `publication_action` | upsert, remove |
| `finance_product` | consumer_loan, finance_lease, operating_lease, balloon_loan |
| `finance_status` | new, sent, approved, rejected, signed, cancelled |
| `message_channel` | sms, email |

## Firma, pobočky, uživatelé

### `companies`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `name` | `text not null` |  |
| `ico` | `text check (ico ~ '^[0-9]{8}$')` |  |
| `dic` | `text` |  |
| `vat_payer` | `boolean not null default true` |  |
| `street` | `text` |  |
| `city` | `text` |  |
| `zip` | `text` |  |
| `email` | `citext` |  |
| `phone` | `text` |  |
| `website` | `text` |  |
| `logo_path` | `text` |  |
| `plan` | `plan_tier not null default 'trial'` |  |
| `vehicle_limit` | `integer not null default 20` | podle tarifu: S 20, M 60, L 150 |
| `trial_ends_at` | `timestamptz default now() + interval '30 days'` |  |
| `public_key` | `text not null unique default encode(gen_random_bytes(12), 'hex')` | identifikace pro plugin a QR |
| `is_demo` | `boolean not null default false` |  |
| `settings` | `jsonb not null default '{}'::jsonb` | barvy pluginu, texty, výchozí záruka atd. |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

### `branches`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `name` | `text not null` |  |
| `street` | `text` |  |
| `city` | `text` |  |
| `zip` | `text` |  |
| `phone` | `text` |  |
| `email` | `citext` |  |
| `opening_hours` | `jsonb not null default '{}'::jsonb` |  |
| `is_default` | `boolean not null default false` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `profiles`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key references auth.users(id) on delete cascade` |  |
| `full_name` | `text` |  |
| `phone` | `text` |  |
| `avatar_path` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `memberships`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `user_id` | `uuid not null references auth.users(id) on delete cascade` |  |
| `role` | `member_role not null` |  |
| `branch_id` | `uuid references branches(id) on delete set null` |  |
| `commission_pct` | `numeric(5,2)` | provize prodejce z marže (BZN.7, v1) |
| `active` | `boolean not null default true` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `number_series`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `kind` | `text not null` | 'invoice', 'sale_contract', 'buyout_contract', 'stock' |
| `year` | `integer not null` |  |
| `prefix` | `text not null default ''` |  |
| `next_value` | `integer not null default 1` |  |

## Zákazníci

### `customers`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `type` | `customer_type not null default 'person'` |  |
| `first_name` | `text` |  |
| `last_name` | `text` |  |
| `company_name` | `text` |  |
| `ico` | `text` |  |
| `dic` | `text` |  |
| `email` | `citext` |  |
| `phone` | `text` |  |
| `street` | `text` |  |
| `city` | `text` |  |
| `zip` | `text` |  |
| `birth_date` | `date` | jen kvůli smlouvám |
| `id_document_number` | `text` | jen kvůli smlouvám, mazat podle retenční lhůty |
| `marketing_consent` | `boolean not null default false` |  |
| `marketing_consent_at` | `timestamptz` |  |
| `note` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

## Vozy

### `vehicles`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `branch_id` | `uuid references branches(id) on delete set null` |  |
| `stock_no` | `text` | skladové číslo bazaru |
| `status` | `vehicle_status not null default 'buyout'` |  |
| `status_changed_at` | `timestamptz not null default now()` |  |
| `vin` | `text check (vin is null or vin ~ '^[A-HJ-NPR-Z0-9]{17}$')` |  |
| `plate` | `text` |  |
| `make` | `text not null` |  |
| `model` | `text not null` |  |
| `variant` | `text` | např. 2.0 TDI Style |
| `body` | `body_type` |  |
| `fuel` | `fuel_type` |  |
| `transmission` | `transmission_type` |  |
| `drive` | `text` | 4x2 / 4x4 |
| `engine_ccm` | `integer` |  |
| `power_kw` | `integer` |  |
| `year` | `smallint check (year between 1950 and 2100)` |  |
| `first_registration` | `date` |  |
| `mileage_km` | `integer check (mileage_km >= 0)` |  |
| `color_name` | `text` |  |
| `color_code` | `text` |  |
| `doors` | `smallint` |  |
| `seats` | `smallint` |  |
| `emission_class` | `text` |  |
| `origin_country` | `text default 'CZ'` |  |
| `imported` | `boolean not null default false` |  |
| `owners_count` | `smallint` |  |
| `stk_valid_until` | `date` |  |
| `service_book` | `boolean` |  |
| `equipment` | `text[] not null default '{}'` | kódy výbavy (katalog v aplikaci) |
| `equipment_raw` | `jsonb` | surová data z dekodéru |
| `condition_note` | `text` |  |
| `known_defects` | `text` | přechází do kupní smlouvy |
| `purchase_price` | `numeric(12,2)` |  |
| `purchase_vat_mode` | `vat_mode not null default 'margin'` |  |
| `target_price` | `numeric(12,2)` |  |
| `min_price` | `numeric(12,2)` |  |
| `list_price` | `numeric(12,2)` | inzerovaná cena |
| `sale_vat_mode` | `vat_mode not null default 'margin'` |  |
| `sold_price` | `numeric(12,2)` |  |
| `bought_at` | `timestamptz default now()` |  |
| `sold_at` | `timestamptz` |  |
| `title` | `text` |  |
| `description` | `text` |  |
| `is_public` | `boolean not null default false` | zobrazit v pluginu |
| `verified` | `boolean not null default false` | odznak prověření (prověrka bez nálezu) |
| `slug` | `text` |  |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |
| `deleted_at` | `timestamptz` |  |

### `vehicle_status_history`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `bigint generated always as identity primary key` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `from_status` | `vehicle_status` |  |
| `to_status` | `vehicle_status not null` |  |
| `changed_by` | `uuid references auth.users(id)` |  |
| `changed_at` | `timestamptz not null default now()` |  |
| `note` | `text` |  |

### `vehicle_costs`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `task_id` | `uuid` |  |
| `category` | `cost_category not null` |  |
| `description` | `text` |  |
| `supplier` | `text` |  |
| `amount` | `numeric(12,2) not null` | bez DPH |
| `vat_rate` | `numeric(4,2) not null default 21` |  |
| `incurred_at` | `date not null default current_date` |  |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `vehicle_tasks`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `title` | `text not null` |  |
| `supplier` | `text` |  |
| `assignee_id` | `uuid references auth.users(id)` |  |
| `cost_estimate` | `numeric(12,2)` |  |
| `status` | `task_status not null default 'todo'` |  |
| `due_date` | `date` |  |
| `done_at` | `timestamptz` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `vehicle_photos`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `storage_path` | `text not null` | bucket vehicle-photos: {company_id}/{vehicle_id}/{uuid}.webp |
| `position` | `smallint not null default 0` |  |
| `angle` | `text` | front_left, rear, interior_dash, … (šablona 16 záběrů) |
| `width` | `integer` |  |
| `height` | `integer` |  |
| `plate_blurred` | `boolean not null default false` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `vehicle_documents`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete cascade` |  |
| `customer_id` | `uuid references customers(id) on delete set null` |  |
| `type` | `document_type not null` |  |
| `number` | `text` |  |
| `storage_path` | `text not null` | bucket documents (soukromý) |
| `generated` | `boolean not null default false` |  |
| `signed_at` | `timestamptz` |  |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

## VIN, prověrky, km, checklisty

### `vin_reports`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete set null` |  |
| `vin` | `text not null` |  |
| `provider` | `vin_provider not null` |  |
| `kind` | `vin_report_kind not null` |  |
| `status` | `job_status not null default 'queued'` |  |
| `result` | `jsonb` |  |
| `findings_count` | `integer` | počet nálezů (havárie, stočení, odcizení…) |
| `report_url` | `text` |  |
| `cost` | `numeric(10,2)` |  |
| `error` | `text` |  |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `mileage_records`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete cascade` |  |
| `vin` | `text not null` |  |
| `recorded_on` | `date not null` |  |
| `mileage_km` | `integer not null check (mileage_km >= 0)` |  |
| `source` | `mileage_source not null` |  |
| `source_ref` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `checklist_templates`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid references companies(id) on delete cascade` | null = systémová šablona |
| `kind` | `checklist_kind not null` |  |
| `name` | `text not null` |  |
| `items` | `jsonb not null` | [{key, group, label, needs_photo, measure: 'mm'|null}] |
| `active` | `boolean not null default true` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `inspections`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `template_id` | `uuid references checklist_templates(id)` |  |
| `kind` | `checklist_kind not null` |  |
| `results` | `jsonb not null default '[]'::jsonb` | [{key, state: ok|warn|fail, note, value, photo_paths[]}] |
| `mileage_km` | `integer` |  |
| `fuel_level_pct` | `smallint` |  |
| `completed` | `boolean not null default false` |  |
| `performed_by` | `uuid references auth.users(id)` |  |
| `performed_at` | `timestamptz not null default now()` |  |

## Leady, zkušební jízdy

### `leads`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete set null` |  |
| `customer_id` | `uuid references customers(id) on delete set null` |  |
| `source` | `lead_source not null` |  |
| `status` | `lead_status not null default 'new'` |  |
| `assigned_to` | `uuid references auth.users(id)` |  |
| `name` | `text` |  |
| `email` | `citext` |  |
| `phone` | `text` |  |
| `message` | `text` |  |
| `wants_test_drive` | `boolean not null default false` |  |
| `preferred_time` | `timestamptz` |  |
| `lost_reason` | `text` |  |
| `utm` | `jsonb` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

### `lead_events`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `bigint generated always as identity primary key` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `lead_id` | `uuid not null references leads(id) on delete cascade` |  |
| `type` | `text not null` | note, call, email, sms, status_change |
| `body` | `text` |  |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `test_drives`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `customer_id` | `uuid references customers(id) on delete set null` |  |
| `lead_id` | `uuid references leads(id) on delete set null` |  |
| `salesperson_id` | `uuid references auth.users(id)` |  |
| `scheduled_at` | `timestamptz` |  |
| `started_at` | `timestamptz` |  |
| `ended_at` | `timestamptz` |  |
| `mileage_start` | `integer` |  |
| `mileage_end` | `integer` |  |
| `fuel_start_pct` | `smallint` |  |
| `fuel_end_pct` | `smallint` |  |
| `licence_photo_path` | `text` |  |
| `consent_document_id` | `uuid references vehicle_documents(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

## Výkup, prodej, faktury

### `sales`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id)` |  |
| `customer_id` | `uuid not null references customers(id)` |  |
| `salesperson_id` | `uuid references auth.users(id)` |  |
| `status` | `sale_status not null default 'draft'` |  |
| `price` | `numeric(12,2) not null` |  |
| `vat_mode` | `vat_mode not null default 'margin'` |  |
| `trade_in_value` | `numeric(12,2)` | protiúčet (BZ2.3) |
| `deposit` | `numeric(12,2)` |  |
| `payment_method` | `payment_method not null default 'transfer'` |  |
| `warranty_months` | `smallint not null default 24 check (warranty_months in (12, 24))` | u spotřebitele lze dohodou zkrátit na 12 |
| `known_defects` | `text` |  |
| `contract_number` | `text` |  |
| `contract_document_id` | `uuid references vehicle_documents(id)` |  |
| `handover_document_id` | `uuid references vehicle_documents(id)` |  |
| `transfer_checklist` | `jsonb not null default '{}'::jsonb` | přepis: {tp_handed: true, ...} |
| `signed_at` | `timestamptz` |  |
| `handed_over_at` | `timestamptz` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

### `buyouts`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `seller_customer_id` | `uuid references customers(id)` |  |
| `buyer_user_id` | `uuid references auth.users(id)` | výkupčí |
| `offered_price` | `numeric(12,2)` |  |
| `agreed_price` | `numeric(12,2)` |  |
| `valuation` | `jsonb` | {comparables:[...], prep_estimate, recommended_buy, expected_margin} |
| `is_trade_in` | `boolean not null default false` |  |
| `sale_id` | `uuid references sales(id) on delete set null` | prodej, ve kterém je protiúčet |
| `contract_number` | `text` |  |
| `contract_document_id` | `uuid references vehicle_documents(id)` |  |
| `poa_document_id` | `uuid references vehicle_documents(id)` |  |
| `payment_method` | `payment_method` |  |
| `signed_at` | `timestamptz` |  |
| `paid_at` | `timestamptz` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `invoices`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `number` | `text not null` |  |
| `type` | `invoice_type not null default 'invoice'` |  |
| `customer_id` | `uuid references customers(id)` |  |
| `sale_id` | `uuid references sales(id) on delete set null` |  |
| `vat_mode` | `vat_mode not null` |  |
| `issued_on` | `date not null default current_date` |  |
| `taxable_supply_on` | `date not null default current_date` |  |
| `due_on` | `date not null default current_date + 14` |  |
| `variable_symbol` | `text` |  |
| `currency` | `char(3) not null default 'CZK'` |  |
| `total_without_vat` | `numeric(12,2) not null default 0` |  |
| `vat_total` | `numeric(12,2) not null default 0` |  |
| `total` | `numeric(12,2) not null default 0` |  |
| `paid_at` | `timestamptz` |  |
| `document_id` | `uuid references vehicle_documents(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `invoice_items`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `invoice_id` | `uuid not null references invoices(id) on delete cascade` |  |
| `position` | `smallint not null default 0` |  |
| `description` | `text not null` |  |
| `quantity` | `numeric(10,2) not null default 1` |  |
| `unit_price` | `numeric(12,2) not null` | u zvláštního režimu cena včetně, DPH se nevyčísluje |
| `vat_rate` | `numeric(4,2) not null default 21` |  |

## Inzerce a publikace

### `channel_accounts`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `channel` | `channel not null` |  |
| `login` | `text` |  |
| `secret_id` | `uuid` | odkaz do Supabase Vault, heslo nikdy v tabulce |
| `dealer_ref` | `text` |  |
| `active` | `boolean not null default true` |  |
| `last_check_at` | `timestamptz` |  |
| `last_error` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `listings`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `channel` | `channel not null` |  |
| `status` | `listing_status not null default 'draft'` |  |
| `external_id` | `text` |  |
| `external_url` | `text` |  |
| `payload_hash` | `text` | hash posledních odeslaných dat (nic se neposílá zbytečně) |
| `last_synced_at` | `timestamptz` |  |
| `last_error` | `text` | srozumitelná chyba pro uživatele |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

### `publication_jobs`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `bigint generated always as identity primary key` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `listing_id` | `uuid not null references listings(id) on delete cascade` |  |
| `action` | `publication_action not null` |  |
| `status` | `job_status not null default 'queued'` |  |
| `attempts` | `smallint not null default 0` |  |
| `run_after` | `timestamptz not null default now()` |  |
| `error` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `finished_at` | `timestamptz` |  |

### `ai_texts`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid not null references vehicles(id) on delete cascade` |  |
| `kind` | `text not null` | description, title, keywords, social |
| `channel` | `channel` |  |
| `language` | `char(2) not null default 'cs'` |  |
| `tone` | `text not null default 'factual'` | factual, sales, premium |
| `content` | `text not null` |  |
| `sources` | `jsonb not null default '[]'::jsonb` | [{sentence, facts:[...]}] – kontrola pravdivosti |
| `model` | `text` |  |
| `approved_by` | `uuid references auth.users(id)` |  |
| `approved_at` | `timestamptz` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `web_events`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `bigint generated always as identity primary key` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete set null` |  |
| `event` | `text not null` | list_view, detail_view, contact_click, lead_submit, calc_open |
| `session_id` | `text` |  |
| `referrer` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |

## F&I (MVP: kalkulačka + poptávka)

### `finance_partners`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `name` | `text not null` |  |
| `kind` | `text not null` | credit, leasing, insurance, warranty |
| `products` | `finance_product[] not null default '{}'` |  |
| `calc_params` | `jsonb not null default '{}'::jsonb` | {apr_from, rate, min_term, max_term, min_down_pct, max_age_years} |
| `request_email` | `citext` |  |
| `active` | `boolean not null default true` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `company_finance_partners`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `partner_id` | `uuid not null references finance_partners(id) on delete cascade` |  |
| `enabled` | `boolean not null default true` |  |
| `cnb_registered_until` | `date` | FI.32: bez platné registrace nelze nabízet |
| `calc_override` | `jsonb` |  |

### `finance_requests`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `vehicle_id` | `uuid references vehicles(id) on delete set null` |  |
| `lead_id` | `uuid references leads(id) on delete set null` |  |
| `customer_id` | `uuid references customers(id) on delete set null` |  |
| `partner_id` | `uuid references finance_partners(id)` |  |
| `product` | `finance_product not null default 'consumer_loan'` |  |
| `vehicle_price` | `numeric(12,2) not null` |  |
| `down_payment` | `numeric(12,2) not null default 0` |  |
| `term_months` | `smallint not null` |  |
| `monthly_estimate` | `numeric(12,2)` |  |
| `status` | `finance_status not null default 'new'` |  |
| `partner_ref` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |
| `updated_at` | `timestamptz not null default now()` |  |

## Komunikace, importy, šablony, audit

### `outbound_messages`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `channel` | `message_channel not null` |  |
| `recipient` | `text not null` |  |
| `template` | `text` |  |
| `body` | `text not null` |  |
| `lead_id` | `uuid references leads(id) on delete set null` |  |
| `customer_id` | `uuid references customers(id) on delete set null` |  |
| `status` | `job_status not null default 'queued'` |  |
| `provider_ref` | `text` |  |
| `error` | `text` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `imports`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid not null references companies(id) on delete cascade` |  |
| `kind` | `text not null default 'vehicles_csv'` |  |
| `status` | `job_status not null default 'queued'` |  |
| `file_path` | `text` |  |
| `column_map` | `jsonb` |  |
| `stats` | `jsonb` | {rows, created, updated, skipped, photos} |
| `errors` | `jsonb` | [{row, message}] |
| `created_by` | `uuid references auth.users(id)` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `document_templates`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_id` | `uuid references companies(id) on delete cascade` | null = systémová šablona schválená advokátem |
| `type` | `document_type not null` |  |
| `name` | `text not null` |  |
| `body_html` | `text not null` | Handlebars šablona |
| `version` | `integer not null default 1` |  |
| `active` | `boolean not null default true` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `audit_log`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `bigint generated always as identity primary key` |  |
| `company_id` | `uuid` |  |
| `actor_id` | `uuid` |  |
| `table_name` | `text not null` |  |
| `record_id` | `text` |  |
| `action` | `text not null` | INSERT, UPDATE, DELETE |
| `diff` | `jsonb` |  |
| `created_at` | `timestamptz not null default now()` |  |

### `platform_signups`

| Sloupec | Typ | Poznámka |
| --- | --- | --- |
| `id` | `uuid primary key default gen_random_uuid()` |  |
| `company_name` | `text not null` |  |
| `ico` | `text` |  |
| `contact_name` | `text not null` |  |
| `email` | `citext not null` |  |
| `phone` | `text` |  |
| `vehicles_in_stock` | `integer` |  |
| `region` | `text` |  |
| `message` | `text` |  |
| `wants_pilot` | `boolean not null default true` |  |
| `source` | `text not null default 'web'` |  |
| `utm` | `jsonb` |  |
| `status` | `text not null default 'new'` | new, contacted, demo, pilot, rejected |
| `created_at` | `timestamptz not null default now()` |  |

## Pohledy a funkce

- `vehicle_economics` – náklady, celková cena, marže a dny na skladě pro každý vůz.
- `is_member(company_id)`, `has_role(company_id, roles)` – základ RLS.
- `create_company(name, ico)` – onboarding: firma + výchozí pobočka + členství majitele.
- `next_number(company_id, kind)` – číselné řady bez děr (faktury, smlouvy), formát `RRRRNNNN` s prefixem.
- Triggery: `updated_at`, historie stavů vozu, audit log (vozy, prodeje, výkupy, faktury, zákazníci, členství).

