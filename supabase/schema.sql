-- =====================================================================
-- Skema database Aplikasi Keuangan Rumah Tangga (Supabase / Postgres)
-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor.
-- Aman dijalankan ulang (idempoten) karena memakai IF NOT EXISTS / DROP.
-- =====================================================================

-- ---------- Tabel ----------

create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  nama       text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  nama       text not null,
  tipe       text not null check (tipe in ('income', 'expense')),
  warna      integer,                       -- ARGB int opsional untuk UI
  created_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  category_id uuid references public.categories (id) on delete set null,
  tipe        text not null check (tipe in ('income', 'expense')),
  amount      numeric(14, 2) not null check (amount >= 0),
  tanggal     date not null default current_date,
  catatan     text not null default '',
  created_at  timestamptz not null default now()
);

create table if not exists public.budgets (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  category_id  uuid not null references public.categories (id) on delete cascade,
  bulan        text not null,               -- format 'YYYY-MM'
  limit_amount numeric(14, 2) not null check (limit_amount >= 0),
  created_at   timestamptz not null default now(),
  unique (user_id, category_id, bulan)
);

create index if not exists idx_transactions_user_tanggal
  on public.transactions (user_id, tanggal desc);
create index if not exists idx_categories_user
  on public.categories (user_id);
create index if not exists idx_budgets_user_bulan
  on public.budgets (user_id, bulan);

-- ---------- Row Level Security ----------
-- Setiap user hanya boleh mengakses barisnya sendiri.

alter table public.profiles     enable row level security;
alter table public.categories   enable row level security;
alter table public.transactions enable row level security;
alter table public.budgets      enable row level security;

drop policy if exists "profiles_self" on public.profiles;
create policy "profiles_self" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "categories_self" on public.categories;
create policy "categories_self" on public.categories
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "transactions_self" on public.transactions;
create policy "transactions_self" on public.transactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "budgets_self" on public.budgets;
create policy "budgets_self" on public.budgets
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------- Trigger: auto-buat profil + kategori default saat daftar ----------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nama)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'nama', ''))
  on conflict (id) do nothing;

  insert into public.categories (user_id, nama, tipe) values
    (new.id, 'Gaji',        'income'),
    (new.id, 'Bonus',       'income'),
    (new.id, 'Lainnya',     'income'),
    (new.id, 'Makanan',     'expense'),
    (new.id, 'Transportasi','expense'),
    (new.id, 'Belanja',     'expense'),
    (new.id, 'Tagihan',     'expense'),
    (new.id, 'Kesehatan',   'expense'),
    (new.id, 'Hiburan',     'expense'),
    (new.id, 'Lainnya',     'expense');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
