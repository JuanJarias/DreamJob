# Guion del video de demostración — Sprint 2 (Oferta y Descubrimiento)

**Duración máxima:** 2:30 minutos
**Entorno:** Aplicación conectada a Supabase (`flutter run --dart-define-from-file=.env`) con `supabase/schema.sql` y las cuentas/vacantes demo cargadas (`reclutador.demo@dreamjob.app` y `candidato.demo@dreamjob.app`).
**Nota de seguridad:** No mostrar en pantalla el contenido de `app/.env` ni claves privadas.

---

## Estructura por tiempos

| Tiempo | Escena en pantalla | Qué se dice / se muestra |
|---|---|---|
| **0:00 – 0:15** | Pantalla de inicio de sesión (`/login`) | Presentación breve del **Sprint 2 — Oferta y Descubrimiento**: objetivo del sprint (publicación de vacantes por reclutadores y descubrimiento con swipes y afinidad para candidatos). |
| **0:15 – 0:55** | `/home` (Reclutador) -> *Vacantes* -> `/vacancies/new` -> `/vacancies/edit` | **Flujo Reclutador:** iniciar sesión con `reclutador.demo@dreamjob.app`. Mostrar `HomeShell` con 2 pestañas (*Vacantes* y *Perfil*), las vacantes publicadas de `NovaTech Labs`, crear una nueva vacante (validando campos y tecnologías), editarla y cambiar su estado (`Activa` / `Pausada`). |
| **0:55 – 1:15** | *Perfil* -> `/profile/edit` -> *Cerrar sesión* | **Edición de perfil y empresa:** editar la descripción de la empresa en `EditProfileScreen`, guardar y verificar el reflejo inmediato en `ProfileSummaryScreen`. Cerrar sesión hacia `/login`. |
| **1:15 – 1:40** | `/home` (Candidato) -> *Perfil* -> `/profile/preferences` | **Preferencias del candidato:** iniciar sesión con `candidato.demo@dreamjob.app`. Mostrar `HomeShell` con 3 pestañas (*Deck*, *Postulaciones*, *Perfil*). Entrar a *Preferencias laborales*, seleccionar modalidad (`Remoto`), nivel (`Semi-Senior`), expectativa salarial y tecnologías (`Flutter`, `Dart`) y guardar. |
| **1:40 – 2:10** | *Deck* (`DeckScreen`) -> `/vacancies/detail` (`JobDetailScreen`) | **Deck, afinidad, swipes y deshacer:** mostrar las tarjetas ordenadas por afinidad con tecnologías coincidentes resaltadas y razones verdes. Deslizar a la izquierda (*Omitir*) y pulsar **Deshacer** para restaurar la tarjeta al tope. Tocar la tarjeta para abrir `JobDetailScreen` y pulsar **Postular**. |
| **2:10 – 2:30** | *Postulaciones* (`CandidateLikedJobsScreen`) | **Bandeja de interés e impacto en reclutador:** ir al tab *Postulaciones*, mostrar la vacante postulada con estado *En revisión* y fecha, y abrir su detalle en modo lectura. Cierre del video. |
