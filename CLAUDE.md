# CLAUDE.md — ml-bigdata-docker-starter

Contexto para asistentes IA que trabajen en este repo.

## Qué es

Plantilla Docker para la cátedra de Machine Learning y BigData: Miniconda + Jupyter
Lab, sin librerías de análisis de datos preinstaladas en la imagen. Cada práctico
tiene su propio entorno conda, creado en runtime a partir de un `.yml` en
`environments/`, sin reconstruir la imagen.

## Decisiones de diseño

- **`docker/` es infraestructura, no cambia entre prácticos.** El contenido real
  (`projects/`, `environments/`) vive fuera de la imagen, montado por bind mount.
- **Usuario no-root (`mluser`) parametrizado por `UID`/`GID`** (build args, pasados
  desde el Makefile vía `HOST_UID`/`HOST_GID` = `id -u`/`id -g`), igual que en los
  starters de Laravel del mismo autor. Evita archivos root-owned al editar desde el
  host.
- **Sin `gosu`/`su-exec`:** para `jupyter-kernels` (named volume) se aprovecha que
  Docker copia contenido y ownership de un directorio de la imagen al volumen la
  primera vez que se monta vacío. Por eso el Dockerfile crea y hace `chown` a esos
  directorios *antes* de montar los volúmenes.
- **`/opt/conda/envs` es bind mount (`./environments-data`), no named volume** —
  a propósito, para que un LSP corriendo en el host (pyright/basedpyright vía
  LazyVim) pueda resolver imports leyendo site-packages directo del filesystem,
  sin ejecutar nada en el host. Gitignoreado (son binarios pesados, no contenido
  versionable). `remove-env.sh` usa `rm -rf` en vez de `conda env remove`: el
  desinstalador de conda hace un rename "seguro" que falla sobre la capa de bind
  mount de Docker Desktop en Mac (virtiofs) — descubierto probando el flujo real,
  no algo documentado. `conda env list` descubre entornos escaneando el
  directorio, no necesita desregistro explícito.
- **`scripts/write-pyright-config.sh`** genera `projects/<nombre>/pyrightconfig.json`
  automáticamente (desde `new-env.sh` y desde el loop de `entrypoint.sh`) con
  `extraPaths` apuntando a `../../environments-data/<nombre>/lib/pythonX.Y/site-packages`.
  La versión de Python se pregunta al intérprete real (`conda run -n <env> python -c
  'sys.version_info...'`), no se infiere listando el filesystem — un intento anterior
  con `ls -d .../lib/python3.*` tomó `python3.1` en vez de `python3.11` porque conda
  también crea un directorio `python3.1` (compat legado) y el glob ordena mal.
- **`environments/*.yml` y `projects/` SÍ se versionan en git** — a diferencia del
  patrón de los starters de Laravel (donde `src/` se ignora porque es regenerable),
  acá son el contenido real de la cátedra, no algo descartable.
- **`entrypoint.sh` es idempotente:** recorre `environments/*.yml` en cada arranque
  y solo crea los entornos que todavía no existen (`conda env list | grep`).
- **Toda la gestión pasa por el Makefile** (`make new-env`, `make remove-env`,
  `make list-envs`, `make shell`), que internamente hace `docker compose exec` a
  scripts copiados en `/usr/local/bin/` dentro de la imagen.
- **Jupyter Lab sin token** (`--IdentityProvider.token=''`, con `--ServerApp.token=''`
  como respaldo por compatibilidad con versiones más viejas de jupyter_server): es
  uso local, corre atrás del firewall de la máquina del usuario.
