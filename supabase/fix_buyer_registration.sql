-- =====================================================================
-- Farm2Home  –  Fix Buyer Registration & Realtime Supabase Triggers
-- 
-- How to use:
-- 1. Open Supabase Dashboard (https://supabase.com/dashboard)
-- 2. Go to: SQL Editor  ->  New Query
-- 3. Paste this ENTIRE script and click "RUN"
-- =====================================================================

-- 1. Ensure `buyers` table exists with all required columns
create table if not exists public.buyers (
  id               text primary key,
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

-- 2. Ensure `profiles` table exists
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        text not null default 'buyer' check (role in ('farmer','buyer','driver','admin')),
  full_name   text not null default '',
  email       text not null default '',
  phone       text not null default '',
  district    text not null default '',
  address     text not null default '',
  avatar_url  text not null default '',
  status      text not null default 'Active',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- 3. Relax Row Level Security (RLS) so App & Admin can read/write without permission denied
alter table public.buyers enable row level security;
drop policy if exists buyers_all_access on public.buyers;
drop policy if exists buyers_owner_select on public.buyers;
drop policy if exists buyers_owner_insert on public.buyers;
drop policy if exists buyers_owner_update on public.buyers;
drop policy if exists buyers_admin on public.buyers;

create policy buyers_all_access on public.buyers
  for all to public using (true) with check (true);

alter table public.profiles enable row level security;
drop policy if exists profiles_all_access on public.profiles;
drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_update on public.profiles;
drop policy if exists profiles_admin on public.profiles;

create policy profiles_all_access on public.profiles
  for all to public using (true) with check (true);

-- 4. Automatic Trigger on Auth Sign-Up (Works for Buyer, Farmer, Driver)
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
  v_dist   text  := coalesce(m->>'district', m->>'hub', 'Colombo Regional Hub');
  v_addr   text  := coalesce(m->>'delivery_address', m->>'address', '');
  v_type   text  := coalesce(nullif(m->>'buyer_type',''), 'Family / Household');
begin
  if v_role not in ('farmer','buyer','driver') then
    v_role := 'buyer';
  end if;

  -- 4a. Always insert / update public.profiles
  insert into public.profiles (id, role, full_name, email, phone, district, address, status, is_active)
  values (new.id, v_role, v_name, coalesce(new.email,''), v_phone, v_dist, v_addr, 'Active', true)
  on conflict (id) do update set
    role = excluded.role,
    full_name = case when excluded.full_name <> '' then excluded.full_name else profiles.full_name end,
    email = case when excluded.email <> '' then excluded.email else profiles.email end,
    phone = case when excluded.phone <> '' then excluded.phone else profiles.phone end,
    district = case when excluded.district <> '' then excluded.district else profiles.district end,
    address = case when excluded.address <> '' then excluded.address else profiles.address end,
    updated_at = now();

  -- 4b. Insert into role-specific tables
  if v_role = 'buyer' then
    insert into public.buyers (id, full_name, email, phone, district, delivery_address, delivery_hub, buyer_type, status)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone, v_dist, v_addr, v_dist, v_type, 'Active')
    on conflict (id) do update set
      full_name = case when excluded.full_name <> '' then excluded.full_name else buyers.full_name end,
      email = case when excluded.email <> '' then excluded.email else buyers.email end,
      phone = case when excluded.phone <> '' then excluded.phone else buyers.phone end,
      delivery_address = case when excluded.delivery_address <> '' then excluded.delivery_address else buyers.delivery_address end,
      delivery_hub = case when excluded.delivery_hub <> '' then excluded.delivery_hub else buyers.delivery_hub end,
      buyer_type = excluded.buyer_type,
      updated_at = now();

  elsif v_role = 'farmer' then
    insert into public.farmers (id, full_name, email, phone, farm_name, district,
                                agrarian_center, scale, practice, crops, nic,
                                bank_name, account_number, status, is_verified)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone,
            coalesce(m->>'farm_name',''), v_dist,
            coalesce(m->>'agrarian_center',''), coalesce(m->>'scale',''),
            coalesce(m->>'practice',''),
            coalesce(m->'crops','[]'::jsonb),
            coalesce(m->>'nic',''), coalesce(m->>'bank_name',''),
            coalesce(m->>'account_number',''), 'Active', true)
    on conflict (id) do update set
      full_name = excluded.full_name,
      email = excluded.email,
      phone = excluded.phone,
      updated_at = now();

  elsif v_role = 'driver' then
    insert into public.drivers (id, full_name, email, phone_number, district, license_number,
                                vehicle_type, vehicle_number, cargo_capacity,
                                is_cold_box_equipped, bank_name, bank_account_number, status)
    values (new.id::text, v_name, coalesce(new.email,''), v_phone, v_dist,
            coalesce(m->>'license_number',''), coalesce(m->>'vehicle_type',''),
            coalesce(m->>'vehicle_number',''), coalesce(m->>'cargo_capacity',''),
            coalesce((m->>'is_cold_box_equipped')::boolean, false),
            coalesce(m->>'bank_name',''), coalesce(m->>'account_number',''), 'Active')
    on conflict (id) do update set
      full_name = excluded.full_name,
      email = excluded.email,
      phone_number = excluded.phone_number,
      updated_at = now();
  end if;

  return new;
end $$;

-- 5. Bind trigger to auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 6. Backfill existing buyers from profiles into public.buyers table immediately
insert into public.buyers (id, full_name, email, phone, district, delivery_address, delivery_hub, buyer_type, status)
select
  p.id::text,
  coalesce(nullif(p.full_name, ''), 'Buyer'),
  coalesce(p.email, ''),
  coalesce(p.phone, ''),
  coalesce(p.district, ''),
  coalesce(p.address, ''),
  coalesce(nullif(p.district, ''), 'Colombo Regional Hub'),
  'Family / Household',
  'Active'
from public.profiles p
where lower(p.role) = 'buyer'
on conflict (id) do update set
  full_name = case when excluded.full_name <> '' then excluded.full_name else buyers.full_name end,
  email = case when excluded.email <> '' then excluded.email else buyers.email end,
  phone = case when excluded.phone <> '' then excluded.phone else buyers.phone end;

-- 7. Verification output
select id, full_name, email, phone, buyer_type, status from public.buyers;
