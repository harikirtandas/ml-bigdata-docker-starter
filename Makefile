COMPOSE = HOST_UID=$$(id -u) HOST_GID=$$(id -g) docker compose

up:
	@mkdir -p environments-data
	$(COMPOSE) up -d --build
	@echo "Jupyter Lab -> http://localhost:$${JUPYTER_PORT:-8888}"

down:
	docker compose down

build:
	$(COMPOSE) build

logs:
	docker compose logs -f

new-env:
	@if [ -z "$(NAME)" ]; then \
		echo "Uso: make new-env NAME=proyecto1 PACKAGES=\"numpy pandas\""; \
		exit 1; \
	fi
	docker compose exec jupyter new-env.sh $(NAME) $(PACKAGES)

remove-env:
	@if [ -z "$(NAME)" ]; then \
		echo "Uso: make remove-env NAME=proyecto1"; \
		exit 1; \
	fi
	docker compose exec jupyter remove-env.sh $(NAME)

list-envs:
	docker compose exec jupyter list-envs.sh

shell:
	@if [ -z "$(ENV)" ]; then \
		echo "Uso: make shell ENV=proyecto1"; \
		exit 1; \
	fi
	docker compose exec jupyter bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate $(ENV) && exec bash"

.PHONY: up down build logs new-env remove-env list-envs shell
