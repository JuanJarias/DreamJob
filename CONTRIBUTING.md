# Como contribuir

## Ramas

- `main`: rama de entregas. Solo recibe merges desde `dev` al cerrar una version (tag como `v1.0.0`).
- `dev`: rama de integracion del equipo.
- `feat/...`, `fix/...`, `docs/...`, `chore/...`, `test/...`: ramas de trabajo individuales, se integran a `dev` mediante Pull Request.

No se hace push directo a `main` ni a `dev` durante el desarrollo, y no se usa `git push --force`.

## Commits

Commits cortos de una sola linea en espanol, con prefijo segun el tipo de cambio:

- `feat:` nueva funcionalidad.
- `fix:` correccion de errores.
- `docs:` documentacion.
- `chore:` configuracion, dependencias o tareas de entorno.
- `test:` pruebas automatizadas.

## Antes de abrir un Pull Request

Desde la carpeta `app/`, confirmar que ambos comandos terminan sin errores ni warnings:

```bash
flutter analyze
flutter test
```

Ademas:

- Todos los textos de la interfaz deben estar en espanol.
- `app/.env` no debe formar parte de ningun commit.
- Usar la plantilla de PR (`.github/pull_request_template.md`) y vincular la issue correspondiente con `Closes #<numero>`.
- El workflow de CI (`flutter analyze` + `flutter test`) debe pasar en verde antes de mergear a `dev` o `main`.
