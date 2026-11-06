-- Store the Google Docs draft URL with each shared task.
alter table public.tasks
  add column if not exists draft_url text;

-- Replace broad team write access with role/assignment-based access.
drop policy if exists "tasks_write_team" on public.tasks;
drop policy if exists "tasks_insert_admin" on public.tasks;
drop policy if exists "tasks_update_admin_or_assignee" on public.tasks;
drop policy if exists "tasks_delete_admin" on public.tasks;

create policy "tasks_insert_admin" on public.tasks
  for insert to authenticated
  with check (public.current_user_role() = 'Admin');

create policy "tasks_update_admin_or_assignee" on public.tasks
  for update to authenticated
  using (
    public.current_user_role() = 'Admin'
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.is_active = true
        and p.full_name = tasks.pic
        and p.role = 'User'
    )
  )
  with check (
    public.current_user_role() = 'Admin'
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.is_active = true
        and p.full_name = tasks.pic
        and p.role = 'User'
    )
  );

create policy "tasks_delete_admin" on public.tasks
  for delete to authenticated
  using (public.current_user_role() = 'Admin');

-- Team members may only change progress and the Google Docs draft URL.
revoke update on public.tasks from authenticated;
grant update (progress, draft_url, updated_at) on public.tasks to authenticated;
