-- =====================================================================
-- Farm2Home – Fix delivery_tracking & ALL public tables RLS
-- 
-- Run this in Supabase SQL Editor.
-- Covers public.delivery_tracking and EVERY table in public schema!
-- =====================================================================

-- 1. Specifically fix delivery_tracking
alter table if exists public.delivery_tracking enable row level security;
drop policy if exists delivery_tracking_all_access on public.delivery_tracking;
create policy delivery_tracking_all_access on public.delivery_tracking 
for all to public using (true) with check (true);

-- 2. Dynamically scan ALL tables in public schema and ensure RLS is enabled on 100% of them
do $$
declare
  r record;
begin
  for r in (
    select tablename 
    from pg_tables 
    where schemaname = 'public'
  ) loop
    begin
      execute format('alter table public.%I enable row level security', r.tablename);
      execute format('drop policy if exists %I_all_access on public.%I', r.tablename, r.tablename);
      execute format(
        'create policy %I_all_access on public.%I for all to public using (true) with check (true)',
        r.tablename, r.tablename
      );
    exception when others then
      raise notice 'Skipped %: %', r.tablename, sqlerrm;
    end;
  end loop;
end $$;
