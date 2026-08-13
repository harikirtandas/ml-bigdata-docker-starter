#!/bin/bash
set -e

NAME="$1"
ENV_DIR="/home/mluser/work/environments"

if [ -z "$NAME" ]; then
    echo "Uso: remove-env.sh <nombre>"
    exit 1
fi

echo "==> Eliminando entorno conda '$NAME'..."
# rm -rf directo en vez de "conda env remove": el desinstalador de conda hace
# un rename "seguro" archivo por archivo que falla sobre la capa de bind mount
# de Docker Desktop en Mac (virtiofs). conda descubre los entornos escaneando
# /opt/conda/envs, no necesita desregistro explicito -- borrar el directorio
# alcanza.
rm -rf "/opt/conda/envs/$NAME"

echo "==> Eliminando kernel de Jupyter '$NAME'..."
jupyter kernelspec remove -f "$NAME" || echo "(el kernel ya no existia)"

echo "==> Eliminando $ENV_DIR/$NAME.yml..."
rm -f "$ENV_DIR/$NAME.yml"

echo "Entorno '$NAME' eliminado por completo."
