# Docker Symfony 5.0.2

### Requirements

- git
- docker
- docker-compose
- make

### Environment

| Service   | Version |
| --------- | ------- |
| Apache    | 2.4     |
| PHP       | 7.4     |
| Mysql     | 5.7     |
| PMA       | latest  |
| Mailhog   | latest  |

### Usage

```
make install
make up
make down
make file-install
make directory-install
make directory-permission
make composer-install
make db-drop
make db-create
make db-diff
make db-migrate
make db-fixtures
make db-install
make yarn-install
make yarn-encore-dev
make yarn-build
```

### Install

Disable chmod for git

```
git config core.fileMode false
```

Install all

```
make install
```

### Compile live Js & Css

```
docker-composer exec -u www-data node yarn watch
```

### Service

| Service   | Url                          |
| --------- | ---------------------------- |
| Apache    |  http://localhost            |
| PMA       |  http://localhost:8081       |
| Mailhog   |  http://localhost:8025       |