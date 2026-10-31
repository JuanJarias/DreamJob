create extension if not exists pgcrypto;

create table if not exists public.empresas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  descripcion text,
  monograma text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  email text not null,
  ciudad text not null,
  fecha_nacimiento date not null,
  resumen_perfil text,
  created_at timestamptz not null default now()
);

create table if not exists public.reclutadores (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  email text not null,
  empresa_id uuid not null references public.empresas(id),
  created_at timestamptz not null default now()
);

alter table public.empresas enable row level security;
alter table public.usuarios enable row level security;
alter table public.reclutadores enable row level security;

drop policy if exists "usuarios_select_propio" on public.usuarios;
create policy "usuarios_select_propio" on public.usuarios
  for select using (id = auth.uid());

drop policy if exists "usuarios_insert_propio" on public.usuarios;
create policy "usuarios_insert_propio" on public.usuarios
  for insert with check (id = auth.uid());

drop policy if exists "usuarios_update_propio" on public.usuarios;
create policy "usuarios_update_propio" on public.usuarios
  for update using (id = auth.uid());

drop policy if exists "reclutadores_select_propio" on public.reclutadores;
create policy "reclutadores_select_propio" on public.reclutadores
  for select using (id = auth.uid());

drop policy if exists "reclutadores_update_propio" on public.reclutadores;
create policy "reclutadores_update_propio" on public.reclutadores
  for update using (id = auth.uid());

drop policy if exists "empresas_select_de_mi_reclutador" on public.empresas;
create policy "empresas_select_de_mi_reclutador" on public.empresas
  for select using (
    id in (select empresa_id from public.reclutadores where id = auth.uid())
  );
