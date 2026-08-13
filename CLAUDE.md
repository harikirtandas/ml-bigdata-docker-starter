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
- **Sin `gosu`/`su-exec`:** se aprovecha que Docker copia contenido y ownership de
  un directorio de la imagen al named volume la primera vez que se monta vacío. Por
  eso el Dockerfile crea y hace `chown` a `/opt/conda/envs` y
  `/home/mluser/.local/share/jupyter/kernels` *antes* de montar los volúmenes.
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
