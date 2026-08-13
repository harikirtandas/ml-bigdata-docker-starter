# ml-bigdata-docker-starter

Plantilla Docker para la cátedra de Machine Learning y BigData. Levanta Jupyter Lab
en el navegador con un solo comando, sin instalar Python, Conda ni ninguna librería
directamente en el sistema operativo. Sirve tanto para quienes trabajan con Jupyter
Notebook en el navegador como para quienes prefieren un editor como Neovim/LazyVim.

## Idea general

Este repo **no trae librerías de análisis de datos preinstaladas**. Lo que trae es
la capacidad de crear, cuando quieras, tantos entornos conda como necesites — uno
por práctico o proyecto — sin mezclar dependencias entre ellos y sin tener que
reconstruir la imagen de Docker cada vez que agregás un proyecto nuevo o una
librería. Los entornos persisten aunque apagues y prendas el contenedor.

## Requisito único: Docker Desktop

No hace falta instalar Python, Conda ni nada más. Solo:

- **Docker Desktop** instalado y corriendo.
- Mac con **Apple Silicon (M1/M2/M3/M4)** o **Intel**: no hay ninguna diferencia de
  uso — Docker Desktop maneja la arquitectura automáticamente al bajar
  `continuumio/miniconda3`. No necesitás hacer nada especial en ningún caso.

## Levantar el repo por primera vez

```bash
git clone <url-del-repo> ml-bigdata-docker-starter
cd ml-bigdata-docker-starter
make up
```

La primera vez, `make up` construye la imagen (instala Jupyter Lab + ipykernel en
el entorno base) y arranca el contenedor. Al iniciar, el contenedor recorre
`environments/*.yml`, crea los entornos que todavía no existan (por eso la primera
vez va a tardar un poco más: crea el entorno de ejemplo `ejemplo-numpy-pandas`) y
los registra como kernels de Jupyter. Cuando termine vas a ver en la terminal:

```
Jupyter Lab -> http://localhost:8888
```

Abrí esa URL en el navegador. Entrás directo a la carpeta `projects/` y no hace
falta ningún token ni contraseña (el servidor corre sin auth porque es para uso
local, atrás del firewall de tu propia máquina).

## Crear un entorno nuevo para un proyecto nuevo

Con el contenedor corriendo (`make up`), desde otra terminal:

```bash
make new-env NAME=practico2 PACKAGES="pyspark matplotlib"
```

Esto genera `environments/practico2.yml`, crea el entorno conda con Python 3.11 +
`ipykernel` + los paquetes que pediste, y lo registra como kernel de Jupyter. No
hace falta reconstruir la imagen ni reiniciar el contenedor — el kernel nuevo
aparece disponible en Jupyter Lab en cuanto termina el comando (puede que tengas
que refrescar la pestaña del navegador o abrir un notebook nuevo para verlo en la
lista).

Si preferís armar el `.yml` a mano (por ejemplo para fijar versiones exactas),
podés crear el archivo directamente en `environments/` con el mismo formato que
`environments/ejemplo-numpy-pandas.yml` y reiniciar el contenedor (`make down &&
make up`) para que el entrypoint lo detecte y lo cree.

## Abrir Jupyter Lab y elegir el kernel correcto

1. Andá a [http://localhost:8888](http://localhost:8888).
2. Creá o abrí un notebook dentro de `projects/` (cada práctico en su propia
   subcarpeta, por ejemplo `projects/practico2/analisis.ipynb`).
3. En la esquina superior derecha del notebook, hacé clic en el nombre del kernel
   y elegí el que corresponda al proyecto — van a aparecer listados como
   `Python (nombre-del-entorno)`, por ejemplo `Python (practico2)`.

Cada notebook queda atado al kernel que elijas, así que un mismo proyecto puede
tener notebooks usando distintos entornos si hiciera falta, aunque lo normal es
usar siempre el kernel que coincide con el nombre del proyecto.

## Entrar por consola a un entorno específico

Para quienes trabajan con editores como Neovim/LazyVim en vez de notebooks, o
simplemente quieren correr un script Python desde la terminal con el entorno
correcto activado:

```bash
make shell ENV=practico2
```

Esto abre una bash dentro del contenedor con el entorno conda `practico2` ya
activado (`conda activate`). Desde ahí podés correr `python script.py`, `pip list`,
o cualquier comando como si el entorno estuviera instalado localmente.

## Uso con LazyVim / Neovim

El código y los notebooks de `projects/` están montados como bind mount: existen
como archivos reales en tu Mac (dentro de la carpeta del repo) y también dentro del
contenedor. Esto significa que podés editarlos con LazyVim **normalmente**, igual
que cualquier otro proyecto local — no hace falta editar dentro del contenedor ni
usar ningún plugin especial para eso.

Lo que sí vive únicamente dentro del contenedor es la **ejecución**: el intérprete
Python, las librerías instaladas y el servidor de Jupyter. El flujo típico con
LazyVim es:

1. Editás el código en `projects/<tu-proyecto>/` con LazyVim, desde el host, como
   siempre.
2. Para ejecutar o probar algo, abrís una terminal (podés usar la terminal
   integrada de LazyVim, `<leader>` + terminal, o una terminal aparte) y corrés
   `make shell ENV=<tu-proyecto>` desde la raíz del repo.
3. Dentro de esa shell ya estás en el entorno conda correcto y podés correr
   `python archivo.py`, tests, linters, etc.

**Fuera de alcance de este repo (a configurar después, paso a paso):** una
integración más fina —por ejemplo un plugin tipo `molten.nvim` o `jupytext` para
ejecutar celdas de notebook directo desde Neovim, o configurar el LSP de Python
(`pyright`/`basedpyright`) para que autocomplete resolviendo contra el intérprete
del entorno conda dentro del contenedor— no está incluida acá. Es una configuración
de tu Neovim/LazyVim local, no del repo, y se aborda en otra sesión una vez que
este entorno esté funcionando.

## Listar y borrar entornos

Listar los entornos conda que existen actualmente:

```bash
make list-envs
```

Borrar un entorno (elimina el entorno conda, su kernel de Jupyter registrado y su
archivo `.yml` en `environments/`):

```bash
make remove-env NAME=practico2
```

## Otros comandos

| Comando | Qué hace |
|---|---|
| `make up` | Construye (si hace falta) y levanta el contenedor |
| `make down` | Apaga el contenedor (los entornos y kernels persisten) |
| `make build` | Reconstruye la imagen sin levantar el contenedor |
| `make logs` | Sigue los logs del contenedor (útil para ver el progreso al crear entornos) |

## Troubleshooting

- **El puerto 8888 ya está en uso:** definí otro puerto antes de levantar, por
  ejemplo `JUPYTER_PORT=8890 make up`, y entrá por `http://localhost:8890`.
- **Cambié el Dockerfile y no se aplica:** `make build` fuerza la reconstrucción de
  la imagen; después `make up` de nuevo.
- **Quiero empezar de cero con los entornos:** `docker compose down -v` borra
  también los volúmenes con nombre (`conda-envs`, `jupyter-kernels`), así que la
  próxima vez que levantes el contenedor se recrean todos los entornos definidos en
  `environments/*.yml` desde cero. Usalo con cuidado, es destructivo.

## Por qué está armado así

Ver [`CLAUDE.md`](./CLAUDE.md) para el resumen de las decisiones de diseño
(usuario no-root, volúmenes con nombre, por qué `projects/` y `environments/*.yml`
sí se versionan en git, etc.).
