FROM continuumio/miniconda3:latest

# Jupyter Lab + ipykernel viven en el entorno base: son la infraestructura minima
# para levantar el servidor y registrar kernels. Ninguna libreria de analisis de
# datos se instala aca -- esas van en entornos separados creados en runtime
# (ver entrypoint.sh y scripts/new-env.sh).
RUN conda install -n base -y -c conda-forge jupyterlab ipykernel \
    && conda clean -afy

ARG UID=1000
ARG GID=1000
# El GID del host (ej. 20 = "staff" en Mac) puede ya existir en la imagen base
# Debian con otro nombre de grupo (ej. "dialout"). Si existe, se reutiliza ese
# grupo para el usuario en vez de fallar con "GID already exists".
RUN set -eux; \
    if getent group "$GID" >/dev/null; then \
        GROUP_NAME=$(getent group "$GID" | cut -d: -f1); \
    else \
        GROUP_NAME=mluser; \
        groupadd -g "$GID" "$GROUP_NAME"; \
    fi; \
    useradd -u "$UID" -g "$GROUP_NAME" -m mluser

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/new-env.sh scripts/remove-env.sh scripts/list-envs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh \
             /usr/local/bin/new-env.sh \
             /usr/local/bin/remove-env.sh \
             /usr/local/bin/list-envs.sh

# Se crean (y se les da ownership) los directorios donde docker-compose va a
# montar los named volumes. Docker copia el contenido y el ownership de estas
# rutas al volumen la primera vez que se monta un volumen vacio sobre ellas, asi
# que el contenedor no necesita arrancar como root para tener permisos correctos.
RUN mkdir -p /opt/conda/envs \
             /home/mluser/.local/share/jupyter/kernels \
             /home/mluser/work/projects \
             /home/mluser/work/environments \
    && chown -R "$UID:$GID" /opt/conda /home/mluser

USER mluser
WORKDIR /home/mluser/work

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
