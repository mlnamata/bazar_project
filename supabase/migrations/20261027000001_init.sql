-- =====================================================================
-- Bazar platforma – výchozí schéma (MVP)
-- Supabase / PostgreSQL 15+
-- Konvence:
--   * každá firemní tabulka má company_id a RLS přes is_member()
--   * peníze numeric(12,2) v Kč, km integer, časy timestamptz
--   * názvy tabulek a sloupců anglicky, texty pro uživatele česky v aplikaci
-- =====================================================================

create extension if not exists pgcrypto;
create extension if not exists citext;

-- ---------------------------------------------------------------------
-- Výčty
-- ---------------------------------------------------------------------
create type member_role       as enum ('owner', 'sales', 'buyer', 'accountant');
create type plan_tier         as enum ('trial', 'S', 'M', 'L', 'network');
create type vehicle_status    as enum ('buyout', 'preparation', 'ready', 'advertised', 'reserved', 'sold', 'returned', 'written_off');
create type fuel_type         as enum ('petrol', 'diesel', 'lpg', 'cng', 'hybrid', 'plugin_hybrid', 'electric', 'other');
create type transmission_type as enum ('manual', 'automatic');
create type body_type         as enum ('hatchback', 'sedan', 'combi', 'suv', 'mpv', 'coupe', 'cabrio', 'pickup', 'van', 'other');
create type vat_mode          as enum ('margin', 'standard');   -- zvláštní režim pro použité zboží / běžné DPH
create type cost_category     as enum ('preparation', 'repair', 'transport', 'stk', 'vehicle_check', 'advertising', 'commission', 'other');
create type task_status       as enum ('todo', 'doing', 'done');
create type document_type     as enum ('tp_small', 'tp_big', 'coc', 'service_book', 'stk', 'buyout_contract', 'power_of_attorney',
                                       'sale_contract', 'handover_protocol', 'test_drive_consent', 'invoice', 'vehicle_report', 'check_report', 'other');
create type vin_provider      as enum ('vincario', 'cebia', 'carvertical', 'dat', 'manual', 'mock');
create type vin_report_kind   as enum ('decode', 'stolen', 'history', 'equipment');
create type job_status        as enum ('queued', 'running', 'done', 'failed');
create type mileage_source    as enum ('buyout', 'stk', 'vehicle_check', 'service', 'listing', 'sale', 'manual');
create type checklist_kind    as enum ('buyout', 'pre_sale');
create type customer_type     as enum ('person', 'company');
create type lead_source       as enum ('web', 'qr', 'sauto', 'tipcars', 'phone', 'email', 'walk_in', 'finance', 'other');
create type lead_status       as enum ('new', 'contacted', 'viewing', 'offer', 'won', 'lost');
create type payment_method    as enum ('cash', 'card', 'transfer', 'financing');
create type sale_status       as enum ('draft', 'signed', 'completed', 'cancelled');
create type invoice_type      as enum ('invoice', 'proforma', 'credit_note');
create type channel           as enum ('web', 'sauto', 'tipcars');            -- další portály přibydou ve v1
create type listing_status    as enum ('draft', 'queued', 'live', 'error', 'removed');
create type publication_action as enum ('upsert', 'remove');
create type finance_product   as enum ('consumer_loan', 'finance_lease', 'operating_lease', 'balloon_loan');
create type finance_status    as enum ('new', 'sent', 'approved', 'rejected', 'signed', 'cancelled');
create type message_channel   as enum ('sms', 'email');

