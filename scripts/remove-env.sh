#!/bin/bash
set -e

NAME="$1"
ENV_DIR="/home/mluser/work/environments"

if [ -z "$NAME" ]; then
    echo "Uso: remove-env.sh <nombre>"
    exit 1
fi

echo "==> Eliminando entorno conda '$NAME'..."
conda env remove -n "$NAME" -y || echo "(el entorno conda ya no existia)"

echo "==> Eliminando kernel de Jupyter '$NAME'..."
jupyter kernelspec remove -f "$NAME" || echo "(el kernel ya no existia)"

echo "==> Eliminando $ENV_DIR/$NAME.yml..."
rm -f "$ENV_DIR/$NAME.yml"

echo "Entorno '$NAME' eliminado por completo."
