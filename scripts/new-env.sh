#!/bin/bash
set -e

NAME="$1"
shift || true
PACKAGES="$@"
ENV_DIR="/home/mluser/work/environments"
YML="$ENV_DIR/$NAME.yml"

if [ -z "$NAME" ]; then
    echo "Uso: new-env.sh <nombre> [paquetes...]"
    exit 1
fi

if [ -f "$YML" ]; then
    echo "Ya existe $YML -- elegi otro nombre o borralo con remove-env.sh."
    exit 1
fi

mkdir -p "$ENV_DIR"
{
    echo "name: $NAME"
    echo "channels:"
    echo "  - conda-forge"
    echo "  - defaults"
    echo "dependencies:"
    echo "  - python=3.11"
    echo "  - ipykernel"
    for pkg in $PACKAGES; do
        echo "  - $pkg"
    done
} > "$YML"

echo "==> Creando entorno '$NAME'..."
conda env create -f "$YML"

echo "==> Registrando kernel para '$NAME'..."
conda run -n "$NAME" python -m ipykernel install --user \
    --name "$NAME" --display-name "Python ($NAME)"

echo "Entorno '$NAME' creado y registrado como kernel de Jupyter."
