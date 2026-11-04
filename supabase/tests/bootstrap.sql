-- Solo para PostgreSQL vacío de pruebas: reproduce los contratos mínimos de Supabase Auth.
create role authenticated nologin;
create schema auth;
create table auth.users (id uuid primary key, email text);
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
grant usage on schema auth, public to authenticated;
alter default privileges in schema public
  grant select, insert, update, delete on tables to authenticated;
