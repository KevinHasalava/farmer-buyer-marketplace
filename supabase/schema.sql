-- =====================================================================
-- Farm2Home  –  Supabase production schema
-- Run this whole file ONCE in:  Supabase Dashboard > SQL Editor > New query
-- It is idempotent (safe to re-run).
--
-- NOTE: if you previously created tables named farmers / buyers / drivers /
-- products / orders / driver_deliveries with a different shape (for example
-- a uuid "id" column), drop them first (they only contain test data):
--   drop table if exists public.driver_deliveries, public.orders,
--     public.products, public.drivers, public.buyers, public.farmers cascade;
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- 1. PROFILES  (one row per auth user; holds the ROLE)
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        text not null default 'buyer'
              check (role in ('farmer','buyer','driver','admin')),
  full_name   text not null default '',
  email       text not null default '',
  phone       text not null default '',
  district    text not null default '',
  avatar_url  text not null default '',
  status      text not null default 'Active',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2. ROLE TABLES
--    id = auth user id (as text) for self-registered users.
--    Admin-created records get a generated id.
-- ---------------------------------------------------------------------
create table if not exists public.farmers (
  id              text primary key default gen_random_uuid()::text,
  full_name       text not null default '',
  email           text not null default '',
  phone           text not null default '',
  farm_name       text not null default '',
  district        text not null default '',
  agrarian_center text not null default '',
  scale           text not null default '',
  practice        text not null default '',
  crops           jsonb not null default '[]'::jsonb,
  nic             text not null default '',
  bank_name       text not null default '',
  account_number  text not null default '',
  is_verified     boolean not null default false,
  status          text not null default 'Pending Verification',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table if not exists public.buyers (
  id               text primary key default gen_random_uuid()::text,
  full_name        text not null default '',
  email            text not null default '',
  phone            text not null default '',
  district         text not null default '',
  delivery_address text not null default '',
  delivery_hub     text not null default '',
  buyer_type       text not null default 'Family / Household',
  total_orders     integer not null default 0,
  total_spent      numeric(14,2) not null default 0,
  status           text not null default 'Active',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table if not exists public.drivers (
  id                   text primary key default gen_random_uuid()::text,
  full_name            text not null default '',
  email                text not null default '',
  phone_number         text not null default '',
  district             text not null default '',
  license_number       text not null default '',
  vehicle_type         text not null default '',
  vehicle_number       text not null default '',
  cargo_capacity       text not null default '',
  is_cold_box_equipped boolean not null default false,
  operating_corridors  jsonb not null default '[]'::jsonb,
  bank_name            text not null default '',
  bank_account_number  text not null default '',
  duty_status          boolean not null default false,
  rating               numeric(3,2) not null default 0,
  completed_deliveries integer not null default 0,
  status               text not null default 'Active',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. PRODUCTS
-- ---------------------------------------------------------------------
create table if not exists public.products (
  id            text primary key default gen_random_uuid()::text,
  farmer_id     text references public.farmers(id) on delete set null,
  name          text not null,
  category      text not null default 'Vegetables',
  price         numeric(12,2) not null default 0 check (price >= 0),
  unit          text not null default '/kg',
  available_qty numeric(12,2) not null default 0 check (available_qty >= 0),
  farm_name     text not null default '',
  farmer_name   text not null default '',
  is_organic    boolean not null default false,
  image_url     text not null default '',
  description   text not null default '',
  status        text not null default 'In Stock',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists products_farmer_idx on public.products(farmer_id);

-- ---------------------------------------------------------------------
-- 4. ORDERS  +  DRIVER DELIVERIES
-- ---------------------------------------------------------------------
create table if not exists public.orders (
  id                    text primary key default ('FH-' || upper(substr(gen_random_uuid()::text, 1, 6))),
  buyer_id              text references public.buyers(id) on delete set null,
  farmer_id             text references public.farmers(id) on delete set null,
  driver_id             text references public.drivers(id) on delete set null,
  customer_name         text not null default '',
  customer_phone        text not null default '',
  farm_name             text not null default '',
  items_summary         text not null default '',
  total_amount          numeric(14,2) not null default 0 check (total_amount >= 0),
  status                text not null default 'Pending',
  delivery_address      text not null default '',
  assigned_driver_name  text not null default '',
  assigned_driver_phone text not null default '',
  order_date            timestamptz not null default now(),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);
create index if not exists orders_buyer_idx  on public.orders(buyer_id);
create index if not exists orders_farmer_idx on public.orders(farmer_id);
create index if not exists orders_driver_idx on public.orders(driver_id);

create table if not exists public.driver_deliveries (
  id             text primary key,
  order_number   text not null default '',
  driver_id      text references public.drivers(id) on delete set null,
  farmer_name    text not null default '',
  farmer_address text not null default '',
  farmer_phone   text not null default '',
  buyer_name     text not null default '',
  buyer_address  text not null default '',
  buyer_phone    text not null default '',
  items_summary  text not null default '',
  crate_count    text not null default '',
  status         text not null default 'Pending',
  is_priority    boolean not null default false,
  cod_amount     text not null default '',
  payout_amount  text not null default '',
  van_temp       text not null default '',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 5. NOTIFICATIONS
-- ---------------------------------------------------------------------
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text not null default '',
  body       text not null default '',
  type       text not null default 'general',
  is_read    boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists notifications_user_idx on public.notifications(user_id, created_at desc);

-- ---------------------------------------------------------------------
-- 6. HELPERS
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin' and p.status = 'Active'
  );
$$;

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array['profiles','farmers','buyers','drivers','products','orders','driver_deliveries']
  loop
    execute format('drop trigger if exists trg_touch_%1$s on public.%1$s', t);
    execute format('create trigger trg_touch_%1$s before update on public.%1$s
                    for each row execute function public.touch_updated_at()', t);
  end loop;
end $$;

-- Only an admin may change a role / status of a profile.
create or replace function public.protect_profile_columns()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    new.role   := old.role;
    new.status := old.status;
  end if;
  return new;
end $$;
drop trigger if exists trg_protect_profile on public.profiles;
create trigger trg_protect_profile before update on public.profiles
  for each row execute function public.protect_profile_columns();

-- ---------------------------------------------------------------------
-- 7. AUTO-CREATE PROFILE + ROLE ROW ON SIGN-UP
--    The app passes details in raw_user_meta_data. "admin" can NEVER be
--    self-assigned: unknown / admin roles fall back to "buyer".
-- ---------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  m        jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_role   text  := lower(coalesce(m->>'role', 'buyer'));
  v_name   text  := coalesce(nullif(m->>'full_name',''), split_part(coalesce(new.email,''),'@',1));
  v_phone  text  := coalesce(m->>'phone', '');
  v_dist   text  := coalesce(m->>'district', '');
begin
  if v_role not in ('farmer','buyer','driver') then
    v_role := 'buyer';
  end if;

  insert into public.profiles (id, role, full_name, email, phone, district)
  values (new.id, v_role, v_name, coalesce(new.email,''), v_phone, v_dist)
  on conflict (id) do nothing;

  if v_role = 'farmer' then
    insert into public.farmers (id, full_name, email, phone, farm_name, district,
                                agrarian_center, scale, practice, crops, nic,
                                bank_name, account_number)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone,
            coalesce(m->>'farm_name',''), v_dist,
            coalesce(m->>'agrarian_center',''), coalesce(m->>'scale',''),
            coalesce(m->>'practice',''),
            coalesce(m->'crops','[]'::jsonb),
            coalesce(m->>'nic',''), coalesce(m->>'bank_name',''),
            coalesce(m->>'account_number',''))
    on conflict (id) do nothing;
  elsif v_role = 'buyer' then
    insert into public.buyers (id, full_name, email, phone, district, delivery_address,
                               delivery_hub, buyer_type)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone, v_dist,
            coalesce(m->>'delivery_address',''), coalesce(m->>'delivery_hub',''),
            coalesce(nullif(m->>'buyer_type',''),'Family / Household'))
    on conflict (id) do nothing;
  elsif v_role = 'driver' then
    insert into public.drivers (id, full_name, email, phone_number, district, license_number,
                                vehicle_type, vehicle_number, cargo_capacity,
                                is_cold_box_equipped, bank_name, bank_account_number)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone, v_dist,
            coalesce(m->>'license_number',''), coalesce(m->>'vehicle_type',''),
            coalesce(m->>'vehicle_number',''), coalesce(m->>'cargo_capacity',''),
            coalesce((m->>'is_cold_box_equipped')::boolean, false),
            coalesce(m->>'bank_name',''), coalesce(m->>'account_number',''))
    on conflict (id) do nothing;
  end if;

  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 8. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
alter table public.profiles          enable row level security;
alter table public.farmers           enable row level security;
alter table public.buyers            enable row level security;
alter table public.drivers           enable row level security;
alter table public.products          enable row level security;
alter table public.orders            enable row level security;
alter table public.driver_deliveries enable row level security;
alter table public.notifications     enable row level security;

-- profiles
drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_update on public.profiles;
drop policy if exists profiles_admin  on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());
create policy profiles_update on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_admin  on public.profiles for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- farmers / buyers / drivers : owner read+write, admin everything
do $$
declare t text;
begin
  foreach t in array array['farmers','buyers','drivers']
  loop
    execute format('drop policy if exists %1$s_owner_select on public.%1$s', t);
    execute format('drop policy if exists %1$s_owner_insert on public.%1$s', t);
    execute format('drop policy if exists %1$s_owner_update on public.%1$s', t);
    execute format('drop policy if exists %1$s_admin on public.%1$s', t);
    execute format('create policy %1$s_owner_select on public.%1$s for select to authenticated using (id = auth.uid()::text or public.is_admin())', t);
    execute format('create policy %1$s_owner_insert on public.%1$s for insert to authenticated with check (id = auth.uid()::text)', t);
    execute format('create policy %1$s_owner_update on public.%1$s for update to authenticated using (id = auth.uid()::text) with check (id = auth.uid()::text)', t);
    execute format('create policy %1$s_admin on public.%1$s for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- Buyers & drivers may read a farmer's public farm info (name, district, verified)
drop policy if exists farmers_public_read on public.farmers;
create policy farmers_public_read on public.farmers for select to authenticated
  using (is_verified = true);

-- products: everyone signed-in can browse; farmer manages own; admin all
drop policy if exists products_read   on public.products;
drop policy if exists products_insert on public.products;
drop policy if exists products_update on public.products;
drop policy if exists products_delete on public.products;
drop policy if exists products_admin  on public.products;
create policy products_read   on public.products for select to authenticated using (true);
create policy products_insert on public.products for insert to authenticated
  with check (farmer_id = auth.uid()::text);
create policy products_update on public.products for update to authenticated
  using (farmer_id = auth.uid()::text) with check (farmer_id = auth.uid()::text);
create policy products_delete on public.products for delete to authenticated
  using (farmer_id = auth.uid()::text);
create policy products_admin  on public.products for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- orders
drop policy if exists orders_select on public.orders;
drop policy if exists orders_insert on public.orders;
drop policy if exists orders_update on public.orders;
drop policy if exists orders_admin  on public.orders;
create policy orders_select on public.orders for select to authenticated
  using (buyer_id = auth.uid()::text or farmer_id = auth.uid()::text or driver_id = auth.uid()::text or public.is_admin());
create policy orders_insert on public.orders for insert to authenticated
  with check (true);
create policy orders_update on public.orders for update to authenticated
  using (farmer_id = auth.uid()::text or driver_id = auth.uid()::text or buyer_id = auth.uid()::text or public.is_admin())
  with check (farmer_id = auth.uid()::text or driver_id = auth.uid()::text or buyer_id = auth.uid()::text or public.is_admin());
create policy orders_admin  on public.orders for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- driver_deliveries
drop policy if exists deliveries_select on public.driver_deliveries;
drop policy if exists deliveries_insert on public.driver_deliveries;
drop policy if exists deliveries_update on public.driver_deliveries;
drop policy if exists deliveries_admin  on public.driver_deliveries;
create policy deliveries_select on public.driver_deliveries for select to authenticated
  using (driver_id = auth.uid()::text or driver_id is null or public.is_admin());
create policy deliveries_insert on public.driver_deliveries for insert to authenticated
  with check (true);
create policy deliveries_update on public.driver_deliveries for update to authenticated
  using (driver_id = auth.uid()::text or public.is_admin()) with check (driver_id = auth.uid()::text or public.is_admin());
create policy deliveries_admin  on public.driver_deliveries for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- notifications
drop policy if exists notif_select on public.notifications;
drop policy if exists notif_update on public.notifications;
drop policy if exists notif_delete on public.notifications;
drop policy if exists notif_admin  on public.notifications;
create policy notif_select on public.notifications for select to authenticated using (user_id = auth.uid());
create policy notif_update on public.notifications for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notif_delete on public.notifications for delete to authenticated using (user_id = auth.uid());
create policy notif_admin  on public.notifications for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------
-- 9. AUCTIONS & BIDDING MODULE
-- ---------------------------------------------------------------------
create table if not exists public.auctions (
  id                   text primary key,
  farmer_id            text references public.farmers(id) on delete set null,
  farmer_name          text default 'Farmer',
  farmer_phone         text default '',
  farmer_location      text default '',
  farmer_avatar        text default '',
  crop_name            text not null,
  category             text default 'Vegetables',
  quantity             numeric not null default 0,
  unit                 text default 'kg',
  starting_price       numeric not null default 0,
  min_bid_increment    numeric default 5.0,
  reserve_price        numeric,
  buy_now_price        numeric,
  current_highest_bid  numeric default 0,
  highest_bidder_id    text,
  highest_bidder_name  text,
  total_bids           integer default 0,
  description          text default '',
  harvest_date         timestamptz,
  delivery_terms       text default 'Farmgate Pickup',
  location             text default '',
  image_url            text default '',
  start_time           timestamptz default now(),
  end_time             timestamptz not null,
  status               text default 'active', -- 'active', 'ended', 'sold', 'cancelled'
  created_at           timestamptz default now()
);

create table if not exists public.auction_bids (
  id                   text primary key,
  auction_id           text not null references public.auctions(id) on delete cascade,
  bidder_id            text,
  bidder_name          text default 'Anonymous Buyer',
  amount               numeric not null,
  is_winning           boolean default false,
  notes                text default '',
  created_at           timestamptz default now()
);

alter table public.auctions enable row level security;
alter table public.auction_bids enable row level security;

-- RLS for auctions
drop policy if exists auctions_select on public.auctions;
drop policy if exists auctions_insert on public.auctions;
drop policy if exists auctions_update on public.auctions;
drop policy if exists auctions_delete on public.auctions;
drop policy if exists auctions_admin  on public.auctions;

create policy auctions_select on public.auctions for select
  using (true);
create policy auctions_insert on public.auctions for insert to authenticated
  with check (true);
create policy auctions_update on public.auctions for update to authenticated
  using (true) with check (true);
create policy auctions_delete on public.auctions for delete to authenticated
  using (farmer_id = auth.uid()::text or public.is_admin());
create policy auctions_admin on public.auctions for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- RLS for auction_bids
drop policy if exists bids_select on public.auction_bids;
drop policy if exists bids_insert on public.auction_bids;
drop policy if exists bids_admin  on public.auction_bids;

create policy bids_select on public.auction_bids for select
  using (true);
create policy bids_insert on public.auction_bids for insert to authenticated
  with check (true);
create policy bids_admin on public.auction_bids for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------
-- 10. PRE-ORDERS & CONTRACT FARMING MODULE
-- ---------------------------------------------------------------------
create table if not exists public.pre_orders (
  id                            text primary key,
  buyer_id                      text,
  buyer_name                    text not null,
  farmer_id                     text references public.farmers(id) on delete set null,
  farmer_name                   text,
  crop_name                     text not null,
  required_quantity_kg          numeric not null default 0,
  offered_price_per_kg          numeric not null default 0,
  expected_delivery_date        timestamptz not null,
  quality_requirements          text default '',
  delivery_location             text default '',
  payment_terms                 text default 'Negotiable',
  packaging_requirements        text default 'Standard Packaging',
  advance_payment_rs            numeric default 0,
  status                        text default 'Pending', -- 'Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled'
  farmer_expected_harvest_date  timestamptz,
  farmer_estimated_yield_kg     numeric,
  farmer_location               text default '',
  farmer_notes                  text default '',
  farmer_rating                 numeric,
  farmer_review                 text,
  rated_at                      timestamptz,
  created_at                    timestamptz default now()
);

create table if not exists public.pre_order_progress (
  id                text primary key,
  pre_order_id      text not null references public.pre_orders(id) on delete cascade,
  stage             text not null,
  description       text default '',
  images            text[] default '{}',
  date              timestamptz default now(),
  update_type       text default 'Progress', -- 'Progress', 'Delay', 'Issue'
  new_expected_date timestamptz,
  issue_type        text,
  created_at        timestamptz default now()
);

alter table public.pre_orders enable row level security;
alter table public.pre_order_progress enable row level security;

-- RLS for pre_orders
drop policy if exists pre_orders_select on public.pre_orders;
drop policy if exists pre_orders_insert on public.pre_orders;
drop policy if exists pre_orders_update on public.pre_orders;
drop policy if exists pre_orders_delete on public.pre_orders;
drop policy if exists pre_orders_admin  on public.pre_orders;

create policy pre_orders_select on public.pre_orders for select
  using (true);
create policy pre_orders_insert on public.pre_orders for insert to authenticated
  with check (true);
create policy pre_orders_update on public.pre_orders for update to authenticated
  using (true) with check (true);
create policy pre_orders_delete on public.pre_orders for delete to authenticated
  using (buyer_id = auth.uid()::text or public.is_admin());
create policy pre_orders_admin on public.pre_orders for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- RLS for pre_order_progress
drop policy if exists progress_select on public.pre_order_progress;
drop policy if exists progress_insert on public.pre_order_progress;
drop policy if exists progress_delete on public.pre_order_progress;
drop policy if exists progress_admin  on public.pre_order_progress;

create policy progress_select on public.pre_order_progress for select
  using (true);
create policy progress_insert on public.pre_order_progress for insert to authenticated
  with check (true);
create policy progress_delete on public.pre_order_progress for delete to authenticated
  using (public.is_admin());
create policy progress_admin on public.pre_order_progress for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------
-- 11. REAL WORLD SEEDS (Optional initial data for Auctions & Contracts)
-- ---------------------------------------------------------------------
insert into public.auctions (
  id, crop_name, category, quantity, unit, starting_price, min_bid_increment,
  buy_now_price, current_highest_bid, total_bids, description, location,
  image_url, start_time, end_time, status, farmer_name, farmer_location
) values
(
  'auc_101', 'Keeri Samba Paddy Harvest', 'Grains', 1500, 'kg', 120, 5,
  145, 130, 2, 'Freshly harvested Keeri Samba paddy from Polonnaruwa organic fields. Moisture level < 14%.',
  'Polonnaruwa', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
  now(), now() + interval '3 days', 'active', 'Sunil Bandara', 'Polonnaruwa'
),
(
  'auc_102', 'Export Quality Cavendish Bananas', 'Fruits', 800, 'kg', 180, 5,
  220, 195, 3, 'Grade-A Cavendish bananas, carefully packed in crates. Ready for cold transit.',
  'Embilipitiya', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
  now(), now() + interval '2 days', 'active', 'Nimal Jayawardena', 'Embilipitiya'
),
(
  'auc_103', 'Upcountry Bell Peppers (Mixed)', 'Vegetables', 400, 'kg', 450, 10,
  550, 480, 4, 'Green, Red and Yellow Greenhouse Bell Peppers from Nuwara Eliya. Crisp and pesticide-free.',
  'Nuwara Eliya', 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80',
  now(), now() + interval '1 day', 'active', 'Priyani Fernando', 'Nuwara Eliya'
)
on conflict (id) do nothing;

insert into public.pre_orders (
  id, buyer_name, crop_name, required_quantity_kg, offered_price_per_kg,
  expected_delivery_date, quality_requirements, delivery_location, payment_terms,
  advance_payment_rs, status, farmer_name, farmer_location, farmer_notes
) values
(
  'po_101', 'Keells Wholesale Sourcing', 'Premium Nuwara Eliya Carrots', 1200, 320,
  now() + interval '30 days', 'Medium to large size, washed and sorted, grade A quality.',
  'Welisara Central Hub', '30% Advance on acceptance, 70% on delivery',
  115200, 'In Progress', 'Kamal Perera', 'Nuwara Eliya', 'Land tilled and organic bed preparation complete.'
),
(
  'po_102', 'Cargills Agri Procurement', 'Dambulla Red Big Onions', 2500, 240,
  now() + interval '45 days', 'Well-cured, skin intact, zero rot or mold. Minimum diameter 50mm.',
  'Dambulla Economic Center', 'Bank Transfer within 48h of inspection',
  0, 'Pending', null, 'Dambulla', ''
)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 12. CREATE YOUR FIRST ADMIN
--    1) In the app: register any normal account with YOUR email.
--    2) Then run (change the email) in the SQL editor:
--
--    update public.profiles set role = 'admin' where email = 'you@example.com';
--
--    3) Log in from the app's Admin login screen with that email/password.
-- ---------------------------------------------------------------------

