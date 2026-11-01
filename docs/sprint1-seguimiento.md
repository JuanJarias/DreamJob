# Seguimiento Sprint 1, parte de Joshua

Responsable: Joshua Rivera (@JRivera340)
Rama de integracion: dev
Ultima actualizacion: 2026-10-31

Estados posibles: pendiente, en progreso, hecha

## #6 supabase/schema.sql: tablas y RLS

Estado: en progreso
Depende de: #5

- [x] Tabla empresas con id, nombre, descripcion, monograma, created_at
- [x] Tabla usuarios con id, nombre, email, ciudad, fecha_nacimiento, resumen_perfil, created_at
- [x] Tabla reclutadores con id, nombre, email, empresa_id, created_at
- [x] RLS activo en las tres tablas
- [x] Politicas de usuarios (select, insert, update propio)
- [x] Politicas de reclutadores (select, update propio, sin insert)
- [x] Politica de empresas (select de la empresa del reclutador autenticado, sin insert)
- [ ] Script corrido sin errores en el SQL Editor de Supabase

Verificacion: SQL Editor de Supabase.

Notas: schema.sql escrito en la rama feat/supabase-schema, PR #27. Falta correrlo en un proyecto Supabase real (depende de #5) para confirmar que no tiene errores.

## #7 RPC registrar_reclutador

Estado: en progreso
Depende de: #5, #6

- [x] Firma exacta con los 5 parametros text
- [x] security definer y search_path = public
- [x] Valida auth.uid(), lanza excepcion si es null
- [x] Inserta empresa antes que reclutador por la llave foranea
- [x] grant execute solo a authenticated
- [ ] Corrido sin errores en el SQL Editor
- [ ] Probado de verdad desde la app (ver #15)

Verificacion: SQL Editor y prueba funcional en #15.

Notas: funcion escrita en el mismo PR #27. Falta correrla en Supabase y probarla end to end registrando un reclutador real desde la app.

## #15 AuthRepository y AuthProvider reales

Estado: en progreso
Depende de: #5, #6, #7

- [x] Supabase.initialize en main.dart
- [x] auth_repository.dart con la interfaz y la implementacion real
- [x] fromMap y toMap en los modelos
- [x] AuthProvider reescrito sin cambiar su contrato publico
- [x] widget_test.dart migrado a FakeAuthRepository
- [x] flutter analyze limpio
- [x] flutter test en verde
- [ ] Probado con .env real, candidato y reclutador

Verificacion: flutter analyze, flutter test, prueba manual con Table Editor.

Notas: implementado en la rama feat/nucleo-auth, PR #28. flutter analyze sin issues y los 9 tests (3 de widget_test.dart mas 6 de auth_error_mapper_test.dart) pasan. Falta la prueba manual con un proyecto Supabase real, depende de #5.

## #16 Errores de Supabase en espanol

Estado: hecha
Depende de: #15

- [x] auth_error_mapper.dart con los casos de email duplicado, credenciales, password corta y sin conexion
- [x] auth_error_mapper_test.dart
- [x] flutter analyze limpio
- [ ] Probado en modo avion

Verificacion: flutter analyze, flutter test, prueba manual.

Notas: mapeo hecho contra los codigos reales de AuthException/PostgrestException del paquete gotrue 2.27.3 instalado (user_already_exists, email_exists, invalid_credentials, weak_password) mas deteccion de errores de red por texto. Cubierto con 6 tests offline en auth_error_mapper_test.dart, todos en verde. PR #28. La prueba manual en modo avion queda pendiente de tener la app corriendo contra Supabase real.

## #17 Sesion persistente y Splash

Estado: en progreso
Depende de: #15

- [x] redirect del router esperando a loading antes de decidir
- [x] SplashScreen simplificado
- [x] signOut limpia la sesion y vuelve a login
- [ ] Verificado cerrando y reabriendo la app, candidato y reclutador
- [ ] Prueba funcional de la RPC de #7 confirmada

Verificacion: cierre y reapertura real de la app.

Notas: redirect y Splash hechos en la rama feat/nucleo-auth, PR #28. flutter analyze y flutter test en verde. Falta la prueba real de cerrar y reabrir la app, depende de tener el proyecto Supabase de #5.

## #21 CONTRIBUTING, plantilla de PR y CI

Estado: en progreso
Depende de: ninguna

- [x] CONTRIBUTING.md
- [x] .github/pull_request_template.md
- [ ] .github/workflows/ci.yml
- [x] Link agregado en el README
- [ ] PR de prueba con el CI en verde

Verificacion: PR de prueba.

Notas: CONTRIBUTING.md, la plantilla de PR y el link en el README van en la rama docs/contributing-ci, PR #29. El workflow ci.yml esta escrito localmente pero no se pudo pushear: el token de gh no tiene el scope workflow. Falta que Joshua corra `gh auth refresh -s workflow` y aprobar en el navegador para poder subirlo.

## Bitacora

- 2026-10-31: creado este documento de seguimiento.
- 2026-10-31: escrito supabase/schema.sql con tablas, RLS y la rpc registrar_reclutador. PR #27 abierto contra dev, pendiente de correr en un proyecto Supabase real.
- 2026-10-31: AuthRepository real, AuthProvider conectado a Supabase, mapeo de errores en espanol y sesion persistente con splash simplificado. flutter analyze y flutter test (9 tests) en verde. PR #28 abierto contra dev, pendiente de probar con un proyecto Supabase real (depende de #5).
- 2026-10-31: CONTRIBUTING.md y plantilla de PR, PR #29 abierto contra dev. El workflow de CI queda pendiente de pushear por falta del scope workflow en el token de gh.
- 2026-10-31: todos los PR (#26, #27, #28, #29) quedan abiertos contra dev, pendientes de revision y merge. El sandbox no permite mergear PR sin revision humana.
