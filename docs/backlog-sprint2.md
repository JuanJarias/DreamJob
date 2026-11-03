# Backlog del Sprint 2 — DreamJob

## 1. Alcance del Sprint 2

Con el módulo de autenticación y registro por rol implementado en el **Sprint 1 (`v1.0.0`)**, el **Sprint 2** aborda el flujo central de oferta y descubrimiento entre reclutadores y candidatos como paso previo al **MVP del Sprint 3**:

- **Sprint 1 (Completado):** Registro de candidato y reclutador (con creación de empresa), inicio de sesión, sesión persistente y resumen inicial de perfil.
- **Sprint 2 (Actual):** Navegación principal diferenciada por rol, edición de perfil y preferencias laborales/tecnologías del candidato, publicación y gestión de vacantes por parte del reclutador, y exploración del mazo de vacantes (*Deck*) con deslizamiento (*swipe* para postular u omitir) y vista de detalle.
- **Sprint 3 (MVP):** Revisión de candidatos interesados por parte del reclutador para concretar el match mutuo, seguimiento de postulaciones por estado, agenda de entrevistas y módulo de práctica con el Coach.

---

## 2. Historias de Usuario y Criterios de Aceptación

### Módulo 1 — Base de Datos, Estado y Navegación Principal

#### HU-01 — Modelo de datos de vacantes, tecnologías, preferencias y swipes
- **Rol:** Sistema / Base de datos
- **Historia:** Como equipo de desarrollo, queremos ampliar el esquema de Supabase con las tablas de tecnologías, preferencias del candidato, vacantes y swipes junto con sus políticas RLS, para almacenar de forma segura las ofertas laborales y las decisiones de los usuarios.
- **Criterios de aceptación:**
  1. Se crean en `supabase/schema.sql` las tablas `tecnologias`, `usuario_tecnologias`, `vacantes`, `vacante_tecnologias` y `swipes`, y se agregan los campos de preferencias en `usuarios` (`modalidad_preferida`, `salario_minimo`, `seniority`).
  2. Todas las tablas nuevas cuentan con políticas RLS activas según el rol: lectura de vacantes activas y catálogo de tecnologías para usuarios autenticados, gestión de vacantes restringida a los reclutadores de la empresa correspondiente y gestión de preferencias/swipes restringida al propio candidato (`auth.uid()`).
  3. Incluye un catálogo inicial precargado con las tecnologías principales para asociarlas tanto a perfiles como a vacantes.

#### HU-02 — Navegación principal con barra inferior según el rol (`HomeShell`)
- **Rol:** Candidato y Reclutador
- **Historia:** Como usuario autenticado, quiero contar con una pantalla principal con barra de navegación inferior adaptada a mi rol tras iniciar sesión, para moverme entre las secciones principales de la aplicación.
- **Criterios de aceptación:**
  1. Al iniciar sesión o recuperar una sesión activa desde el Splash, el usuario ingresa al contenedor principal correspondiente a su rol.
  2. Para el **Candidato**, la barra inferior presenta las secciones: *Deck*, *Mis Postulaciones* y *Perfil*.
  3. Para el **Reclutador**, la barra inferior presenta las secciones: *Mis Vacantes* y *Perfil*.
  4. Al cerrar sesión desde la sección de perfil se limpia el historial de navegación y se regresa a la pantalla de inicio de sesión.

#### HU-03 — Gestión y consulta de vacantes en la capa de datos
- **Rol:** Reclutador y Candidato
- **Historia:** Como usuario de la aplicación, quiero que el sistema sincronice las vacantes con Supabase para poder publicar y administrar ofertas como reclutador y explorarlas en tiempo real como candidato.
- **Criterios de aceptación:**
  1. Permite al reclutador crear vacantes con sus tecnologías requeridas, listar las ofertas de su empresa, actualizar su información y cambiar su estado (`activa`, `pausada` o `cerrada`).
  2. Permite al candidato consultar únicamente las vacantes `activas` que aún no ha evaluado, calculando los criterios de afinidad con respecto a sus preferencias y tecnologías.
  3. Presenta mensajes de error claros en español ante fallos de red o de base de datos.

#### HU-04 — Registro de swipes y opción de deshacer el último descarte
- **Rol:** Candidato
- **Historia:** Como candidato, quiero que cada deslizamiento sobre una vacante (postular u omitir) se guarde en la base de datos y poder revertir mi último descarte, para no volver a ver ofertas ya evaluadas ni perder una vacante descartada por accidente.
- **Criterios de aceptación:**
  1. Registra en la tabla `swipes` el identificador del candidato, la vacante evaluada y la dirección (`derecha` para postular o `izquierda` para omitir).
  2. Permite deshacer el último swipe negativo (`izquierda`), eliminando el registro y devolviendo la tarjeta al tope del mazo.
  3. Permite consultar el listado de vacantes con swipe positivo del candidato y el conteo de interesados por vacante para el reclutador.

