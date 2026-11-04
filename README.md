# DreamJob

Aplicación móvil de búsqueda de empleo y prácticas profesionales con dinámica de match bidireccional.

![Flutter](https://img.shields.io/badge/Flutter-Estable-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white)
![Estado](https://img.shields.io/badge/Estado-Sprint%201%20(v1.0.0)-success)

---

## 1. Descripción y propuesta de valor

**DreamJob** es una aplicación móvil en **Flutter/Dart** que lleva la mecánica de **Tinder** al mercado laboral y de prácticas universitarias.

En lugar de enviar hojas de vida a decenas de portales sin recibir respuesta, el flujo se basa en interés mutuo:

1. Cada persona crea un perfil con sus datos y preferencias; por su parte, los reclutadores registran su empresa y publican vacantes o prácticas.
2. En la pantalla de búsqueda se muestran tarjetas con oportunidades que encajan con el perfil (o candidatos compatibles, en el caso de las empresas).
3. Deslizar a la **derecha** indica interés (*like*) y deslizar a la **izquierda** descarta la tarjeta.
4. Solo hay **match** cuando ambas partes se dan *like* mutuamente (match bidireccional entre candidato y empresa).

**Visión a largo plazo (Roadmap):** a partir del modelo de datos diseñado para el proyecto, las siguientes etapas contemplan un agente de IA que ayude con vacantes y postulaciones (ajuste de hoja de vida y carta de presentación, llenado de formularios, lectura de códigos OTP 2FA y registro de acciones), además de seguimiento de postulaciones y entrevistas, sesiones de preparación con un coach y notificaciones.

---

## 2. Usuarios objetivo

### Valentina Rodríguez — Candidata
- **Perfil:** 21 años, Cali, Colombia. Estudiante de Ingeniería de Sistemas orientada a desarrollo móvil.
- **Contexto:** *"Quiero encontrar una oportunidad que se ajuste a mi perfil sin enviar mi hoja de vida a decenas de vacantes que no responden."*
- **Motivaciones:** conseguir su primera práctica o empleo junior, aplicar Flutter, Dart y sus proyectos académicos en un entorno real, y dar con empresas cuya modalidad, horarios y cultura se ajusten a lo que busca.
- **Frustraciones:** vacantes junior que piden años de experiencia, procesos donde nunca informan el estado de la postulación y ofertas sin datos claros de salario, modalidad o beneficios.

### Andrés Martínez — Reclutador
- **Perfil:** 32 años, Cali, Colombia. Analista de selección tecnológica.
- **Contexto:** *"Necesito identificar candidatos realmente compatibles sin invertir horas revisando perfiles que no cumplen los requisitos básicos."*
- **Motivaciones:** cubrir vacantes de prácticas y cargos junior con rapidez, revisar habilidades, disponibilidad y preferencias antes de primer contacto, y tener en un solo lugar las vacantes, perfiles, matches y mensajes.
- **Frustraciones:** recibir decenas de postulaciones que no cumplen requisitos mínimos, tener la información repartida entre portales, correo y hojas de cálculo, y encontrar perfiles incompletos difíciles de comparar.

---

## 3. Funcionalidades

El **Sprint 1 (Autenticación — `v1.0.0`)** se encuentra implementado e integrado; el resto de módulos corresponde al **Roadmap** derivado del modelo de datos.

| Funcionalidad | Estado | Detalle |
|---|---|---|
| Registro de candidato con onboarding básico | Implementado | Nombre, correo, contraseña, ciudad, fecha de nacimiento y resumen opcional |
| Registro de reclutador con empresa nueva | Implementado | Datos del reclutador y alta transaccional de su empresa (nombre, descripción y monograma) por RPC |
| Inicio de sesión con correo y contraseña | Implementado | Autenticación con Supabase Auth (sin confirmación de correo) y mensajes de error en español |
| Resumen de perfil según rol | Implementado | Vista diferenciada para candidato (incluye edad calculada) y reclutador (incluye tarjeta de empresa) |
| Sesión persistente y cierre de sesión | Implementado | El Splash verifica la sesión guardada en Supabase y redirige a `/profile` o `/login` |
| Seguridad por fila (RLS) en Postgres | Implementado | Políticas RLS en `empresas`, `usuarios` y `reclutadores` más la función `registrar_reclutador` |
| Navegación principal por rol (`HomeShell`) | Sprint 2 | Contenedor principal con barra de navegación inferior diferenciada para candidato y reclutador |
| Preferencias laborales, tecnologías y edición de perfil | Sprint 2 | Seniority, salario mínimo, modalidad preferida, selección de tecnologías y edición de datos |
| Publicación y gestión de vacantes (Reclutador) | Sprint 2 | Alta, edición, listado y cambio de estado de ofertas por empresa con tecnologías requeridas |
| Deck de vacantes con swipes y vista de detalle (Candidato) | Sprint 2 | Deslizar a derecha (postular) o izquierda (omitir) con opción de deshacer e historial de interés |
| Revisión de postulantes y match bidireccional | Sprint 3 (MVP) | Evaluación de candidatos por el reclutador y generación del match mutuo |
| Seguimiento de postulaciones, entrevistas y coach | Sprint 3 (MVP) | Estados de aplicación, agenda de entrevistas y sesiones de práctica con puntaje y consejos |
| Inicio de sesión con Google y conexión con Gmail | Roadmap posterior | OAuth (`google_sub`) y lectura automática de códigos OTP |
| Agente de IA para documentos y formularios | Roadmap posterior | Adaptación de CV y carta de presentación, respuestas de formulario y bitácora |
| Notificaciones | Roadmap posterior | Avisos en la app para candidatos y reclutadores |

---

## 4. Arquitectura y stack

### Stack utilizado en el Sprint 1
- **Aplicación móvil:** Flutter / Dart (canal estable).
- **Estado:** `provider` (`ChangeNotifier` mediante `AuthProvider`).
- **Rutas y navegación:** `go_router` con redirección automática según el estado de sesión.
- **Backend:** Supabase (`supabase_flutter`)
  - **Auth:** correo y contraseña con confirmación de email desactivada.
  - **Base de datos:** PostgreSQL con Row Level Security (RLS) activo por `auth.uid()`.
  - **RPC `registrar_reclutador`:** función en PL/pgSQL (`security definer`) para insertar empresa y reclutador en una misma transacción.

### Diagrama de arquitectura

```mermaid
flowchart LR
    subgraph App["App Móvil (Flutter)"]
        UI["Pantallas y Widgets\n(Login, Registro, Perfil)"]
        Router["go_router\n(6 rutas + redirect)"]
        State["AuthProvider\n(provider)"]
        Repo["AuthRepository"]
    end

    subgraph Supabase["Supabase"]
        Auth["Supabase Auth\n(auth.users)"]
        RPC["RPC: registrar_reclutador"]
        DB[("PostgreSQL + RLS\nusuarios · reclutadores · empresas")]
    end

    UI --> State
    State --> Router
    State --> Repo
    Repo --> Auth
    Repo --> RPC
    Repo --> DB
    RPC --> DB
    Auth -. "auth.uid()" .-> DB
```

---

## 5. Modelo de datos

Sobre el diseño de base de datos del proyecto conviene tener presentes tres puntos:

1. **Modelo objetivo vs. alcance actual:** el diagrama relacional completo recoge la visión objetivo del producto a largo plazo. En el **Sprint 1 solo se implementan las tablas `empresas`, `usuarios` y `reclutadores`** (enlazadas a `auth.users` de Supabase) junto con la función RPC `registrar_reclutador`.
2. **Tipos de datos:** el diagrama original se modeló con tipos de **Oracle** (`VARCHAR2`, `NUMBER`, `CLOB`, `DATE`, `TIMESTAMP`), pero la base de datos real corre sobre **PostgreSQL en Supabase** (`uuid`, `text`, `date`, `timestamptz`, `boolean`, `numeric`).
3. **Aislamiento:** todas las tablas del Sprint 1 tienen RLS habilitado; el alta de empresa y reclutador no admite `INSERT` directo desde el cliente y se hace únicamente mediante la función RPC.

### 5.1. Tablas del Sprint 1 (PostgreSQL en Supabase)

| Tabla / Función | Columnas principales | Reglas RLS / Permisos |
|---|---|---|
| `empresas` | `id` (`uuid PK default gen_random_uuid()`), `nombre` (`text not null`), `descripcion` (`text`), `monograma` (`text not null`), `created_at` (`timestamptz`) | `SELECT` limitado a la empresa del reclutador autenticado. Sin `INSERT` directo. |
| `usuarios` | `id` (`uuid PK references auth.users(id) on delete cascade`), `nombre` (`text not null`), `email` (`text not null`), `ciudad` (`text not null`), `fecha_nacimiento` (`date not null`), `resumen_perfil` (`text`), `created_at` (`timestamptz`) | `SELECT`, `INSERT` y `UPDATE` solo cuando `id = auth.uid()`. |
| `reclutadores` | `id` (`uuid PK references auth.users(id) on delete cascade`), `nombre` (`text not null`), `email` (`text not null`), `empresa_id` (`uuid not null references empresas(id)`), `created_at` (`timestamptz`) | `SELECT` y `UPDATE` solo cuando `id = auth.uid()`. Sin `INSERT` directo. |
| `registrar_reclutador` (RPC) | `p_nombre`, `p_email`, `p_empresa_nombre`, `p_empresa_descripcion`, `p_empresa_monograma` (`text`) | `security definer`, `set search_path = public`. Valida `auth.uid()`, crea la empresa y el reclutador en una transacción. Ejecución permitida solo a `authenticated`. |

### 5.2. Entidades del modelo completo (Visión objetivo)

| Bloque | Tablas en el modelo relacional | Uso dentro del sistema |
|---|---|---|
| Perfil del candidato | `usuarios`, `hojas_de_vida`, `roles_interes`, `usuario_roles_interes`, `tecnologias`, `usuario_tecnologias`, `usuario_modalidades`, `empresas_bloqueadas` | Datos del candidato, preferencias salariales y de modalidad, tecnologías que maneja o descarta, bloqueo de empresas y hojas de vida con puntaje ATS. |
| Empresas y vacantes | `empresas`, `reclutadores`, `vacantes`, `vacante_tecnologias` | Datos de la empresa, reclutadores vinculados, ofertas con modalidad, salario, fuente y tecnologías requeridas. |
| Recomendaciones y match | `recomendaciones`, `swipes`, `matches` | Sugerencias de vacantes o candidatos con sus razones, registro de cada deslizamiento (`derecha` o `izquierda`) indicando el actor y creación del match cuando coinciden ambos lados. |
| Postulaciones y agente IA | `postulaciones`, `documentos_postulacion`, `preguntas_formulario`, `codigos_otp`, `log_acciones_agente` | Seguimiento de la postulación, documentos generados o ajustados (CV y carta), respuestas a preguntas de aplicación, lectura de códigos 2FA y historial de acciones del agente. |
| Entrevistas, coach y avisos | `entrevistas`, `llamadas_coach`, `notificaciones` | Etapas de entrevista, sesiones de práctica con duración, puntaje y consejos, y notificaciones para ambos roles. |

---

## 6. Estructura del repositorio

```text
DreamJob/
├── README.md
├── CONTRIBUTING.md
├── .github/
│   ├── pull_request_template.md
│   └── workflows/
│       └── ci.yml                           # CI: flutter analyze y flutter test
├── docs/
│   ├── backlog-sprint2.md                   # Historias de usuario y criterios de aceptación del Sprint 2
│   ├── guion-video-sprint1.md               # Guion de demostración del Sprint 1 (máx. 2 min)
│   └── sprint1-seguimiento.md               # Bitácora técnica de verificación con Supabase
├── supabase/
│   ├── schema.sql                           # Tablas empresas, usuarios, reclutadores, RLS y RPC registrar_reclutador
│   └── tests/
│       ├── bootstrap.sql                    # Contrato mínimo de Auth para PostgreSQL de pruebas
│       └── rls.sql                          # Aislamiento de cuentas y empresas, con rollback
└── app/                                     # Proyecto Flutter (paquete icesi.edu.co.dreamjob)
    ├── .env.example                         # Plantilla con SUPABASE_URL y SUPABASE_ANON_KEY vacías
    ├── pubspec.yaml                         # Dependencias: supabase_flutter, provider, go_router
    ├── lib/
    │   ├── main.dart                        # Inicialización de Supabase, MultiProvider y MaterialApp.router
    │   ├── theme.dart                       # Paleta de colores y tema visual de DreamJob
    │   ├── widgets/
    │   │   └── common.dart                  # Componentes visuales compartidos (OwlBadge, DjCard, CompanyMark, etc.)
    │   ├── core/
    │   │   └── validators.dart              # Validadores en español (email, password, required, date, monogram)
    │   ├── router/
    │   │   └── app_router.dart              # Configuración de las 6 rutas, SplashScreen y redirect por sesión
    │   ├── auth/
    │   │   ├── data/
    │   │   │   ├── models.dart              # UserRole, CandidateProfile, CompanyProfile y RecruiterProfile
    │   │   │   ├── auth_repository.dart     # AuthRepository y SupabaseAuthRepository
    │   │   │   └── auth_error_mapper.dart   # Mapeo de excepciones de Supabase y red al español
    │   │   ├── state/
    │   │   │   └── auth_provider.dart       # AuthProvider (ChangeNotifier) conectado a AuthRepository
    │   │   ├── widgets/
    │   │   │   ├── auth_text_field.dart
    │   │   │   ├── auth_password_field.dart
    │   │   │   ├── auth_primary_button.dart
    │   │   │   └── auth_error_banner.dart
    │   │   └── screens/
    │   │       ├── login_screen.dart
    │   │       ├── register_role_screen.dart
    │   │       ├── register_candidate_screen.dart
    │   │       └── register_recruiter_screen.dart
    │   └── profile/
    │       └── profile_summary_screen.dart  # Pantalla de resumen de perfil para candidato y reclutador
    └── test/
        ├── widget_test.dart
        ├── profile_summary_screen_test.dart
        ├── register_recruiter_screen_test.dart
        ├── auth_error_mapper_test.dart
        ├── demo_users_live_test.dart
        ├── session_recovery_test.dart
        ├── fakes/
        │   └── fake_auth_repository.dart
        └── helpers/
            └── fake_auth_provider.dart
```

---

## 7. Primeros pasos

### 7.1. Requisitos
1. **Flutter SDK estable** instalado y agregado al `PATH`, con `flutter doctor` en verde.
2. **Android Studio** con un emulador Android (AVD) configurado, o un celular Android conectado con depuración por USB.
3. **Proyecto en Supabase** con:
   - En `Authentication -> Sign In / Providers -> Email`: opción **"Enable Email provider" activada** y opción **"Confirm email" desactivada**.
   - El archivo `supabase/schema.sql` ejecutado sin errores en el SQL Editor de Supabase.

### 7.2. Instalación y ejecución

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/JuanJarias/DreamJob.git
   cd DreamJob
   ```

2. Entrar a la carpeta de la aplicación e instalar dependencias:
   ```bash
   cd app
   flutter pub get
   ```

3. Configurar las variables de entorno copiando `app/.env.example` a `app/.env`:
   ```bash
   cp .env.example .env
   ```
   Abrir `app/.env` y completar los valores del proyecto de Supabase (se comparten por privado entre el equipo; nunca se suben al repositorio):
   ```env
   SUPABASE_URL=https://<tu-proyecto>.supabase.co
   SUPABASE_ANON_KEY=<tu-anon-key>
   ```
   No subas el archivo `.env` a Git ni uses nunca la `service_role` key en la aplicación.

4. Correr la app pasando el archivo de entorno:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

---

## 8. Sprint 1 — Autenticación

- **Video de demostración (Sprint 1):** [Ver video en Canva](https://canva.link/669vlmr8ydbyc5a)

### 8.1. Alcance
- Registro con datos básicos para **Candidato** y **Reclutador** (el reclutador crea siempre una empresa nueva al registrarse).
- Inicio de sesión con correo electrónico y contraseña contra Supabase.
- Pantalla de resumen de perfil que cambia según el rol del usuario autenticado.
- Persistencia de sesión al cerrar y volver a abrir la app, y cierre de sesión.
- El inicio de sesión con Google y la conexión con Gmail quedan fuera de este sprint.

### 8.2. Rutas de la aplicación

| Ruta | Clase de pantalla | Archivo | Función |
|---|---|---|---|
| `/splash` | `SplashScreen` | `app/lib/router/app_router.dart` | Comprueba si hay sesión activa al abrir la app y redirige a `/profile` o `/login`. |
| `/login` | `LoginScreen` | `app/lib/auth/screens/login_screen.dart` | Formulario de correo y contraseña, banner de error y enlace a `/register`. |
| `/register` | `RegisterRoleScreen` | `app/lib/auth/screens/register_role_screen.dart` | Selección de rol ("¿Cómo quieres usar DreamJob?"): candidato o reclutador. |
| `/register/candidato` | `RegisterCandidateScreen` | `app/lib/auth/screens/register_candidate_screen.dart` | Registro de candidato: nombre, correo, contraseña (mínimo 8 caracteres), confirmación, ciudad, fecha de nacimiento y resumen opcional (máx. 280 caracteres). |
| `/register/reclutador` | `RegisterRecruiterScreen` | `app/lib/auth/screens/register_recruiter_screen.dart` | Registro de reclutador en dos bloques: datos personales y datos de la empresa (nombre, descripción máx. 280 caracteres y monograma de 1 a 3 letras en mayúsculas con vista previa). |
| `/profile` | `ProfileSummaryScreen` | `app/lib/profile/profile_summary_screen.dart` | Muestra el resumen del candidato o del reclutador (con su empresa) y el botón para cerrar sesión. |

### 8.3. Pasos de demostración por rol

#### Candidato
1. En `/login`, tocar **"¿No tienes cuenta? Crear cuenta"** para ir a `/register`.
2. Elegir **"Soy candidato"** para abrir `/register/candidato`.
3. Llenar nombre completo, correo, contraseña (al menos 8 caracteres), confirmación de contraseña, ciudad, fecha de nacimiento y resumen opcional. Tocar **"Crear cuenta"**.
4. Comprobar que el router redirige solo a `/profile` y que se ven las iniciales, nombre, correo, ciudad, fecha de nacimiento con edad calculada y el resumen.
5. Tocar **"Cerrar sesión"** y verificar que vuelve a `/login`.
6. Iniciar sesión con la cuenta recién creada y verificar que entra de nuevo a `/profile`.
7. Cerrar la aplicación por completo y volver a abrirla: debe mantener la sesión e ir directo a `/profile`.

#### Reclutador
1. En `/login`, tocar **"Crear cuenta"** y seleccionar **"Soy reclutador"** (`/register/reclutador`).
2. Completar la sección **"Tus datos"** (nombre, correo, contraseña y confirmación) y la sección **"Tu empresa"** (nombre, descripción y monograma de 1 a 3 letras), y tocar **"Crear cuenta"**.
3. Verificar que redirige a `/profile` mostrando los datos del reclutador y la tarjeta de la empresa con su monograma, nombre y descripción.
4. Tocar **"Cerrar sesión"** (regresa a `/login`), volver a iniciar sesión con las mismas credenciales y comprobar el perfil.
5. Cerrar y reabrir la aplicación para verificar que la sesión persiste en `/profile`.

### 8.4. Errores esperables

Todos los mensajes de validación y respuestas de error se muestran en español:

- **Email repetido:** si el correo ya existe en Supabase Auth, se informa en el banner de error (`"Este correo electrónico ya está registrado"`).
- **Credenciales incorrectas:** al ingresar un correo o contraseña equivocados en el login, el banner indica `"Correo electrónico o contraseña incorrectos"`.
- **Contraseña corta:** el validador del campo y el mapeo de errores exigen un mínimo de 8 caracteres (`"La contraseña debe tener al menos 8 caracteres"`).
- **Campos vacíos:** cada campo obligatorio muestra su mensaje debajo del input si se intenta enviar vacío.
- **Sin conexión:** si el teléfono o emulador no tiene red (por ejemplo, en modo avión), se captura el fallo de red y se muestra `"Sin conexión a internet. Verifica tu red e inténtalo de nuevo"`.

---

## 9. Cómo contribuir

Ver la guía completa en [CONTRIBUTING.md](./CONTRIBUTING.md): flujo de ramas, formato de commits, checklist de calidad antes de abrir un Pull Request y el workflow de CI que corre `flutter analyze` y `flutter test` en cada PR hacia `dev` y `main`.

### Verificación del Sprint 1

Desde `app/`, ejecutar `flutter analyze` y `flutter test`. Las pruebas cubren formularios, perfiles de ambos roles, restauración de sesión y recuperación de errores de red al abrir la app o cerrar sesión.

Las dos pruebas de `test/demo_users_live_test.dart` se omiten explícitamente cuando faltan credenciales. Para ejecutarlas contra Supabase, agregar `DEMO_PASSWORD`, `DEMO_CANDIDATO_EMAIL` y `DEMO_RECLUTADOR_EMAIL` al archivo local `app/.env` y ejecutar:

```bash
flutter test test/demo_users_live_test.dart --dart-define-from-file=.env
```

Estas pruebas esperan los perfiles demo existentes descritos en el archivo de prueba; no crean cuentas. No publicar contraseñas ni el contenido de `.env`.

El job `database-rls` de CI comprueba el aislamiento de cuentas y empresas con PostgreSQL 17. Para repetirlo en una base PostgreSQL **vacía y desechable**, desde la raíz:

```bash
psql -v ON_ERROR_STOP=1 -f supabase/tests/bootstrap.sql -f supabase/schema.sql -f supabase/tests/rls.sql
```

`bootstrap.sql` reproduce únicamente el contrato mínimo de Auth para las pruebas; no debe ejecutarse en Supabase. En un proyecto Supabase existente, volver a aplicar `supabase/schema.sql` para restringir la actualización de `reclutadores` a `nombre` y `email`. Esto impide cambiar `empresa_id` para acceder a datos de otra empresa. Las pruebas locales no modifican el proyecto remoto.

---

## 10. Roadmap

El detalle de las **12 historias de usuario** y criterios de aceptación del Sprint 2 se encuentra en [docs/backlog-sprint2.md](./docs/backlog-sprint2.md).

| Sprint / Etapa | Alcance | Estado |
|---|---|---|
| Sprint 1 | Autenticación para candidato y reclutador, alta de empresa, perfil, sesión persistente y RLS (`v1.0.0`) | Completado (`v1.0.0`) |
| Sprint 2 | Navegación principal por rol (`HomeShell`), gestión de vacantes del reclutador, preferencias y tecnologías del candidato, Deck de swipes (postular/omitir/deshacer), detalle de vacante e historial de interés ([ver backlog](./docs/backlog-sprint2.md)) | Planificado (En curso) |
| Sprint 3 (MVP) | Revisión de candidatos por el reclutador, match bidireccional, seguimiento de postulaciones por estado, agenda de entrevistas y módulo de práctica con el Coach | Planificado |
| Siguientes etapas | Integración OAuth con Google/Gmail para lectura de OTP, adaptación automática de hojas de vida/cartas con agente de IA y notificaciones push | En hoja de ruta |

---

## 11. Equipo y licencia

### Equipo
- **Joshua Rivera** ([@JRivera340](https://github.com/JRivera340)) — Núcleo, configuración de Flutter y Supabase, router, autenticación e integración.
- **Juan José Arias** ([@JuanJarias](https://github.com/JuanJarias)) — Pantallas de login, selección de rol, registro de candidato y widgets compartidos de formulario.
- **Ange** ([@Angdicode](https://github.com/Angdicode)) — Pantalla de registro de reclutador, resumen de perfil por rol y pruebas de widgets.
- **Santiago Espinosa** ([@espinosacodes](https://github.com/espinosacodes)) — Diseño inicial de datos, esquema de Supabase y documentación del sprint.

### Licencia
- Por confirmar (aún no se ha definido un archivo `LICENSE` en el repositorio).
