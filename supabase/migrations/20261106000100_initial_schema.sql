-- PLANT DOC PM | Initial schema
-- Shared data model for Dokumen Mutu Plant 2027

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  full_name text not null default '',
  nik text unique,
  position text not null default '',
  email text not null default '',
  role text not null default 'Viewer' check (role in ('Admin','User','Viewer')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.document_registry (
  id uuid primary key default gen_random_uuid(),
  document_type text not null check (document_type in ('SOP','WI','STD','FRM')),
  title text not null,
  code text,
  url text,
  publication_date date,
  approval_date date,
  revision text,
  status text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists document_registry_type_code_uidx
  on public.document_registry(document_type, code) where code is not null and code <> '';

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  document_type text not null check (document_type in ('SOP','WI','STD','FRM')),
  element text not null default '',
  status text not null default 'Belum Tersedia',
  pic text not null default '',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  pic text not null,
  priority text not null default 'Normal' check (priority in ('Normal','Tinggi','Urgent')),
  due date,
  progress integer not null default 0 check (progress between 0 and 100),
  status text not null default 'Belum Dimulai',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tasks_pic_idx on public.tasks(pic);
create index if not exists tasks_due_idx on public.tasks(due);

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and is_active = true
$$;

alter table public.profiles enable row level security;
alter table public.document_registry enable row level security;
alter table public.documents enable row level security;
alter table public.tasks enable row level security;

drop policy if exists "profiles_read_authenticated" on public.profiles;
create policy "profiles_read_authenticated" on public.profiles
  for select to authenticated using (is_active = true or id = auth.uid());
drop policy if exists "profiles_admin_manage" on public.profiles;
create policy "profiles_admin_manage" on public.profiles
  for all to authenticated using (public.current_user_role() = 'Admin')
  with check (public.current_user_role() = 'Admin');

drop policy if exists "registry_read_authenticated" on public.document_registry;
create policy "registry_read_authenticated" on public.document_registry
  for select to authenticated using (true);
drop policy if exists "registry_admin_manage" on public.document_registry;
create policy "registry_admin_manage" on public.document_registry
  for all to authenticated using (public.current_user_role() = 'Admin')
  with check (public.current_user_role() = 'Admin');

drop policy if exists "documents_read_authenticated" on public.documents;
create policy "documents_read_authenticated" on public.documents
  for select to authenticated using (true);
drop policy if exists "documents_write_team" on public.documents;
create policy "documents_write_team" on public.documents
  for all to authenticated using (public.current_user_role() in ('Admin','User'))
  with check (public.current_user_role() in ('Admin','User'));

drop policy if exists "tasks_read_authenticated" on public.tasks;
create policy "tasks_read_authenticated" on public.tasks
  for select to authenticated using (true);
drop policy if exists "tasks_write_team" on public.tasks;
create policy "tasks_write_team" on public.tasks
  for all to authenticated using (public.current_user_role() in ('Admin','User'))
  with check (public.current_user_role() in ('Admin','User'));

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.document_registry to authenticated;
grant select, insert, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.tasks to authenticated;
grant execute on function public.current_user_role() to authenticated;
