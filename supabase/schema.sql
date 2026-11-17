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

-- RLS protege la fila, pero cambiar empresa_id permitiría leer otra empresa.
revoke update on public.reclutadores from authenticated;
grant update (nombre, email) on public.reclutadores to authenticated;

drop policy if exists "empresas_select_de_mi_reclutador" on public.empresas;
create policy "empresas_select_de_mi_reclutador" on public.empresas
  for select using (
    id in (select empresa_id from public.reclutadores where id = auth.uid())
  );

drop policy if exists "empresas_update_de_mi_reclutador" on public.empresas;
create policy "empresas_update_de_mi_reclutador" on public.empresas
  for update using (
    id in (select empresa_id from public.reclutadores where id = auth.uid())
  )
  with check (
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

-- ============================================================================
-- Sprint 2: Preferencias de candidato, tecnologías, vacantes y swipes
-- ============================================================================

alter table public.usuarios
  add column if not exists modalidad_preferida text;

alter table public.usuarios
  add column if not exists salario_minimo numeric;

alter table public.usuarios
  add column if not exists seniority text;

create table if not exists public.tecnologias (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  categoria text not null default 'General',
  created_at timestamptz not null default now()
);

insert into public.tecnologias (nombre, categoria) values
  ('Flutter', 'Móvil'),
  ('Dart', 'Móvil'),
  ('Kotlin', 'Móvil'),
  ('Python', 'Backend / Datos'),
  ('Go', 'Backend'),
  ('Node.js', 'Backend'),
  ('Java', 'Backend'),
  ('React', 'Frontend'),
  ('TypeScript', 'Frontend'),
  ('PostgreSQL', 'Bases de datos'),
  ('SQL', 'Bases de datos'),
  ('AWS', 'Cloud / DevOps'),
  ('Docker', 'Cloud / DevOps'),
  ('Git', 'Herramientas')
on conflict (nombre) do nothing;

create table if not exists public.usuario_tecnologias (
  usuario_id uuid not null references public.usuarios(id) on delete cascade,
  tecnologia_id uuid not null references public.tecnologias(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (usuario_id, tecnologia_id)
);

create table if not exists public.vacantes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  reclutador_id uuid not null references public.reclutadores(id) on delete cascade,
  titulo text not null,
  descripcion text not null,
  ubicacion text not null,
  modalidad text not null check (modalidad in ('Remoto', 'Híbrido', 'Presencial')),
  salario_min numeric,
  salario_max numeric,
  moneda text not null default 'COP',
  seniority text not null default 'Practicante / Junior'
    check (seniority in ('Practicante / Junior', 'Semi-Senior', 'Senior')),
  estado text not null default 'activa'
    check (estado in ('activa', 'pausada', 'cerrada')),
  created_at timestamptz not null default now(),
  check (salario_max is null or salario_min is null or salario_max >= salario_min)
);

create table if not exists public.vacante_tecnologias (
  vacante_id uuid not null references public.vacantes(id) on delete cascade,
  tecnologia_id uuid not null references public.tecnologias(id) on delete cascade,
  primary key (vacante_id, tecnologia_id)
);

create table if not exists public.swipes (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references public.usuarios(id) on delete cascade,
  vacante_id uuid not null references public.vacantes(id) on delete cascade,
  direccion text not null check (direccion in ('derecha', 'izquierda')),
  created_at timestamptz not null default now(),
  unique (usuario_id, vacante_id)
);

alter table public.tecnologias enable row level security;
alter table public.usuario_tecnologias enable row level security;
alter table public.vacantes enable row level security;
alter table public.vacante_tecnologias enable row level security;
alter table public.swipes enable row level security;

-- Catálogo de tecnologías: lectura para autenticados
drop policy if exists "tecnologias_select_autenticados" on public.tecnologias;
create policy "tecnologias_select_autenticados" on public.tecnologias
  for select to authenticated using (true);

-- Tecnologías del candidato: gestión solo para el dueño
drop policy if exists "usuario_tecnologias_select_propio" on public.usuario_tecnologias;
create policy "usuario_tecnologias_select_propio" on public.usuario_tecnologias
  for select using (usuario_id = auth.uid());

drop policy if exists "usuario_tecnologias_insert_propio" on public.usuario_tecnologias;
create policy "usuario_tecnologias_insert_propio" on public.usuario_tecnologias
  for insert with check (usuario_id = auth.uid());

drop policy if exists "usuario_tecnologias_delete_propio" on public.usuario_tecnologias;
create policy "usuario_tecnologias_delete_propio" on public.usuario_tecnologias
  for delete using (usuario_id = auth.uid());

-- Empresas con vacantes activas visibles para usuarios autenticados
drop policy if exists "empresas_select_con_vacante_activa" on public.empresas;
create policy "empresas_select_con_vacante_activa" on public.empresas
  for select to authenticated using (
    exists (
      select 1 from public.vacantes v
      where v.empresa_id = empresas.id and v.estado = 'activa'
    )
  );

-- Vacantes: activas visibles para autenticados, propias visibles y editables para reclutadores de la empresa
drop policy if exists "vacantes_select_activas_o_propias" on public.vacantes;
create policy "vacantes_select_activas_o_propias" on public.vacantes
  for select to authenticated using (
    estado = 'activa'
    or empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
  );

drop policy if exists "vacantes_insert_propia_empresa" on public.vacantes;
create policy "vacantes_insert_propia_empresa" on public.vacantes
  for insert with check (
    reclutador_id = auth.uid()
    and empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
  );

drop policy if exists "vacantes_update_propia_empresa" on public.vacantes;
create policy "vacantes_update_propia_empresa" on public.vacantes
  for update using (
    empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
  )
  with check (
    empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
  );

revoke update on public.vacantes from authenticated;
grant update (
  titulo,
  descripcion,
  ubicacion,
  modalidad,
  salario_min,
  salario_max,
  moneda,
  seniority,
  estado
) on public.vacantes to authenticated;

-- Tecnologías por vacante
drop policy if exists "vacante_tecnologias_select" on public.vacante_tecnologias;
create policy "vacante_tecnologias_select" on public.vacante_tecnologias
  for select to authenticated using (
    exists (
      select 1 from public.vacantes v
      where v.id = vacante_id
        and (
          v.estado = 'activa'
          or v.empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
        )
    )
  );

drop policy if exists "vacante_tecnologias_insert" on public.vacante_tecnologias;
create policy "vacante_tecnologias_insert" on public.vacante_tecnologias
  for insert with check (
    exists (
      select 1 from public.vacantes v
      where v.id = vacante_id
        and v.empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
    )
  );

drop policy if exists "vacante_tecnologias_delete" on public.vacante_tecnologias;
create policy "vacante_tecnologias_delete" on public.vacante_tecnologias
  for delete using (
    exists (
      select 1 from public.vacantes v
      where v.id = vacante_id
        and v.empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
    )
  );

-- Swipes: el candidato administra sus propios swipes; el reclutador ve los de su empresa
drop policy if exists "swipes_select_propio_o_reclutador" on public.swipes;
create policy "swipes_select_propio_o_reclutador" on public.swipes
  for select using (
    usuario_id = auth.uid()
    or exists (
      select 1 from public.vacantes v
      where v.id = vacante_id
        and v.empresa_id in (select empresa_id from public.reclutadores where id = auth.uid())
    )
  );

drop policy if exists "swipes_insert_propio" on public.swipes;
create policy "swipes_insert_propio" on public.swipes
  for insert with check (
    usuario_id = auth.uid()
    and exists (
      select 1 from public.vacantes v
      where v.id = vacante_id and v.estado = 'activa'
    )
  );

drop policy if exists "swipes_delete_propio" on public.swipes;
create policy "swipes_delete_propio" on public.swipes
  for delete using (usuario_id = auth.uid());
