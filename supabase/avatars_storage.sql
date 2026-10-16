-- Profile photos uploaded during registration.
-- Run once in Supabase Dashboard > SQL Editor.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

alter table public.profiles
  add column if not exists avatar_url text not null default '';

drop policy if exists "avatars_public_read"   on storage.objects;
drop policy if exists "avatars_public_insert" on storage.objects;
drop policy if exists "avatars_public_update" on storage.objects;

create policy "avatars_public_read"   on storage.objects
  for select to public using (bucket_id = 'avatars');

-- Uploads happen right after sign-up (the user may not have a session yet when
-- e-mail confirmation is enabled), so inserts are allowed for the bucket.
create policy "avatars_public_insert" on storage.objects
  for insert to public with check (bucket_id = 'avatars');

create policy "avatars_public_update" on storage.objects
  for update to public using (bucket_id = 'avatars');
