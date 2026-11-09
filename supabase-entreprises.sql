-- Formulaire /entreprise : demandes de recrutement des entreprises
create table if not exists public.entreprises (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  entreprise text not null,
  siret text,
  taille text,
  aide text,
  prenom text not null,
  nom text not null,
  fonction text,
  tel text not null,
  email text not null,
  postes text,
  secteur text,
  nombre text,
  demarrage text,
  cp text,
  jour text,
  criteres text,
  qualites text,
  precisions text,
  rdv text,
  source text,
  campagne text
);

alter table public.entreprises enable row level security;

-- Le site (anon) peut seulement INSERER.
create policy "anon insert entreprises" on public.entreprises
  for insert to anon with check (true);

-- Seul direction@talentys.info peut lire / supprimer.
create policy "admin read entreprises" on public.entreprises
  for select to authenticated
  using ((auth.jwt() ->> 'email') = 'direction@talentys.info');

create policy "admin delete entreprises" on public.entreprises
  for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'direction@talentys.info');
