-- Centralize document master and imported registry records in Supabase.
-- source_key gives each imported register row a stable upsert key.
alter table public.document_registry
  add column if not exists source_key text;

create unique index if not exists document_registry_source_key_uidx
  on public.document_registry(source_key)
  where source_key is not null;

-- Master document codes are unique in the Plant register.
create unique index if not exists documents_code_uidx
  on public.documents(code);

grant select, insert, update, delete on public.document_registry to authenticated;
grant select, insert, update, delete on public.documents to authenticated;

drop policy if exists "registry_admin_manage" on public.document_registry;
create policy "registry_admin_manage" on public.document_registry
  for all to authenticated
  using (public.current_user_role() = 'Admin')
  with check (public.current_user_role() = 'Admin');

drop policy if exists "documents_write_team" on public.documents;
create policy "documents_write_team" on public.documents
  for all to authenticated
  using (public.current_user_role() in ('Admin','User'))
  with check (public.current_user_role() in ('Admin','User'));
