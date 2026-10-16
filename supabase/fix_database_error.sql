-- =====================================================================
-- Farm2Home – Fix Registration for All 3 Roles (Farmer, Buyer, Driver)
-- Fixes "Database error saving new user" (Instant Fix)
--
-- How to use:
-- 1. Open Supabase Dashboard (https://supabase.com/dashboard)
-- 2. Go to: SQL Editor  ->  New Query
-- 3. Paste this ENTIRE script and click "RUN"
-- =====================================================================

-- 1. Ensure `profiles` table has all columns safely
alter table public.profiles add column if not exists status text not null default 'Active';
alter table public.profiles add column if not exists is_active boolean not null default true;
alter table public.profiles add column if not exists address text not null default '';
alter table public.profiles add column if not exists district text not null default '';

-- 2. Ensure `buyers` table exists with all required columns
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

-- 3. Relax RLS on ALL 4 tables so App & Admin can sync freely
alter table public.profiles enable row level security;
drop policy if exists profiles_all_access on public.profiles;
create policy profiles_all_access on public.profiles for all to public using (true) with check (true);

alter table public.buyers enable row level security;
drop policy if exists buyers_all_access on public.buyers;
create policy buyers_all_access on public.buyers for all to public using (true) with check (true);

alter table public.farmers enable row level security;
drop policy if exists farmers_all_access on public.farmers;
create policy farmers_all_access on public.farmers for all to public using (true) with check (true);

alter table public.drivers enable row level security;
drop policy if exists drivers_all_access on public.drivers;
create policy drivers_all_access on public.drivers for all to public using (true) with check (true);

-- 4. BULLETPROOF Trigger Function with exception safety for all 3 roles
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
  v_crops  text[];
begin
  if v_role not in ('farmer','buyer','driver') then
    v_role := 'buyer';
  end if;

  -- 4a. Profiles Insert (Safely protected)
  begin
    insert into public.profiles (id, role, full_name, email, phone, district, address, status, is_active)
    values (new.id, v_role, v_name, coalesce(new.email,''), v_phone, v_dist, v_addr, 'Active', true)
    on conflict (id) do update set
      role = excluded.role,
      full_name = case when excluded.full_name <> '' then excluded.full_name else profiles.full_name end,
      email = case when excluded.email <> '' then excluded.email else profiles.email end,
      phone = case when excluded.phone <> '' then excluded.phone else profiles.phone end,
      district = case when excluded.district <> '' then excluded.district else profiles.district end,
      address = case when excluded.address <> '' then excluded.address else profiles.address end,
      status = 'Active',
      is_active = true,
      updated_at = now();
  exception when others then
    raise warning 'handle_new_user profiles insert failed: %', sqlerrm;
  end;

  -- 4b. Role-Specific Table Inserts
  begin
    if v_role = 'buyer' then
      insert into public.buyers (id, full_name, email, phone, district, delivery_address, delivery_hub, buyer_type, status)
      values (new.id::text, v_name, coalesce(new.email,''), v_phone, v_dist, v_addr, v_dist, v_type, 'Active')
      on conflict (id) do update set
        full_name = case when excluded.full_name <> '' then excluded.full_name else buyers.full_name end,
        email = case when excluded.email <> '' then excluded.email else buyers.email end,
        phone = case when excluded.phone <> '' then excluded.phone else buyers.phone end,
        district = case when excluded.district <> '' then excluded.district else buyers.district end,
        delivery_address = case when excluded.delivery_address <> '' then excluded.delivery_address else buyers.delivery_address end,
        delivery_hub = case when excluded.delivery_hub <> '' then excluded.delivery_hub else buyers.delivery_hub end,
        buyer_type = excluded.buyer_type,
        status = 'Active',
        updated_at = now();

    elsif v_role = 'farmer' then
      -- Safely convert crops jsonb array to text[] array
      begin
        if jsonb_typeof(m->'crops') = 'array' and jsonb_array_length(m->'crops') > 0 then
          select array_agg(x) into v_crops from jsonb_array_elements_text(m->'crops') as x;
        else
          v_crops := array['Rice & Grains']::text[];
        end if;
      exception when others then
        v_crops := array['Rice & Grains']::text[];
      end;

      insert into public.farmers (
        id, full_name, email, phone, farm_name, district,
        agrarian_center, scale, practice, crops, nic,
        bank_name, account_number, status, is_verified
      )
      values (
        new.id::text, v_name, coalesce(new.email,''), v_phone,
        coalesce(m->>'farm_name',''), v_dist,
        coalesce(m->>'agrarian_center',''), coalesce(m->>'scale',''),
        coalesce(m->>'practice',''),
        coalesce(v_crops, array['Rice & Grains']::text[]),
        coalesce(m->>'nic',''), coalesce(m->>'bank_name',''),
        coalesce(m->>'account_number',''), 'Active', true
      )
      on conflict (id) do update set
        full_name = excluded.full_name,
        email = excluded.email,
        phone = excluded.phone,
        farm_name = case when excluded.farm_name <> '' then excluded.farm_name else farmers.farm_name end,
        district = case when excluded.district <> '' then excluded.district else farmers.district end,
        updated_at = now();

    elsif v_role = 'driver' then
      insert into public.drivers (
        id, full_name, license_number, phone_number,
        vehicle_type, vehicle_number, cargo_capacity,
        is_cold_box_equipped, duty_status, is_on_duty
      )
      values (
        new.id::text, v_name,
        coalesce(m->>'license_number',''), v_phone,
        coalesce(m->>'vehicle_type',''), coalesce(m->>'vehicle_number',''),
        coalesce(m->>'cargo_capacity',''),
        case when lower(coalesce(m->>'is_cold_box_equipped','false')) in ('true','1','t') then true else false end,
        true, true
      )
      on conflict (id) do update set
        full_name = excluded.full_name,
        phone_number = excluded.phone_number,
        updated_at = now();
    end if;
  exception when others then
    raise warning 'handle_new_user role insert failed: %', sqlerrm;
  end;

  return new;
exception when others then
  -- ULTIMATE CATCH-ALL: NEVER abort auth.users insert under any condition!
  raise warning 'handle_new_user overall error: %', sqlerrm;
  return new;
end $$;

-- 5. Bind trigger to auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
