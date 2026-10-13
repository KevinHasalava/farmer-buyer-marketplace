-- =============================================================================
-- Farm2Home: Buyer Cart + Notifications tables (Member IT23843770 - Thennakoon)
-- Run this ONCE in Supabase Dashboard -> SQL Editor -> New query -> Run.
-- It is safe to re-run (idempotent) and does NOT drop any data.
-- =============================================================================

-- 1. Shopping cart (CRUD: Create/Read/Update quantity/Delete) ------------------
create table if not exists public.cart_items (
  id            text primary key,
  buyer_id      text not null,
  product_name  text not null,
  unit_price    numeric(12,2) not null default 0,
  unit          text default '/kg',
  quantity      integer not null default 1 check (quantity > 0),
  emoji         text default '🥬',
  farm_name     text default '',
  image_url     text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

alter table public.cart_items enable row level security;
drop policy if exists cart_items_all_access on public.cart_items;
create policy cart_items_all_access on public.cart_items
  for all using (true) with check (true);

-- 2. Notifications (READ + mark read/unread UPDATE + admin broadcast CREATE) ---
create table if not exists public.notifications (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now()
);

alter table public.notifications add column if not exists buyer_id text;
alter table public.notifications add column if not exists title text;
alter table public.notifications add column if not exists message text;
alter table public.notifications add column if not exists type text default 'Order Updates';
alter table public.notifications add column if not exists is_read boolean default false;

-- Allow admin-created notifications that target a buyer_id instead of an auth user
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'notifications'
               and column_name = 'user_id') then
    execute 'alter table public.notifications alter column user_id drop not null';
  end if;
end $$;

alter table public.notifications enable row level security;
drop policy if exists notifications_all_access on public.notifications;
create policy notifications_all_access on public.notifications
  for all using (true) with check (true);
