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

create or replace function public.registrar_reclutador(
  p_nombre text,
  p_email text,
  p_empresa_nombre text,
  p_empresa_descripcion text,
  p_empresa_monograma text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_empresa_id uuid;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  insert into public.empresas (nombre, descripcion, monograma)
  values (p_empresa_nombre, p_empresa_descripcion, p_empresa_monograma)
  returning id into v_empresa_id;

  insert into public.reclutadores (id, nombre, email, empresa_id)
  values (v_uid, p_nombre, p_email, v_empresa_id);
end;
$$;

revoke all on function public.registrar_reclutador(text, text, text, text, text) from public;
grant execute on function public.registrar_reclutador(text, text, text, text, text) to authenticated;
