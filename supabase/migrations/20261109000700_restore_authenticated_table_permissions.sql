-- Restore explicit API privileges for authenticated application users.
-- This migration does not delete or modify application records.

grant usage on schema public to authenticated;

grant select on public.profiles to authenticated;
grant select, insert, delete on public.tasks to authenticated;
grant update (progress, draft_url, updated_at) on public.tasks to authenticated;

grant select, insert, update, delete on public.document_registry to authenticated;
grant select, insert, update, delete on public.documents to authenticated;

-- Ensure authenticated users can read shared task rows; row access remains
-- controlled by the RLS policy and does not grant write access by itself.
drop policy if exists "tasks_read_authenticated" on public.tasks;
create policy "tasks_read_authenticated" on public.tasks
  for select to authenticated
  using (true);

-- Ensure approved active profiles remain visible to the team, while pending
-- registrations are visible only to their owner or an Admin.
drop policy if exists "profiles_read_authenticated" on public.profiles;
create policy "profiles_read_authenticated" on public.profiles
  for select to authenticated
  using (
    (is_active = true and approval_status = 'Approved')
    or id = auth.uid()
    or public.current_user_role() = 'Admin'
  );
