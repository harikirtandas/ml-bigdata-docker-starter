#!/bin/bash
# Genera projects/<nombre>/pyrightconfig.json apuntando al site-packages real
# del entorno, para que un LSP corriendo en el host (ej. pyright via LazyVim)
# resuelva imports sin ejecutar nada -- ver docker-compose.yml (bind mount de
# environments-data) y el README, seccion "Uso con LazyVim / Neovim".
# No pisa un pyrightconfig.json que el usuario ya haya customizado a mano.
set -e

NAME="$1"
[ -z "$NAME" ] && { echo "Uso: write-pyright-config.sh <nombre>"; exit 1; }

PROJECT_DIR="/home/mluser/work/projects/$NAME"
CONFIG="$PROJECT_DIR/pyrightconfig.json"

[ -f "$CONFIG" ] && exit 0

PYVER=$(conda run -n "$NAME" python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null)
if [ -z "$PYVER" ]; then
    echo "==> No se pudo determinar la version de Python de '$NAME', se omite pyrightconfig.json."
    exit 0
fi
PYVER_DIR="python$PYVER"

mkdir -p "$PROJECT_DIR"
cat > "$CONFIG" <<EOF
{
  "extraPaths": ["../../environments-data/$NAME/lib/$PYVER_DIR/site-packages"]
}
EOF
echo "==> pyrightconfig.json generado en projects/$NAME/"
