-- NIK-based login and self-registration for PLANT DOC PM
alter table public.profiles
  add column if not exists approval_status text not null default 'Approved'
  check (approval_status in ('Pending','Approved','Rejected'));

update public.profiles
set approval_status = case when is_active then 'Approved' else 'Pending' end
where approval_status is null or approval_status = '';

create or replace function public.create_profile_for_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nik text;
begin
  v_nik := nullif(trim(coalesce(new.raw_user_meta_data->>'nik','')), '');
  if v_nik is not null then
    insert into public.profiles (
      id, username, full_name, nik, position, email, role, is_active, approval_status
    ) values (
      new.id,
      v_nik,
      trim(coalesce(new.raw_user_meta_data->>'full_name','')),
      v_nik,
      trim(coalesce(new.raw_user_meta_data->>'job_position','')),
      lower(trim(coalesce(new.email,''))),
      'User',
      false,
      'Pending'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
after insert on auth.users
for each row execute procedure public.create_profile_for_new_auth_user();

-- This function is used only to translate a supplied NIK into the Auth email.
-- It returns an email only for active accounts; the UI never displays it.
create or replace function public.get_login_email_by_nik(p_nik text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select email
  from public.profiles
  where nik = trim(p_nik)
    and is_active = true
    and approval_status = 'Approved'
  limit 1
$$;

revoke all on function public.get_login_email_by_nik(text) from public;
grant execute on function public.get_login_email_by_nik(text) to anon, authenticated;

-- Admins can review and approve pending registrations using the profiles table.
drop policy if exists "profiles_read_authenticated" on public.profiles;
create policy "profiles_read_authenticated" on public.profiles
  for select to authenticated
  using (is_active = true or id = auth.uid() or public.current_user_role() = 'Admin');
