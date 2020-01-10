
APP_UID					?= $(id -u)
APP_GID				    ?= www-data
APP_COMPOSE				?= docker-compose.yml
APP_CHMOD				?= 777
APP_ENV					?= dev

DOCKER_COMPOSE 			= docker-compose
DOCKER_COMPOSE_EXEC 	= $(DOCKER_COMPOSE) exec

EXEC_APACHE 			= $(DOCKER_COMPOSE_EXEC) apache
EXEC_APACHE_USER 		= $(DOCKER_COMPOSE_EXEC) -u $(APP_GID) apache
EXEC_APACHE_COMPOSER 	= $(EXEC_APACHE_USER) composer
EXEC_APACHE_CONSOLE 	= $(EXEC_APACHE_USER) php bin/console

EXEC_NODE				= $(DOCKER_COMPOSE_EXEC) node
EXEC_NODE_USER		    = $(DOCKER_COMPOSE_EXEC) -u $(APP_GID) node

up:
	$(DOCKER_COMPOSE) -f $(APP_COMPOSE) up -d --build

down:
	$(DOCKER_COMPOSE) down -v

file-install:
	$(EXEC_APACHE_USER) cp docker/environment/.env .env
	$(EXEC_APACHE_USER) cp docker/environment/.env.$(APP_ENV) .env.$(APP_ENV)
	$(EXEC_APACHE_USER) cp docker/htaccess/.htaccess.$(APP_ENV) public/.htaccess

directory-install:
	$(EXEC_APACHE_USER) mkdir -p var/cache
	$(EXEC_APACHE_USER) mkdir -p var/log

directory-permission:
	$(EXEC_APACHE) chmod $(APP_CHMOD) -R var/cache
	$(EXEC_APACHE) chmod $(APP_CHMOD) -R var/log

composer-install:
	$(EXEC_APACHE_COMPOSER) install --no-suggest --no-progress

db-drop:
	$(EXEC_APACHE_CONSOLE) doctrine:database:drop --force --if-exists

db-create:
	$(EXEC_APACHE_CONSOLE) doctrine:database:create --if-not-exists

db-migrate:
	$(EXEC_APACHE_CONSOLE) doctrine:migrations:migrate -n

db-diff:
	$(EXEC_APACHE_CONSOLE) doctrine:migrations:diff

db-fixtures:
	$(EXEC_APACHE_CONSOLE) doctrine:fixtures:load -n

db-install: db-drop db-create #db-migrate

yarn-install:
	$(EXEC_NODE_USER) yarn install

yarn-encore-dev:
	$(EXEC_NODE_USER) yarn encore dev

yarn-build:
	$(EXEC_NODE_USER) yarn build

cache-clear:
	$(EXEC_APACHE_CONSOLE) cache:clear --env=$(APP_ENV)

install: up file-install directory-install directory-permission composer-install db-install yarn-install yarn-encore-dev cache-clear