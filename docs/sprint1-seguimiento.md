# Seguimiento Sprint 1, parte de Joshua

Responsable: Joshua Rivera (@JRivera340)
Rama de integracion: dev
Ultima actualizacion: 2026-10-31

Estados posibles: pendiente, en progreso, hecha

## #6 supabase/schema.sql: tablas y RLS

Estado: pendiente
Depende de: #5

- [ ] Tabla empresas con id, nombre, descripcion, monograma, created_at
- [ ] Tabla usuarios con id, nombre, email, ciudad, fecha_nacimiento, resumen_perfil, created_at
- [ ] Tabla reclutadores con id, nombre, email, empresa_id, created_at
- [ ] RLS activo en las tres tablas
- [ ] Politicas de usuarios (select, insert, update propio)
- [ ] Politicas de reclutadores (select, update propio, sin insert)
- [ ] Politica de empresas (select de la empresa del reclutador autenticado, sin insert)
- [ ] Script corrido sin errores en el SQL Editor de Supabase

Verificacion: SQL Editor de Supabase.

Notas:

## #7 RPC registrar_reclutador

Estado: pendiente
Depende de: #5, #6

- [ ] Firma exacta con los 5 parametros text
- [ ] security definer y search_path = public
- [ ] Valida auth.uid(), lanza excepcion si es null
- [ ] Inserta empresa antes que reclutador por la llave foranea
- [ ] grant execute solo a authenticated
- [ ] Corrido sin errores en el SQL Editor
- [ ] Probado de verdad desde la app (ver #15)

Verificacion: SQL Editor y prueba funcional en #15.

Notas:

## #15 AuthRepository y AuthProvider reales

Estado: pendiente
Depende de: #5, #6, #7

- [ ] Supabase.initialize en main.dart
- [ ] auth_repository.dart con la interfaz y la implementacion real
- [ ] fromMap y toMap en los modelos
- [ ] AuthProvider reescrito sin cambiar su contrato publico
- [ ] widget_test.dart migrado a FakeAuthRepository
- [ ] flutter analyze limpio
- [ ] flutter test en verde
- [ ] Probado con .env real, candidato y reclutador

Verificacion: flutter analyze, flutter test, prueba manual con Table Editor.

Notas:

## #16 Errores de Supabase en espanol

Estado: pendiente
Depende de: #15

- [ ] auth_error_mapper.dart con los casos de email duplicado, credenciales, password corta y sin conexion
- [ ] auth_error_mapper_test.dart
- [ ] flutter analyze limpio
- [ ] Probado en modo avion

Verificacion: flutter analyze, flutter test, prueba manual.

Notas:

## #17 Sesion persistente y Splash

Estado: pendiente
Depende de: #15

- [ ] redirect del router esperando a loading antes de decidir
- [ ] SplashScreen simplificado
- [ ] signOut limpia la sesion y vuelve a login
- [ ] Verificado cerrando y reabriendo la app, candidato y reclutador
- [ ] Prueba funcional de la RPC de #7 confirmada

Verificacion: cierre y reapertura real de la app.

Notas:

## #21 CONTRIBUTING, plantilla de PR y CI

Estado: pendiente
Depende de: ninguna

- [ ] CONTRIBUTING.md
- [ ] .github/pull_request_template.md
- [ ] .github/workflows/ci.yml
- [ ] Link agregado en el README
- [ ] PR de prueba con el CI en verde

Verificacion: PR de prueba.

Notas:

## Bitacora

- 2026-10-31: creado este documento de seguimiento.
