-- Durcissement : à lancer dans Supabase > SQL Editor (déjà appliqué)

-- 1. Limites de taille / format sur les formulaires publics
alter table public.candidats
  add constraint candidats_limits check (
    char_length(prenom) between 1 and 80 and char_length(nom) between 1 and 80
    and char_length(tel) between 6 and 30
    and char_length(email) between 5 and 160 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$'
    and coalesce(char_length(niveau),0) <= 80 and coalesce(char_length(cv_path),0) <= 250
  );

alter table public.entreprises
  add constraint entreprises_limits check (
    char_length(entreprise) between 1 and 160 and char_length(prenom) between 1 and 80 and char_length(nom) between 1 and 80
    and char_length(tel) between 6 and 30
    and char_length(email) between 5 and 160 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$'
    and coalesce(char_length(precisions),0) <= 2000 and coalesce(char_length(criteres),0) <= 1000
    and coalesce(char_length(qualites),0) <= 1000 and coalesce(char_length(postes),0) <= 500
    and coalesce(char_length(siret),0) <= 20 and coalesce(char_length(cp),0) <= 10
    and coalesce(char_length(secteur),0) <= 200 and coalesce(char_length(fonction),0) <= 120
    and coalesce(char_length(source),0) <= 120 and coalesce(char_length(campagne),0) <= 160
  );

-- 2. Bucket CV : uniquement des documents / images, 5 Mo max
update storage.buckets set
  allowed_mime_types = array['application/pdf','application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document','image/jpeg','image/png'],
  file_size_limit = 5242880
where id = 'cv';

-- 3. Inscriptions fermées : seul le compte admin peut exister
create or replace function public.only_admin_signup() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if lower(new.email) <> 'direction@talentys.info' then
    raise exception 'Inscriptions fermées';
  end if;
  return new;
end $$;
revoke all on function public.only_admin_signup() from public, anon, authenticated;
drop trigger if exists only_admin_signup on auth.users;
create trigger only_admin_signup before insert on auth.users
  for each row execute function public.only_admin_signup();

-- 4. L'admin peut supprimer les CV (ex. quand il supprime une candidature)
create policy "admin delete cv" on storage.objects
  for delete to authenticated
  using (bucket_id = 'cv' and (auth.jwt() ->> 'email') = 'direction@talentys.info');
