-- Script idempotente de datos de demostración para el Sprint 2 (HU-12).
-- Ejecutar en el SQL Editor de Supabase después de haber aplicado supabase/schema.sql
-- y de haber creado las cuentas demo (laura.demo@dreamjob.co y carlos.demo@dreamjob.co).

do $$
declare
  v_rec_id uuid;
  v_emp_id uuid;
  v_cand_id uuid;
  v_vac1 uuid := '40000000-0000-0000-0000-000000000001';
  v_vac2 uuid := '40000000-0000-0000-0000-000000000002';
  v_vac3 uuid := '40000000-0000-0000-0000-000000000003';
  v_vac4 uuid := '40000000-0000-0000-0000-000000000004';
  v_flutter uuid;
  v_dart uuid;
  v_pg uuid;
  v_docker uuid;
  v_python uuid;
begin
  select id, empresa_id into v_rec_id, v_emp_id
  from public.reclutadores
  where lower(email) in ('reclutador.demo@dreamjob.app', 'laura.demo@dreamjob.co')
  limit 1;

  if v_rec_id is null then
    raise notice 'No se encontró la cuenta demo de reclutadora (reclutador.demo@dreamjob.app).';
  else
    select id into v_flutter from public.tecnologias where nombre = 'Flutter';
    select id into v_dart from public.tecnologias where nombre = 'Dart';
    select id into v_pg from public.tecnologias where nombre = 'PostgreSQL';
    select id into v_docker from public.tecnologias where nombre = 'Docker';
    select id into v_python from public.tecnologias where nombre = 'Python';

    insert into public.vacantes (
      id, empresa_id, reclutador_id, titulo, descripcion, ubicacion,
      modalidad, salario_min, salario_max, moneda, seniority, estado
    ) values
      (
        v_vac1, v_emp_id, v_rec_id,
        'Desarrollador Flutter Semi-Senior',
        'Construir experiencias móviles fluidas en Flutter integradas con Supabase y pruebas automatizadas.',
        'Cali, Colombia', 'Remoto', 4500000, 6500000, 'COP', 'Semi-Senior', 'activa'
      ),
      (
        v_vac2, v_emp_id, v_rec_id,
        'Ingeniero Mobile Junior',
        'Acompañar el desarrollo de nuevas pantallas en Dart y Flutter con diseño limpio y consumo de APIs.',
        'Medellín, Colombia', 'Híbrido', 2800000, 3800000, 'COP', 'Practicante / Junior', 'activa'
      ),
      (
        v_vac3, v_emp_id, v_rec_id,
        'Backend & Supabase Engineer',
        'Modelar esquemas PostgreSQL, políticas RLS seguras y funciones RPC de alto rendimiento.',
        'Bogotá, Colombia', 'Remoto', 5500000, 7500000, 'COP', 'Semi-Senior', 'activa'
      ),
      (
        v_vac4, v_emp_id, v_rec_id,
        'Tech Lead Mobile & Cloud',
        'Liderar arquitectura móvil en Flutter, CI/CD con Docker y mentoría técnica del equipo.',
        'Cali, Colombia', 'Presencial', 8000000, 11000000, 'COP', 'Senior', 'activa'
      )
    on conflict (id) do nothing;

    insert into public.vacante_tecnologias (vacante_id, tecnologia_id)
    select x.vacante_id, x.tecnologia_id
    from (
      values
        (v_vac1, v_flutter),
        (v_vac1, v_dart),
        (v_vac2, v_flutter),
        (v_vac2, v_dart),
        (v_vac3, v_pg),
        (v_vac3, v_python),
        (v_vac4, v_flutter),
        (v_vac4, v_docker)
    ) as x(vacante_id, tecnologia_id)
    where x.tecnologia_id is not null
    on conflict do nothing;
  end if;

  select id into v_cand_id
  from public.usuarios
  where lower(email) in ('candidato.demo@dreamjob.app', 'carlos.demo@dreamjob.co')
  limit 1;

  if v_cand_id is not null then
    update public.usuarios
    set modalidad_preferida = 'Remoto',
        salario_minimo = 4000000,
        seniority = 'Semi-Senior'
    where id = v_cand_id;

    insert into public.usuario_tecnologias (usuario_id, tecnologia_id)
    select v_cand_id, t.id
    from public.tecnologias t
    where t.nombre in ('Flutter', 'Dart', 'PostgreSQL')
    on conflict do nothing;
  end if;
end;
$$;
