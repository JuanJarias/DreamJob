-- Ejecutar con psql como administrador en una base de pruebas con schema.sql aplicado.
-- Todas las filas de prueba se revierten al terminar.
\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email) values
  ('10000000-0000-0000-0000-000000000001', 'rls-a@example.com'),
  ('10000000-0000-0000-0000-000000000002', 'rls-b@example.com');
insert into public.usuarios (id, nombre, email, ciudad, fecha_nacimiento) values
  ('10000000-0000-0000-0000-000000000001', 'A', 'rls-a@example.com', 'Cali', '2000-01-01'),
  ('10000000-0000-0000-0000-000000000002', 'B', 'rls-b@example.com', 'Bogotá', '2000-01-01');
insert into public.empresas (id, nombre, monograma) values
  ('20000000-0000-0000-0000-000000000001', 'Empresa A', 'A'),
  ('20000000-0000-0000-0000-000000000002', 'Empresa B', 'B');
insert into public.reclutadores (id, nombre, email, empresa_id) values
  ('10000000-0000-0000-0000-000000000001', 'A', 'rls-a@example.com', '20000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', 'B', 'rls-b@example.com', '20000000-0000-0000-0000-000000000002');

set local role authenticated;
set local request.jwt.claim.sub = '10000000-0000-0000-0000-000000000001';

do $$
declare
  v_count integer;
begin
  assert (select count(*) from public.usuarios) = 1, 'Un candidato puede leer otra cuenta';
  assert (select count(*) from public.reclutadores) = 1, 'Un reclutador puede leer otra cuenta';
  assert (select count(*) from public.empresas) = 1, 'Un reclutador puede leer otra empresa';

  update public.usuarios set nombre = 'Intruso'
    where id = '10000000-0000-0000-0000-000000000002';
  get diagnostics v_count = row_count;
  assert v_count = 0, 'Un candidato puede editar otra cuenta';

  update public.reclutadores set nombre = 'Intruso'
    where id = '10000000-0000-0000-0000-000000000002';
  get diagnostics v_count = row_count;
  assert v_count = 0, 'Un reclutador puede editar otra cuenta';

  update public.reclutadores set nombre = 'Nombre actualizado' where id = auth.uid();
  get diagnostics v_count = row_count;
  assert v_count = 1, 'El reclutador debe poder editar su nombre';

  begin
    update public.reclutadores
      set empresa_id = '20000000-0000-0000-0000-000000000002'
      where id = auth.uid();
    raise exception 'El reclutador puede cambiar su empresa y leer datos ajenos';
  exception when insufficient_privilege then
    null;
  end;

  assert not exists (select 1 from public.empresas where nombre = 'Empresa B'),
    'La empresa ajena debe seguir oculta';

  update public.empresas
    set nombre = 'Empresa A Actualizada',
        descripcion = 'Nueva descripción de prueba',
        monograma = 'EAA'
    where id = '20000000-0000-0000-0000-000000000001';
  get diagnostics v_count = row_count;
  assert v_count = 1, 'El reclutador debe poder actualizar su propia empresa';

  update public.empresas
    set nombre = 'Empresa B Manipulada'
    where id = '20000000-0000-0000-0000-000000000002';
  get diagnostics v_count = row_count;
  assert v_count = 0, 'El reclutador no debe poder actualizar empresas ajenas';

  -- Sprint 2: pruebas RLS de vacantes, tecnologías y swipes
  assert (select count(*) from public.tecnologias) >= 12,
    'El catálogo inicial de tecnologías debe estar disponible';

  insert into public.vacantes (
    id, empresa_id, reclutador_id, titulo, descripcion, ubicacion, modalidad
  ) values (
    '30000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Desarrollador Flutter Jr',
    'Desarrollo de funcionalidades móviles',
    'Cali',
    'Híbrido'
  );

  begin
    update public.vacantes
      set empresa_id = '20000000-0000-0000-0000-000000000002'
      where id = '30000000-0000-0000-0000-000000000001';
    raise exception 'El reclutador no debe poder reasignar empresa_id de una vacante';
  exception when insufficient_privilege then
    null;
  end;
end;
$$;

-- Cambiar a usuario B para verificar visibilidad de vacante activa, aislamiento de edición y swipes
set local request.jwt.claim.sub = '10000000-0000-0000-0000-000000000002';

do $$
declare
  v_count integer;
begin
  assert (select count(*) from public.vacantes) = 1,
    'Un usuario autenticado debe poder ver vacantes activas';
  assert exists (
    select 1 from public.empresas
    where id = '20000000-0000-0000-0000-000000000001'
      and nombre = 'Empresa A Actualizada'
  ),
    'La empresa con vacante activa debe ser visible para candidatos';

  update public.vacantes set titulo = 'Intruso'
    where id = '30000000-0000-0000-0000-000000000001';
  get diagnostics v_count = row_count;
  assert v_count = 0, 'Otro reclutador no debe poder editar vacante ajena';

  begin
    insert into public.vacantes (
      empresa_id, reclutador_id, titulo, descripcion, ubicacion, modalidad
    ) values (
      '20000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000002',
      'Vacante intrusa',
      'Intento no autorizado',
      'Bogotá',
      'Remoto'
    );
    raise exception 'No debe permitir crear vacantes para otra empresa';
  exception when insufficient_privilege then
    null;
  end;

  insert into public.swipes (usuario_id, vacante_id, direccion)
  values (
    '10000000-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000001',
    'derecha'
  );
  assert (select count(*) from public.swipes) = 1,
    'El candidato debe poder registrar y consultar su propio swipe';

  begin
    insert into public.swipes (usuario_id, vacante_id, direccion)
    values (
      '10000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000001',
      'izquierda'
    );
    raise exception 'No debe permitir insertar swipes a nombre de otro usuario';
  exception when insufficient_privilege then
    null;
  end;
end;
$$;

rollback;
