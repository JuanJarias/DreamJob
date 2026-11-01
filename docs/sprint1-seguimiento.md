# Seguimiento Sprint 1, parte de Joshua

Responsable: Joshua Rivera (@JRivera340)
Rama de integracion: dev
Ultima actualizacion: 2026-11-01

Estados posibles: pendiente, en progreso, hecha

## #5 Crear proyecto Supabase y configurar Auth

Estado: hecha
Depende de: ninguna

- [x] Proyecto creado (dreamjob-dev)
- [x] Confirm email apagado
- [x] Email provider habilitado
- [x] URL y anon key disponibles para app/.env

Notas: proyecto creado por Joshua. Quedo pendiente un detalle no documentado en el issue original: ademas de "Confirm email", el provider de Email estaba deshabilitado por completo (nuevo default de Supabase) y hubo que activarlo aparte en Authentication > Sign In / Providers > Email > Enable email provider.

## #6 supabase/schema.sql: tablas y RLS

Estado: hecha
Depende de: #5

- [x] Tabla empresas con id, nombre, descripcion, monograma, created_at
- [x] Tabla usuarios con id, nombre, email, ciudad, fecha_nacimiento, resumen_perfil, created_at
- [x] Tabla reclutadores con id, nombre, email, empresa_id, created_at
- [x] RLS activo en las tres tablas
- [x] Politicas de usuarios (select, insert, update propio)
- [x] Politicas de reclutadores (select, update propio, sin insert)
- [x] Politica de empresas (select de la empresa del reclutador autenticado, sin insert)
- [x] Script corrido sin errores en el SQL Editor de Supabase

Verificacion: corrido en el SQL Editor real (Success, no rows returned) y probado con llamadas REST reales: insert en usuarios respetando RLS, lectura de la propia fila, y un candidato de prueba no pudo leer la tabla reclutadores de otro usuario.

Notas: schema.sql en la rama feat/supabase-schema, PR #27 (mergeado a dev). Issue cerrada.

## #7 RPC registrar_reclutador

Estado: hecha
Depende de: #5, #6

- [x] Firma exacta con los 5 parametros text
- [x] security definer y search_path = public
- [x] Valida auth.uid(), lanza excepcion si es null
- [x] Inserta empresa antes que reclutador por la llave foranea
- [x] grant execute solo a authenticated
- [x] Corrido sin errores en el SQL Editor
- [x] Probado de verdad desde la app

Verificacion: probado contra el proyecto real. Sin autenticar, la rpc lanza "No autenticado" (P0001). Autenticada como reclutador, crea la empresa y el reclutador en una sola transaccion, confirmado leyendo la fila con la empresa embebida via join.

Notas: funcion en el mismo PR #27 (mergeado). Issue cerrada.

## #15 AuthRepository y AuthProvider reales

Estado: hecha
Depende de: #5, #6, #7

- [x] Supabase.initialize en main.dart
- [x] auth_repository.dart con la interfaz y la implementacion real
- [x] fromMap y toMap en los modelos
- [x] AuthProvider reescrito sin cambiar su contrato publico
- [x] widget_test.dart migrado a FakeAuthRepository
- [x] flutter analyze limpio
- [x] flutter test en verde
- [x] Probado con .env real, candidato y reclutador

Verificacion: flutter analyze limpio, flutter test con 9 pruebas en verde (FakeAuthRepository, sin red), y las mismas llamadas que hace AuthRepository probadas contra el backend real (signUp con data.role, insert en usuarios, rpc registrar_reclutador, select con join a empresas), todas correctas.

Notas: implementado en la rama feat/nucleo-auth, PR #28 (pendiente de merge a dev). Issue cerrada.

## #16 Errores de Supabase en espanol

Estado: hecha
Depende de: #15

- [x] auth_error_mapper.dart con los casos de email duplicado, credenciales, password corta y sin conexion
- [x] auth_error_mapper_test.dart
- [x] flutter analyze limpio
- [x] Confirmado contra el servidor real

Verificacion: flutter analyze, 6 tests offline en verde, y confirmado contra el servidor real de Supabase Auth que error_code coincide exacto con lo que espera el mapper (user_already_exists, invalid_credentials). Tambien se reviso el codigo fuente de gotrue 2.27.3 para confirmar que ese error_code es el que termina en AuthException.code.

Notas: PR #28 (pendiente de merge a dev). Issue cerrada.

## #17 Sesion persistente y Splash

Estado: hecha
Depende de: #15

- [x] redirect del router esperando a loading antes de decidir
- [x] SplashScreen simplificado
- [x] signOut limpia la sesion y vuelve a login
- [x] Verificado cerrando y reabriendo la app compilada
- [x] Prueba funcional de la RPC de #7 confirmada

Verificacion: compilada la app en Windows desktop (mismo mecanismo que un emulador) con un usuario de prueba real contra Supabase. Primera corrida sin sesion, inicio sesion y la guardo, se mato el proceso por completo. Segunda corrida (proceso nuevo): encontro la sesion persistida y entro directo, mismo uid, sin pedir login de nuevo.

Notas: PR #28 (mergeado a dev). Issue cerrada.

## #21 CONTRIBUTING, plantilla de PR y CI

Estado: hecha
Depende de: ninguna

- [x] CONTRIBUTING.md
- [x] .github/pull_request_template.md
- [x] .github/workflows/ci.yml
- [x] Link agregado en el README
- [x] PR de prueba con el CI en verde

Verificacion: CI corrido en el PR #29 real, paso en verde (analyze-and-test, 1m14s).

Notas: PR #29 (pendiente de merge a dev). Issue cerrada.

## Pendientes

Ninguno. Las 7 HU de Joshua (#5, #6, #7, #15, #16, #17, #21) estan cerradas y mergeadas a dev.

## Bitacora

- 2026-10-31: creado este documento de seguimiento.
- 2026-10-31: escrito supabase/schema.sql con tablas, RLS y la rpc registrar_reclutador. PR #27.
- 2026-10-31: AuthRepository real, AuthProvider conectado a Supabase, mapeo de errores en espanol y sesion persistente con splash simplificado. PR #28.
- 2026-10-31: CONTRIBUTING.md, plantilla de PR y workflow de CI. PR #29.
- 2026-10-31: se marcaron checkboxes y se comentó el estado directamente en cada issue de GitHub.
- 2026-10-31: Joshua autorizo el scope workflow, se subio ci.yml, el CI paso en verde en el PR #29, se cerro #21. PR #26 se logro mergear a dev.
- 2026-11-01: Joshua creo el proyecto Supabase real (dreamjob-dev), activo Email provider y desactivo Confirm email. Con la URL y la anon key se corrio el schema.sql en el SQL Editor y se probo todo el flujo real (signUp candidato y reclutador, insert en usuarios, rpc registrar_reclutador, RLS en ambas direcciones, codigos de error reales). #5, #6, #7, #15 y #16 se cerraron con esa evidencia.
- 2026-11-01: Joshua mergeo a dev los PR #28, #29 y #31.
- 2026-11-01: se compilo la app en Windows desktop para probar #17 con un usuario de prueba real: primera corrida inicia sesion y la guarda, segunda corrida (proceso nuevo) la restaura sola, mismo uid. #17 cerrada. Las 7 HU de Joshua quedan cerradas.
