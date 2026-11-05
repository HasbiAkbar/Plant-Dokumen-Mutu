-- Create the first Admin profile for the existing Supabase Auth user.
-- The email is read from auth.users; no password or secret is stored here.

insert into public.profiles (
  id,
  username,
  full_name,
  nik,
  position,
  email,
  role,
  is_active
)
select
  u.id,
  'Admin',
  'Sysdev',
  '100000',
  'Administrator',
  coalesce(u.email, ''),
  'Admin',
  true
from auth.users as u
where u.id = '2ea90e3f-aa04-4fba-ab73-e1a6b080b7f8'::uuid
on conflict (id) do update set
  username = excluded.username,
  full_name = excluded.full_name,
  nik = excluded.nik,
  position = excluded.position,
  email = excluded.email,
  role = 'Admin',
  is_active = true,
  updated_at = now();
