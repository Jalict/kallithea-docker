# Kallithea Docker Setup
[![Docker Pulls](https://img.shields.io/docker/pulls/jalict/kallithea.svg)](https://hub.docker.com/r/jalict/kallithea)

This repository provides a docker images for running [Kallithea](https://kallithea-scm.org/) [kallithea](https://kallithea-scm.org/) since most I could find were heavily outdated or couldn't be built any longer.

This is my first attempt in publishing a docker image.

## Setup
Use the `docker-compose.yml` file.
```yml
services:
  kallithea:
    image: jalict/kallithea
    ports:
      - "5000:5000"
    volumes:
      - kallithea_data:/opt/kallithea
      - kallithea_repos:/opt/repos
    environment:
      CONFIG_FILE: "/opt/kallithea/my.ini"
      DB_FILE: "/opt/kallithea/kallithea.db"
      REPO_ROOT: "/opt/repos"
      ADMIN_USER: "admin"
      ADMIN_PASS: "password"
      ADMIN_EMAIL: "admin@example.com"
volumes:
  kallithea_data: {}
  kallithea_repos: {}
```


Start the service with: 
```bash
docker compose up -d
```

The Kallithea web interface will be available on `http://localhost:5000`

## Note
The image is set to `sqlite` and I do not intend to make support unless someone wants to do to initial work via pull request.
