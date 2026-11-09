-- Back-office : seul cet email peut lire / supprimer les candidatures et les CV.
-- (Même si quelqu'un crée un compte, il n'aura aucun accès.)

create policy "admin read candidats" on public.candidats
  for select to authenticated
  using ((auth.jwt() ->> 'email') = 'direction@talentys.info');

create policy "admin delete candidats" on public.candidats
  for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'direction@talentys.info');

create policy "admin read cv" on storage.objects
  for select to authenticated
  using (bucket_id = 'cv' and (auth.jwt() ->> 'email') = 'direction@talentys.info');