---

### Módulo 2 — Flujo del Candidato (Deck, Detalle, Preferencias y Perfil)

#### HU-05 — Exploración de vacantes en tarjetas deslizables (`DeckScreen`)
- **Rol:** Candidato
- **Historia:** Como candidato, quiero explorar las vacantes disponibles mediante un mazo de tarjetas deslizables hacia la derecha (postular) o hacia la izquierda (omitir), para decidir ágilmente qué oportunidades se ajustan a lo que busco.
- **Criterios de aceptación:**
  1. La tarjeta visible muestra: nombre y monograma de la empresa, título del cargo, ubicación, modalidad (`Remoto`, `Híbrido`, `Presencial`), rango salarial, chips de tecnologías requeridas (destacando las que coinciden con el candidato) y el resumen de razones de afinidad.
  2. Permite decidir tanto deslizando la tarjeta horizontalmente (mostrando un indicador visual de `POSTULAR` u `OMITIR`) como mediante los botones inferiores (*Deshacer*, *Omitir* y *Postular*).
  3. Al omitir una tarjeta se muestra un aviso temporal con la opción **"Deshacer"**; al postular se registra el interés y pasa a la siguiente oferta.
  4. Cuando no quedan vacantes pendientes por revisar, muestra un mensaje informativo en español con opción para recargar o ajustar preferencias.

#### HU-06 — Vista de detalle completo de una vacante (`JobDetailScreen`)
- **Rol:** Candidato
- **Historia:** Como candidato, quiero tocar una tarjeta del deck o de mi lista de postulaciones para leer la descripción completa del cargo y la información de la empresa antes de tomar una decisión.
- **Criterios de aceptación:**
  1. Muestra el encabezado con nombre, monograma y descripción de la empresa, título de la vacante, modalidad, ubicación, rango salarial, nivel de experiencia requerido, listado completo de tecnologías y descripción detallada del puesto.
  2. Incluye acciones en la parte inferior para **"Postular"** u **"Omitir"** directamente desde el detalle, regresando a la pantalla anterior tras registrar la decisión.

#### HU-07 — Configuración de preferencias laborales y tecnologías (`CandidatePreferencesScreen`)
- **Rol:** Candidato
- **Historia:** Como candidato, quiero configurar mis tecnologías de dominio, modalidad de trabajo preferida, nivel de experiencia y expectativa salarial mínima, para que el mazo de vacantes resalte mi compatibilidad con cada oferta.
- **Criterios de aceptación:**
  1. Accesible desde la sección de perfil del candidato.
  2. Permite elegir modalidad (`Remoto`, `Híbrido`, `Presencial`), nivel (`Practicante / Junior`, `Semi-Senior`, `Senior`), salario mínimo esperado y seleccionar múltiples tecnologías mediante chips interactivos.
  3. Valida en español que el salario ingresado sea numérico y que se seleccione al menos una tecnología antes de guardar los cambios en Supabase.

#### HU-08 — Edición de datos básicos del perfil y de la empresa (`EditProfileScreen`)
- **Rol:** Candidato y Reclutador
- **Historia:** Como usuario autenticado, quiero editar la información básica de mi perfil (y de mi empresa en el caso del reclutador), para mantener mis datos actualizados en cualquier momento.
- **Criterios de aceptación:**
  1. Para el **Candidato**, precarga y permite actualizar su nombre completo, ciudad y resumen profesional (máximo 280 caracteres).
  2. Para el **Reclutador**, precarga y permite actualizar su nombre completo y los datos de su empresa (nombre, descripción de hasta 280 caracteres y monograma de 1 a 3 letras).
  3. Guarda los cambios en Supabase y refleja la información actualizada de inmediato en el resumen de perfil.

---

### Módulo 3 — Flujo del Reclutador (Vacantes), Historial y Pruebas