-- ---------------------------------------------------------------------
-- Pomocné funkce
-- ---------------------------------------------------------------------
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------------
-- Firma, pobočky, uživatelé
-- ---------------------------------------------------------------------
create table companies (
  id                 uuid primary key default gen_random_uuid(),
  name               text not null,
  ico                text check (ico ~ '^[0-9]{8}$'),
  dic                text,
  vat_payer          boolean not null default true,
  street             text,
  city               text,
  zip                text,
  email              citext,
  phone              text,
  website            text,
  logo_path          text,
  plan               plan_tier not null default 'trial',
  vehicle_limit      integer not null default 20,          -- podle tarifu: S 20, M 60, L 150
  trial_ends_at      timestamptz default now() + interval '30 days',
  public_key         text not null unique default encode(gen_random_bytes(12), 'hex'),  -- identifikace pro plugin a QR
  is_demo            boolean not null default false,
  settings           jsonb not null default '{}'::jsonb,   -- barvy pluginu, texty, výchozí záruka atd.
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table branches (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  name               text not null,
  street             text,
  city               text,
  zip                text,
  phone              text,
  email              citext,
  opening_hours      jsonb not null default '{}'::jsonb,
  is_default         boolean not null default false,
  created_at         timestamptz not null default now()
);
create unique index branches_one_default on branches(company_id) where is_default;

create table profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  full_name          text,
  phone              text,
  avatar_path        text,
  created_at         timestamptz not null default now()
);

create table memberships (
  company_id         uuid not null references companies(id) on delete cascade,
  user_id            uuid not null references auth.users(id) on delete cascade,
  role               member_role not null,
  branch_id          uuid references branches(id) on delete set null,
  commission_pct     numeric(5,2),                         -- provize prodejce z marže (BZN.7, v1)
  active             boolean not null default true,
  created_at         timestamptz not null default now(),
  primary key (company_id, user_id)
);
create index memberships_user on memberships(user_id);

-- Je přihlášený uživatel aktivním členem firmy? (používá RLS)
create or replace function is_member(cid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from memberships m
    where m.company_id = cid and m.user_id = auth.uid() and m.active
  );
$$;

-- Má uživatel ve firmě jednu z rolí?
create or replace function has_role(cid uuid, roles member_role[]) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from memberships m
    where m.company_id = cid and m.user_id = auth.uid() and m.active and m.role = any(roles)
  );
$$;

-- Číselné řady (faktury, smlouvy) – bez děr, po letech
create table number_series (
  company_id         uuid not null references companies(id) on delete cascade,
  kind               text not null,                        -- 'invoice', 'sale_contract', 'buyout_contract', 'stock'
  year               integer not null,
  prefix             text not null default '',
  next_value         integer not null default 1,
  primary key (company_id, kind, year)
);

create or replace function next_number(cid uuid, k text) returns text
language plpgsql security definer set search_path = public as $$
declare
  y int := extract(year from now())::int;
  v int;
  p text;
begin
  if not is_member(cid) and auth.role() <> 'service_role' then
    raise exception 'not a member';
  end if;
  insert into number_series(company_id, kind, year) values (cid, k, y)
    on conflict (company_id, kind, year) do nothing;
  update number_series set next_value = next_value + 1
    where company_id = cid and kind = k and year = y
    returning next_value - 1, prefix into v, p;
  return p || y::text || lpad(v::text, 4, '0');
end $$;

