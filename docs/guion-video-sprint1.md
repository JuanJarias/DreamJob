# Guion del video de demostración — Sprint 1 (Autenticación)

**Duración máxima:** 2:00 minutos
**Entorno:** Emulador Android con la aplicación corriendo conectada a Supabase (`flutter run --dart-define-from-file=.env`).
**Nota de seguridad:** No mostrar en pantalla el contenido de `app/.env` ni claves privadas.

---

## Estructura por tiempos

| Tiempo | Escena en pantalla | Qué se dice / se muestra |
|---|---|---|
| **0:00 – 0:10** | Pantalla de inicio de sesión (`/login`) | Presentación breve: nombre de la aplicación (**DreamJob**), integrantes del equipo (Joshua Rivera, Juan José Arias y Ange) y objetivo del Sprint 1: autenticación con Supabase para candidato y reclutador, perfil por rol y sesión persistente. |
| **0:10 – 0:50** | `/login` -> `/register` -> `/register/candidato` -> `/profile` | **Flujo Candidato:** tocar *"¿No tienes cuenta? Crear cuenta"*, elegir *"Soy candidato"*, completar nombre, correo, contraseña (mínimo 8 caracteres), confirmación, ciudad, fecha de nacimiento en el calendario y resumen. Tocar *"Crear cuenta"* y mostrar cómo el router redirige automáticamente a `/profile` con las iniciales, edad calculada, ciudad y resumen. |
| **0:50 – 1:00** | `/profile` -> `/login` -> `/profile` | **Reingreso Candidato:** tocar *"Cerrar sesión"* (vuelve a `/login`), ingresar el correo y contraseña recién registrados, tocar *"Iniciar sesión"* y mostrar que carga nuevamente el perfil del candidato desde Supabase. |
| **1:00 – 1:40** | `/login` -> `/register` -> `/register/reclutador` -> `/profile` | **Flujo Reclutador:** cerrar sesión, ir a *"Crear cuenta"* -> *"Soy reclutador"*. Completar *"Tus datos"* y *"Tu empresa"* (nombre de la empresa, descripción y monograma de 1 a 3 letras mostrando la vista previa en mayúsculas). Tocar *"Crear cuenta"* y mostrar en `/profile` los datos del reclutador junto con la tarjeta de la empresa creada mediante la función RPC `registrar_reclutador`. |
| **1:40 – 1:50** | `/profile` -> `/login` | **Manejo de error:** tocar *"Cerrar sesión"*, intentar iniciar sesión con una contraseña equivocada y mostrar el banner de error en español (*"Correo electrónico o contraseña incorrectos"*). Luego iniciar sesión con las credenciales correctas. |
| **1:50 – 2:00** | Cierre y reapertura de la app -> `/splash` -> `/profile` | **Sesión persistente:** cerrar por completo la aplicación desde las apps recientes del emulador y volver a abrirla. Mostrar que `/splash` restaura la sesión activa de Supabase y entra directo a `/profile` sin pedir login. Cierre del video. |
