create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  role text not null default 'sales' check (role in ('admin', 'sales')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id text primary key,
  sku text unique not null,
  name_en text not null,
  name_zh text,
  type text,
  inch text,
  style text,
  price text,
  fit_en text,
  fit_zh text,
  talk_en text,
  talk_zh text,
  cover_url text,
  image_urls text[] not null default '{}',
  video_urls text[] not null default '{}',
  tags text[] not null default '{}',
  sort_order integer not null default 999,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text,
  phone text,
  email text,
  city text,
  profile_type text,
  profile_type_en text,
  score integer,
  follow_status text,
  recommended_sku text,
  consent boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.client_events (
  id uuid primary key default gen_random_uuid(),
  client_id text not null references public.clients(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null,
  note text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.clients enable row level security;
alter table public.client_events enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
      and active = true
  );
$$;

drop policy if exists "profiles read own or admin" on public.profiles;
create policy "profiles read own or admin"
on public.profiles for select
using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles admin update" on public.profiles;
create policy "profiles admin update"
on public.profiles for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "products readable by authenticated users" on public.products;
create policy "products readable by authenticated users"
on public.products for select
using (auth.role() = 'authenticated' and active = true);

drop policy if exists "products writable by admin" on public.products;
create policy "products writable by admin"
on public.products for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "clients read own or admin" on public.clients;
create policy "clients read own or admin"
on public.clients for select
using (owner_id = auth.uid() or public.is_admin());

drop policy if exists "clients insert own" on public.clients;
create policy "clients insert own"
on public.clients for insert
with check (owner_id = auth.uid() or public.is_admin());

drop policy if exists "clients update own or admin" on public.clients;
create policy "clients update own or admin"
on public.clients for update
using (owner_id = auth.uid() or public.is_admin())
with check (owner_id = auth.uid() or public.is_admin());

drop policy if exists "client events read own or admin" on public.client_events;
create policy "client events read own or admin"
on public.client_events for select
using (owner_id = auth.uid() or public.is_admin());

drop policy if exists "client events insert own" on public.client_events;
create policy "client events insert own"
on public.client_events for insert
with check (owner_id = auth.uid() or public.is_admin());
