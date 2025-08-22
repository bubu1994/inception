SHELL := /bin/bash
ENV_FILE = ./srcs/.env
PASSWORDS_FILE = ./srcs/.passwords_env
LOGIN = gebuqaj
MARIA_DIR = mariadb_vol
WP_DIR = wordpress_vol
STACK_NAME = inception
REQUIRED_VARS = MYSQL_DATABASE MYSQL_USER WP_ADMIN_USER WP_ADMIN_EMAIL WP_USER WP_USER_EMAIL
PASSWORDS = MYSQL_PASSWORD WP_ADMIN_PASSWORD WP_USER_PASSWORD
SECRETS = mysql_password wp_admin_password wp_user_password

-include $(ENV_FILE)
-include $(PASSWORDS_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
export $(shell sed 's/=.*//' $(PASSWORDS_FILE))


all: check-dirs check-env check-passwords
	docker compose -f ./srcs/docker-compose.yml up

rebuild: check-dirs check-env check-passwords down
	docker compose -f ./srcs/docker-compose.yml up -d --build

# Ne pas lancer un 'make prod' pendant l'exécution de l'application
prod: check-dirs check-env check-secrets
	docker build -t mariadb:prod srcs/requirements/mariaDB; \
	docker build -t wordpress:prod srcs/requirements/wordpress; \
	docker build -t nginx:prod srcs/requirements/nginx; \
	docker stack deploy -c ./srcs/docker-compose.prod.yml inception


check-dirs:
	@[ -d /home/$(LOGIN)/data/$(MARIA_DIR) ] || sudo mkdir -p /home/$(LOGIN)/data/$(MARIA_DIR)
	@[ -d /home/$(LOGIN)/data/$(WP_DIR) ] || sudo mkdir -p /home/$(LOGIN)/data/$(WP_DIR)

check-env:
	@for var in $(REQUIRED_VARS); do \
		if [ -z "$${!var}" ]; then \
			echo "La variable d'environnement '$$var' est manquante dans .env"; \
			exit 1; \
		fi; \
	done;

check-passwords:
	@for var in $(PASSWORDS); do \
		if [ -z "$${!var}" ]; then \
			echo "Le mot de passe '$$var' est manquant dans .env"; \
			exit 1; \
		fi; \
	done;

check-secrets:
	@if docker info | grep -q "Swarm: inactive"; then \
		docker swarm init > /dev/null; \
		echo "Swarm initialisé. Initialiser les secrets nécessaires svp"; \
		exit 1; \
	fi; \
	for secret in $(SECRETS); do \
		if ! docker secret ls --format "{{.Name}}" | grep -q "^$$secret$$"; then \
			echo "Erreur: secret Docker $$secret manquant"; \
			exit 1; \
		fi; \
	done


down:
	docker compose -f ./srcs/docker-compose.yml down
	@if docker info | grep -q "Swarm: active"; then \
		docker stack rm inception; \
		docker swarm leave --force; \
	fi

clean: down
	docker system prune -af --volumes
	-docker volume rm $$(docker volume ls -q)

fclean: clean
	sudo rm -rf /home/$(LOGIN)/data/
