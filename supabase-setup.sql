-- À lancer dans Supabase > SQL Editor

create table if not exists public.candidats (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  prenom text not null,
  nom text not null,
  tel text not null,
  email text not null,
  age int not null check (age between 16 and 25),
  niveau text,
  parent_ok boolean not null default false,
  cv_path text
);

alter table public.candidats enable row level security;

-- Le site (anon) peut seulement INSERER, jamais lire.
create policy "anon insert candidats" on public.candidats
  for insert to anon with check (true);

-- Bucket privé pour les CV (5 Mo max)
insert into storage.buckets (id, name, public, file_size_limit)
values ('cv', 'cv', false, 5242880)
on conflict (id) do nothing;

create policy "anon upload cv" on storage.objects
  for insert to anon with check (bucket_id = 'cv');
