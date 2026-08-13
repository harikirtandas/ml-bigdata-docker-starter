#!/bin/bash
set -e

ENV_DIR="/home/mluser/work/environments"
mkdir -p "$ENV_DIR"

for yml in "$ENV_DIR"/*.yml; do
    [ -e "$yml" ] || continue

    env_name=$(grep -m1 '^name:' "$yml" | awk '{print $2}')
    if [ -z "$env_name" ]; then
        echo "==> $yml no tiene 'name:', se omite."
        continue
    fi

    if conda env list | grep -qE "^${env_name}\s"; then
        echo "==> Entorno '$env_name' ya existe, omitiendo creacion."
    else
        echo "==> Creando entorno '$env_name' desde $yml..."
        conda env create -f "$yml"
    fi

    echo "==> Registrando kernel para '$env_name'..."
    conda run -n "$env_name" python -m ipykernel install --user \
        --name "$env_name" --display-name "Python ($env_name)"

    write-pyright-config.sh "$env_name"
done

echo "==> Levantando Jupyter Lab en http://0.0.0.0:8888"
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --IdentityProvider.token='' \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --ServerApp.root_dir=/home/mluser/work/projects