-- ---------------------------------------------------------------------
-- Zákazníci
-- ---------------------------------------------------------------------
create table customers (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  type               customer_type not null default 'person',
  first_name         text,
  last_name          text,
  company_name       text,
  ico                text,
  dic                text,
  email              citext,
  phone              text,
  street             text,
  city               text,
  zip                text,
  birth_date         date,                                 -- jen kvůli smlouvám
  id_document_number text,                                 -- jen kvůli smlouvám, mazat podle retenční lhůty
  marketing_consent  boolean not null default false,
  marketing_consent_at timestamptz,
  note               text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index customers_company on customers(company_id);
create index customers_phone on customers(company_id, phone);
create index customers_email on customers(company_id, email);

-- ---------------------------------------------------------------------
-- Vozy
-- ---------------------------------------------------------------------
create table vehicles (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  branch_id          uuid references branches(id) on delete set null,
  stock_no           text,                                 -- skladové číslo bazaru
  status             vehicle_status not null default 'buyout',
  status_changed_at  timestamptz not null default now(),
  vin                text check (vin is null or vin ~ '^[A-HJ-NPR-Z0-9]{17}$'),
  plate              text,
  make               text not null,
  model              text not null,
  variant            text,                                 -- např. 2.0 TDI Style
  body               body_type,
  fuel               fuel_type,
  transmission       transmission_type,
  drive              text,                                 -- 4x2 / 4x4
  engine_ccm         integer,
  power_kw           integer,
  year               smallint check (year between 1950 and 2100),
  first_registration date,
  mileage_km         integer check (mileage_km >= 0),
  color_name         text,
  color_code         text,
  doors              smallint,
  seats              smallint,
  emission_class     text,
  origin_country     text default 'CZ',
  imported           boolean not null default false,
  owners_count       smallint,
  stk_valid_until    date,
  service_book       boolean,
  equipment          text[] not null default '{}',         -- kódy výbavy (katalog v aplikaci)
  equipment_raw      jsonb,                                -- surová data z dekodéru
  condition_note     text,
  known_defects      text,                                 -- přechází do kupní smlouvy
  -- ekonomika
  purchase_price     numeric(12,2),
  purchase_vat_mode  vat_mode not null default 'margin',
  target_price       numeric(12,2),
  min_price          numeric(12,2),
  list_price         numeric(12,2),                        -- inzerovaná cena
  sale_vat_mode      vat_mode not null default 'margin',
  sold_price         numeric(12,2),
  bought_at          timestamptz default now(),
  sold_at            timestamptz,
  -- inzerce
  title              text,
  description        text,
  is_public          boolean not null default false,       -- zobrazit v pluginu
  verified           boolean not null default false,       -- odznak prověření (prověrka bez nálezu)
  slug               text,
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  deleted_at         timestamptz
);
create index vehicles_company_status on vehicles(company_id, status) where deleted_at is null;
create index vehicles_vin on vehicles(vin);
create unique index vehicles_stock_no on vehicles(company_id, stock_no) where stock_no is not null;

create table vehicle_status_history (
  id                 bigint generated always as identity primary key,
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  from_status        vehicle_status,
  to_status          vehicle_status not null,
  changed_by         uuid references auth.users(id),
  changed_at         timestamptz not null default now(),
  note               text
);

-- BEFORE: časová razítka stavu
create or replace function stamp_vehicle_status() returns trigger
language plpgsql as $$
begin
  if tg_op = 'INSERT' or new.status is distinct from old.status then
    new.status_changed_at := now();
    if new.status = 'sold' and new.sold_at is null then new.sold_at := now(); end if;
  end if;
  return new;
end $$;

-- AFTER: historie stavů (řádek vozu už existuje, cizí klíč projde)
create or replace function log_vehicle_status() returns trigger
language plpgsql as $$
begin
  if tg_op = 'INSERT' or new.status is distinct from old.status then
    insert into vehicle_status_history(company_id, vehicle_id, from_status, to_status, changed_by)
      values (new.company_id, new.id, case when tg_op = 'UPDATE' then old.status end, new.status, auth.uid());
  end if;
  return null;
end $$;

create table vehicle_costs (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  task_id            uuid,
  category           cost_category not null,
  description        text,
  supplier           text,
  amount             numeric(12,2) not null,               -- bez DPH
  vat_rate           numeric(4,2) not null default 21,
  incurred_at        date not null default current_date,
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now()
);
create index vehicle_costs_vehicle on vehicle_costs(vehicle_id);

create table vehicle_tasks (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  title              text not null,
  supplier           text,
  assignee_id        uuid references auth.users(id),
  cost_estimate      numeric(12,2),
  status             task_status not null default 'todo',
  due_date           date,
  done_at            timestamptz,
  created_at         timestamptz not null default now()
);
create index vehicle_tasks_vehicle on vehicle_tasks(vehicle_id);
alter table vehicle_costs add constraint vehicle_costs_task_fk foreign key (task_id) references vehicle_tasks(id) on delete set null;

create table vehicle_photos (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  storage_path       text not null,                        -- bucket vehicle-photos: {company_id}/{vehicle_id}/{uuid}.webp
  position           smallint not null default 0,
  angle              text,                                 -- front_left, rear, interior_dash, … (šablona 16 záběrů)
  width              integer,
  height             integer,
  plate_blurred      boolean not null default false,
  created_at         timestamptz not null default now()
);
create index vehicle_photos_vehicle on vehicle_photos(vehicle_id, position);

create table vehicle_documents (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete cascade,
  customer_id        uuid references customers(id) on delete set null,
  type               document_type not null,
  number             text,
  storage_path       text not null,                        -- bucket documents (soukromý)
  generated          boolean not null default false,
  signed_at          timestamptz,
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now()
);
create index vehicle_documents_vehicle on vehicle_documents(vehicle_id);

-- ---------------------------------------------------------------------
-- VIN, prověrky, km, checklisty
-- ---------------------------------------------------------------------
create table vin_reports (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete set null,
  vin                text not null,
  provider           vin_provider not null,
  kind               vin_report_kind not null,
  status             job_status not null default 'queued',
  result             jsonb,
  findings_count     integer,                              -- počet nálezů (havárie, stočení, odcizení…)
  report_url         text,
  cost               numeric(10,2),
  error              text,
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now()
);
create index vin_reports_vin on vin_reports(company_id, vin, kind, created_at desc);

create table mileage_records (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete cascade,
  vin                text not null,
  recorded_on        date not null,
  mileage_km         integer not null check (mileage_km >= 0),
  source             mileage_source not null,
  source_ref         text,
  created_at         timestamptz not null default now()
);
create index mileage_records_vin on mileage_records(vin, recorded_on);

create table checklist_templates (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid references companies(id) on delete cascade,   -- null = systémová šablona
  kind               checklist_kind not null,
  name               text not null,
  items              jsonb not null,                       -- [{key, group, label, needs_photo, measure: 'mm'|null}]
  active             boolean not null default true,
  created_at         timestamptz not null default now()
);

create table inspections (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  template_id        uuid references checklist_templates(id),
  kind               checklist_kind not null,
  results            jsonb not null default '[]'::jsonb,   -- [{key, state: ok|warn|fail, note, value, photo_paths[]}]
  mileage_km         integer,
  fuel_level_pct     smallint,
  completed          boolean not null default false,
  performed_by       uuid references auth.users(id),
  performed_at       timestamptz not null default now()
);
create index inspections_vehicle on inspections(vehicle_id);

-- ---------------------------------------------------------------------
-- Leady, zkušební jízdy
-- ---------------------------------------------------------------------
create table leads (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete set null,
  customer_id        uuid references customers(id) on delete set null,
  source             lead_source not null,
  status             lead_status not null default 'new',
  assigned_to        uuid references auth.users(id),
  name               text,
  email              citext,
  phone              text,
  message            text,
  wants_test_drive   boolean not null default false,
  preferred_time     timestamptz,
  lost_reason        text,
  utm                jsonb,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index leads_company_status on leads(company_id, status, created_at desc);

create table lead_events (
  id                 bigint generated always as identity primary key,
  company_id         uuid not null references companies(id) on delete cascade,
  lead_id            uuid not null references leads(id) on delete cascade,
  type               text not null,                        -- note, call, email, sms, status_change
  body               text,
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now()
);
create index lead_events_lead on lead_events(lead_id, created_at);

create table test_drives (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  customer_id        uuid references customers(id) on delete set null,
  lead_id            uuid references leads(id) on delete set null,
  salesperson_id     uuid references auth.users(id),
  scheduled_at       timestamptz,
  started_at         timestamptz,
  ended_at           timestamptz,
  mileage_start      integer,
  mileage_end        integer,
  fuel_start_pct     smallint,
  fuel_end_pct       smallint,
  licence_photo_path text,
  consent_document_id uuid references vehicle_documents(id),
  created_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Výkup, prodej, faktury
-- ---------------------------------------------------------------------
create table sales (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id),
  customer_id        uuid not null references customers(id),
  salesperson_id     uuid references auth.users(id),
  status             sale_status not null default 'draft',
  price              numeric(12,2) not null,
  vat_mode           vat_mode not null default 'margin',
  trade_in_value     numeric(12,2),                        -- protiúčet (BZ2.3)
  deposit            numeric(12,2),
  payment_method     payment_method not null default 'transfer',
  warranty_months    smallint not null default 24 check (warranty_months in (12, 24)),  -- u spotřebitele lze dohodou zkrátit na 12
  known_defects      text,
  contract_number    text,
  contract_document_id uuid references vehicle_documents(id),
  handover_document_id uuid references vehicle_documents(id),
  transfer_checklist jsonb not null default '{}'::jsonb,   -- přepis: {tp_handed: true, ...}
  signed_at          timestamptz,
  handed_over_at     timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create unique index sales_one_active_per_vehicle on sales(vehicle_id) where status <> 'cancelled';

create table buyouts (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  seller_customer_id uuid references customers(id),
  buyer_user_id      uuid references auth.users(id),      -- výkupčí
  offered_price      numeric(12,2),
  agreed_price       numeric(12,2),
  valuation          jsonb,                                -- {comparables:[...], prep_estimate, recommended_buy, expected_margin}
  is_trade_in        boolean not null default false,
  sale_id            uuid references sales(id) on delete set null,   -- prodej, ve kterém je protiúčet
  contract_number    text,
  contract_document_id uuid references vehicle_documents(id),
  poa_document_id    uuid references vehicle_documents(id),
  payment_method     payment_method,
  signed_at          timestamptz,
  paid_at            timestamptz,
  created_at         timestamptz not null default now()
);
create index buyouts_vehicle on buyouts(vehicle_id);

create table invoices (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  number             text not null,
  type               invoice_type not null default 'invoice',
  customer_id        uuid references customers(id),
  sale_id            uuid references sales(id) on delete set null,
  vat_mode           vat_mode not null,
  issued_on          date not null default current_date,
  taxable_supply_on  date not null default current_date,
  due_on             date not null default current_date + 14,
  variable_symbol    text,
  currency           char(3) not null default 'CZK',
  total_without_vat  numeric(12,2) not null default 0,
  vat_total          numeric(12,2) not null default 0,
  total              numeric(12,2) not null default 0,
  paid_at            timestamptz,
  document_id        uuid references vehicle_documents(id),
  created_at         timestamptz not null default now(),
  unique (company_id, number)
);

create table invoice_items (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  invoice_id         uuid not null references invoices(id) on delete cascade,
  position           smallint not null default 0,
  description        text not null,
  quantity           numeric(10,2) not null default 1,
  unit_price         numeric(12,2) not null,               -- u zvláštního režimu cena včetně, DPH se nevyčísluje
  vat_rate           numeric(4,2) not null default 21
);

-- ---------------------------------------------------------------------
-- Inzerce a publikace
-- ---------------------------------------------------------------------
create table channel_accounts (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  channel            channel not null,
  login              text,
  secret_id          uuid,                                 -- odkaz do Supabase Vault, heslo nikdy v tabulce
  dealer_ref         text,
  active             boolean not null default true,
  last_check_at      timestamptz,
  last_error         text,
  created_at         timestamptz not null default now(),
  unique (company_id, channel)
);

create table listings (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  channel            channel not null,
  status             listing_status not null default 'draft',
  external_id        text,
  external_url       text,
  payload_hash       text,                                 -- hash posledních odeslaných dat (nic se neposílá zbytečně)
  last_synced_at     timestamptz,
  last_error         text,                                 -- srozumitelná chyba pro uživatele
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (vehicle_id, channel)
);

create table publication_jobs (
  id                 bigint generated always as identity primary key,
  company_id         uuid not null references companies(id) on delete cascade,
  listing_id         uuid not null references listings(id) on delete cascade,
  action             publication_action not null,
  status             job_status not null default 'queued',
  attempts           smallint not null default 0,
  run_after          timestamptz not null default now(),
  error              text,
  created_at         timestamptz not null default now(),
  finished_at        timestamptz
);
create index publication_jobs_queue on publication_jobs(status, run_after) where status in ('queued', 'failed');

create table ai_texts (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid not null references vehicles(id) on delete cascade,
  kind               text not null,                        -- description, title, keywords, social
  channel            channel,
  language           char(2) not null default 'cs',
  tone               text not null default 'factual',      -- factual, sales, premium
  content            text not null,
  sources            jsonb not null default '[]'::jsonb,   -- [{sentence, facts:[...]}] – kontrola pravdivosti
  model              text,
  approved_by        uuid references auth.users(id),
  approved_at        timestamptz,
  created_at         timestamptz not null default now()
);

-- Měření pluginu (A9.2) – bez osobních údajů
create table web_events (
  id                 bigint generated always as identity primary key,
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete set null,
  event              text not null,                        -- list_view, detail_view, contact_click, lead_submit, calc_open
  session_id         text,
  referrer           text,
  created_at         timestamptz not null default now()
);
create index web_events_company on web_events(company_id, created_at desc);

-- ---------------------------------------------------------------------
-- F&I (MVP: kalkulačka + poptávka)
-- ---------------------------------------------------------------------
create table finance_partners (
  id                 uuid primary key default gen_random_uuid(),
  name               text not null,
  kind               text not null,                        -- credit, leasing, insurance, warranty
  products           finance_product[] not null default '{}',
  calc_params        jsonb not null default '{}'::jsonb,   -- {apr_from, rate, min_term, max_term, min_down_pct, max_age_years}
  request_email      citext,
  active             boolean not null default true,
  created_at         timestamptz not null default now()
);

create table company_finance_partners (
  company_id         uuid not null references companies(id) on delete cascade,
  partner_id         uuid not null references finance_partners(id) on delete cascade,
  enabled            boolean not null default true,
  cnb_registered_until date,                               -- FI.32: bez platné registrace nelze nabízet
  calc_override      jsonb,
  primary key (company_id, partner_id)
);

create table finance_requests (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  vehicle_id         uuid references vehicles(id) on delete set null,
  lead_id            uuid references leads(id) on delete set null,
  customer_id        uuid references customers(id) on delete set null,
  partner_id         uuid references finance_partners(id),
  product            finance_product not null default 'consumer_loan',
  vehicle_price      numeric(12,2) not null,
  down_payment       numeric(12,2) not null default 0,
  term_months        smallint not null,
  monthly_estimate   numeric(12,2),
  status             finance_status not null default 'new',
  partner_ref        text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Komunikace, importy, šablony, audit
-- ---------------------------------------------------------------------
create table outbound_messages (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  channel            message_channel not null,
  recipient          text not null,
  template           text,
  body               text not null,
  lead_id            uuid references leads(id) on delete set null,
  customer_id        uuid references customers(id) on delete set null,
  status             job_status not null default 'queued',
  provider_ref       text,
  error              text,
  created_at         timestamptz not null default now()
);

create table imports (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid not null references companies(id) on delete cascade,
  kind               text not null default 'vehicles_csv',
  status             job_status not null default 'queued',
  file_path          text,
  column_map         jsonb,
  stats              jsonb,                                -- {rows, created, updated, skipped, photos}
  errors             jsonb,                                -- [{row, message}]
  created_by         uuid references auth.users(id),
  created_at         timestamptz not null default now()
);

create table document_templates (
  id                 uuid primary key default gen_random_uuid(),
  company_id         uuid references companies(id) on delete cascade,   -- null = systémová šablona schválená advokátem
  type               document_type not null,
  name               text not null,
  body_html          text not null,                        -- Handlebars šablona
  version            integer not null default 1,
  active             boolean not null default true,
  created_at         timestamptz not null default now()
);

create table audit_log (
  id                 bigint generated always as identity primary key,
  company_id         uuid,
  actor_id           uuid,
  table_name         text not null,
  record_id          text,
  action             text not null,                        -- INSERT, UPDATE, DELETE
  diff               jsonb,
  created_at         timestamptz not null default now()
);
create index audit_log_company on audit_log(company_id, created_at desc);

create or replace function audit_row() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  rec jsonb := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  diff jsonb;
begin
  if tg_op = 'UPDATE' then
    select jsonb_object_agg(n.key, n.value) into diff
    from jsonb_each(to_jsonb(new)) n
    where n.value is distinct from (to_jsonb(old) -> n.key) and n.key <> 'updated_at';
  else
    diff := rec;
  end if;
  insert into audit_log(company_id, actor_id, table_name, record_id, action, diff)
  values ((rec ->> 'company_id')::uuid, auth.uid(), tg_table_name, rec ->> 'id', tg_op, diff);
  return null;
end $$;

-- Registrace z prezentačního webu (Lovable) – zapisuje jen edge funkce
create table platform_signups (
  id                 uuid primary key default gen_random_uuid(),
  company_name       text not null,
  ico                text,
  contact_name       text not null,
  email              citext not null,
  phone              text,
  vehicles_in_stock  integer,
  region             text,
  message            text,
  wants_pilot        boolean not null default true,
  source             text not null default 'web',
  utm                jsonb,
  status             text not null default 'new',          -- new, contacted, demo, pilot, rejected
  created_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Pohled pro přehled skladu (ekonomika vozu)
-- ---------------------------------------------------------------------
create or replace view vehicle_economics with (security_invoker = true) as
select
  v.id as vehicle_id,
  v.company_id,
  v.status,
  v.purchase_price,
  coalesce(c.costs, 0)                                   as costs_total,
  coalesce(v.purchase_price, 0) + coalesce(c.costs, 0)   as total_cost,
  coalesce(v.sold_price, v.list_price)                   as revenue,
  coalesce(v.sold_price, v.list_price) - (coalesce(v.purchase_price, 0) + coalesce(c.costs, 0)) as margin,
  extract(day from coalesce(v.sold_at, now()) - v.bought_at)::int as days_in_stock
from vehicles v
left join (
  select vehicle_id, sum(amount) as costs from vehicle_costs group by vehicle_id
) c on c.vehicle_id = v.id
where v.deleted_at is null;

-- ---------------------------------------------------------------------
-- Triggery
-- ---------------------------------------------------------------------
create trigger companies_updated   before update on companies  for each row execute function set_updated_at();
create trigger customers_updated   before update on customers  for each row execute function set_updated_at();
create trigger vehicles_updated    before update on vehicles   for each row execute function set_updated_at();
create trigger leads_updated       before update on leads      for each row execute function set_updated_at();
create trigger sales_updated       before update on sales      for each row execute function set_updated_at();
create trigger listings_updated    before update on listings   for each row execute function set_updated_at();
create trigger finance_req_updated before update on finance_requests for each row execute function set_updated_at();
create trigger vehicles_status_stamp before insert or update of status on vehicles for each row execute function stamp_vehicle_status();
create trigger vehicles_status_log   after insert or update of status on vehicles for each row execute function log_vehicle_status();

create trigger audit_vehicles  after insert or update or delete on vehicles  for each row execute function audit_row();
create trigger audit_sales     after insert or update or delete on sales     for each row execute function audit_row();
create trigger audit_buyouts   after insert or update or delete on buyouts   for each row execute function audit_row();
create trigger audit_invoices  after insert or update or delete on invoices  for each row execute function audit_row();
create trigger audit_customers after insert or update or delete on customers for each row execute function audit_row();
create trigger audit_members   after insert or update or delete on memberships for each row execute function audit_row();

-- ---------------------------------------------------------------------
-- Založení firmy novým uživatelem (onboarding)
-- ---------------------------------------------------------------------
create or replace function create_company(p_name text, p_ico text default null) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  cid uuid;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  insert into companies(name, ico) values (p_name, p_ico) returning id into cid;
  insert into branches(company_id, name, is_default) values (cid, p_name, true);
  insert into memberships(company_id, user_id, role) values (cid, auth.uid(), 'owner');
  return cid;
end $$;

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------
do $$
declare
  t text;
  member_tables text[] := array[
    'branches', 'customers', 'vehicles', 'vehicle_status_history', 'vehicle_costs', 'vehicle_tasks',
    'vehicle_photos', 'vehicle_documents', 'vin_reports', 'mileage_records', 'inspections',
    'leads', 'lead_events', 'test_drives', 'buyouts', 'listings', 'publication_jobs',
    'ai_texts', 'web_events', 'finance_requests', 'outbound_messages', 'imports', 'number_series'
  ];
begin
  foreach t in array member_tables loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy %I on %I for select using (is_member(company_id))', t || '_select', t);
    execute format('create policy %I on %I for insert with check (is_member(company_id))', t || '_insert', t);
    execute format('create policy %I on %I for update using (is_member(company_id)) with check (is_member(company_id))', t || '_update', t);
    execute format('create policy %I on %I for delete using (has_role(company_id, array[''owner'']::member_role[]))', t || '_delete', t);
  end loop;
end $$;

-- Firma: číst členové, měnit majitel
alter table companies enable row level security;
create policy companies_select on companies for select using (is_member(id));
create policy companies_update on companies for update using (has_role(id, array['owner']::member_role[]));

-- Členství: člen vidí kolegy, spravuje majitel
alter table memberships enable row level security;
create policy memberships_select on memberships for select using (is_member(company_id));
create policy memberships_write  on memberships for all
  using (has_role(company_id, array['owner']::member_role[]))
  with check (has_role(company_id, array['owner']::member_role[]));

-- Profil: vlastní + kolegové z firmy
alter table profiles enable row level security;
create policy profiles_self on profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_colleagues on profiles for select using (
  exists (select 1 from memberships a join memberships b on a.company_id = b.company_id
          where a.user_id = auth.uid() and b.user_id = profiles.id and a.active)
);

-- Prodej a faktury: majitel, prodejce, účetní (výkupčí ne)
do $$
declare t text;
begin
  foreach t in array array['sales', 'invoices', 'invoice_items'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy %I on %I for all using (has_role(company_id, array[''owner'',''sales'',''accountant'']::member_role[])) with check (has_role(company_id, array[''owner'',''sales'',''accountant'']::member_role[]))', t || '_rw', t);
  end loop;
end $$;

-- Přístupy k portálům: jen majitel
alter table channel_accounts enable row level security;
create policy channel_accounts_owner on channel_accounts for all
  using (has_role(company_id, array['owner']::member_role[]))
  with check (has_role(company_id, array['owner']::member_role[]));

-- F&I partneři: katalog čtou všichni přihlášení, nastavení firmy majitel
alter table finance_partners enable row level security;
create policy finance_partners_read on finance_partners for select using (auth.uid() is not null);
alter table company_finance_partners enable row level security;
create policy cfp_select on company_finance_partners for select using (is_member(company_id));
create policy cfp_write on company_finance_partners for all
  using (has_role(company_id, array['owner']::member_role[]))
  with check (has_role(company_id, array['owner']::member_role[]));

-- Šablony checklistů a dokumentů: systémové čtou všichni, vlastní firma
alter table checklist_templates enable row level security;
create policy checklist_templates_select on checklist_templates for select using (company_id is null or is_member(company_id));
create policy checklist_templates_write on checklist_templates for all
  using (company_id is not null and has_role(company_id, array['owner']::member_role[]))
  with check (company_id is not null and has_role(company_id, array['owner']::member_role[]));
alter table document_templates enable row level security;
create policy document_templates_select on document_templates for select using (company_id is null or is_member(company_id));
create policy document_templates_write on document_templates for all
  using (company_id is not null and has_role(company_id, array['owner']::member_role[]))
  with check (company_id is not null and has_role(company_id, array['owner']::member_role[]));

-- Audit: čte jen majitel, zapisuje jen trigger
alter table audit_log enable row level security;
create policy audit_owner on audit_log for select using (has_role(company_id, array['owner']::member_role[]));

-- Registrace z webu: žádný přímý přístup (jen service role v edge funkci)
alter table platform_signups enable row level security;

-- ---------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------
-- Buckety se zakládají v supabase/config.toml nebo seedem:
--   vehicle-photos  – veřejné čtení (fotky jdou na portály a do pluginu), cesta {company_id}/{vehicle_id}/{uuid}.webp
--   documents       – soukromý, čtení přes podepsané URL, cesta {company_id}/{type}/{uuid}.pdf
-- Politiky storage: zápis jen pokud první segment cesty = firma, kde je uživatel členem (viz prompt 02).