#### HU-09 — Creación y edición de vacantes (`VacancyFormScreen`)
- **Rol:** Reclutador
- **Historia:** Como reclutador, quiero publicar nuevas vacantes y editar las existentes de mi empresa especificando cargo, modalidad, ubicación, salario, descripción y tecnologías requeridas, para atraer candidatos compatibles.
- **Criterios de aceptación:**
  1. Formulario con validaciones en español para: título del cargo (obligatorio), ubicación/ciudad (obligatorio), modalidad (`Remoto`, `Híbrido`, `Presencial`), nivel de experiencia, rango salarial opcional (verificando que el máximo no sea menor al mínimo), descripción del puesto (obligatorio) y selección de tecnologías (mínimo una).
  2. Al guardar, registra o actualiza la vacante en Supabase vinculada a la empresa del reclutador autenticado y regresa al listado de vacantes.

#### HU-10 — Panel de vacantes publicadas de la empresa (`RecruiterVacanciesScreen`)
- **Rol:** Reclutador
- **Historia:** Como reclutador, quiero visualizar la lista de vacantes creadas por mi empresa con su estado actual y la cantidad de candidatos interesados, para administrar mis ofertas activas o pausarlas cuando sea necesario.
- **Criterios de aceptación:**
  1. Lista las vacantes de la empresa mostrando: título, modalidad, ubicación, rango salarial, tecnologías principales, etiqueta de estado (`Activa`, `Pausada`, `Cerrada`) y número de candidatos que han dado swipe positivo.
  2. Permite cambiar el estado de cualquier vacante y acceder a su formulario de edición.
  3. Cuenta con un botón para publicar una nueva vacante y muestra un estado vacío claro cuando la empresa aún no tiene ofertas registradas.

#### HU-11 — Bandeja de vacantes de interés del candidato (`CandidateLikedJobsScreen`)
- **Rol:** Candidato
- **Historia:** Como candidato, quiero consultar en la sección *Mis Postulaciones* el listado de vacantes a las que les di swipe a la derecha, para llevar control de las oportunidades que me interesaron y revisar sus detalles.
- **Criterios de aceptación:**
  1. Muestra las vacantes con swipe positivo del candidato autenticado ordenadas de la más reciente a la más antigua.
  2. Cada tarjeta incluye el monograma y nombre de la empresa, título del puesto, modalidad, ubicación, fecha de postulación y etiqueta de estado inicial (`En revisión`).
  3. Al tocar una vacante de la lista se abre su vista de detalle completo (`JobDetailScreen`).

#### HU-12 — Pruebas de widgets del Sprint 2 y datos de demostración
- **Rol:** Equipo de desarrollo
- **Historia:** Como equipo de desarrollo, queremos contar con pruebas automatizadas de widgets para las pantallas del Sprint 2 y un conjunto de vacantes de demostración precargadas, para validar todos los flujos de ambos roles.
- **Criterios de aceptación:**
  1. Pruebas automatizadas en `app/test/` que verifican el mazo de tarjetas y la acción de deshacer en `DeckScreen`, la vista `JobDetailScreen`, el formulario `VacancyFormScreen`, el listado en `RecruiterVacanciesScreen` y la pantalla `CandidatePreferencesScreen`.
  2. Carga de al menos 4 vacantes activas de demostración asociadas a la cuenta demo de reclutadora (`laura.demo@dreamjob.co`) para recorrer el flujo completo desde la cuenta demo de candidato (`carlos.demo@dreamjob.co`).
  3. Análisis estático (`dart analyze`) sin errores y suite de pruebas pasando en integración continua.

---

## 3. Resumen de Tablas del Sprint 2 en Supabase

| Tabla | Columnas principales | Reglas RLS |
|---|---|---|
| `usuarios` *(extensión)* | Se añaden `modalidad_preferida`, `salario_minimo` y `seniority` | Lectura y edición solo cuando `id = auth.uid()`. |
| `tecnologias` | `id`, `nombre`, `categoria` | Lectura permitida a cualquier usuario autenticado. |
| `usuario_tecnologias` | `usuario_id`, `tecnologia_id` | Gestión permitida únicamente cuando `usuario_id = auth.uid()`. |
| `vacantes` | `id`, `empresa_id`, `reclutador_id`, `titulo`, `descripcion`, `ubicacion`, `modalidad`, `salario_min`, `salario_max`, `seniority`, `estado`, `created_at` | Lectura de vacantes activas para autenticados; creación y edición solo para reclutadores de la empresa. |
| `vacante_tecnologias` | `vacante_id`, `tecnologia_id` | Lectura para autenticados; modificación solo para el reclutador dueño de la vacante. |
| `swipes` | `id`, `usuario_id`, `vacante_id`, `direccion` (`derecha` o `izquierda`), `created_at` | El candidato administra sus propios swipes; el reclutador consulta los swipes de las vacantes de su empresa. |
