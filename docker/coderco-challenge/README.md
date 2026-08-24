# CoderCo Containers Challenge

A multi-service containerized application built for the CoderCo DevOps Academy Docker module challenge. Combines a Flask web app, Redis for a persistent visit counter, and Nginx as a reverse proxy in front of the app.

## Project Overview

This project demonstrates:
- A Flask app with two routes: a welcome page and a Redis-backed visit counter
- Redis integration for fast, persistent state management (with a named volume so data survives restarts)
- Nginx as a reverse proxy sitting in front of the Flask app, using an upstream block
- Environment-based configuration for Redis connection details
- Multi-container orchestration with Docker Compose, including service dependencies

## Architecture

```
                     ┌────────────┐
        Client ───▶  │   Nginx    │  (port 5000, exposed to host)
                     └─────┬──────┘
                           │ proxy_pass via upstream "flask_app"
                           ▼
                     ┌────────────┐
                     │    web     │  (Flask app, internal port 5000)
                     └─────┬──────┘
                           │
                           ▼
                     ┌────────────┐
                     │   Redis    │  (visit counter, persisted via volume)
                     └────────────┘
```

Only Nginx's port is published to the host (`5000:5000`). The Flask `web` service only `expose`s port 5000 internally, so it's reachable from Nginx but not directly from outside the Docker network.

## Project Structure

```
├── count.py               # Flask application (welcome + counter routes)
├── Dockerfile             # Docker image configuration for the Flask app
├── docker-compose.yml     # Multi-service orchestration (web, redis, nginx)
├── nginx.conf             # Nginx reverse proxy configuration
└── README.md              # This file
```

## Application Routes

| Route     | Description                                            |
|-----------|--------------------------------------------------------|
| `/`       | Returns a welcome message                              |
| `/count`  | Increments and returns a Redis-backed visit counter    |

## Services

**web**
- Built from the local `Dockerfile` (Python 3.8-slim base)
- Installs `flask` and `redis` via pip
- Reads `REDIS_HOST` and `REDIS_PORT` from environment variables (set in `docker-compose.yml`)
- Depends on `redis` being available before starting

**redis**
- Uses the official `redis:latest` image
- Persists data with a named volume (`redis-data:/data`) so the counter survives container restarts
- Exposes port `6379`

**nginx**
- Uses the official `nginx:latest` image
- Publishes port `5000` to the host
- Proxies all requests to the `web` service via an `upstream flask_app` block pointing to `web:5000`
- Depends on `web` being available before starting

## Setup Instructions

### 1. Clone and navigate to the project

```bash
git clone https://github.com/Irum-F/docker.git
cd coderco-challenge
```

### 2. Build and start all services

```bash
docker-compose up --build
```

### 3. Verify

```bash
curl http://localhost:5000
curl http://localhost:5000/count
```

Refresh `/count` a few times to see the counter increment. Because Redis persists data via its volume, the count survives a `docker-compose restart`.

### 4. Tear down

```bash
docker-compose down
```

To also remove the persisted Redis volume:

```bash
docker-compose down -v
```

## Errors Faced & Solutions

### 1. Nginx service rejected in docker-compose.yml
**Error:** `additional properties 'nginx' not allowed`
**Cause:** The `nginx` service block wasn't indented under `services:` — it was written as a top-level key
**Solution:** Correctly nested `nginx:` and its config (image, ports, volumes, depends_on) under `services:` with consistent indentation

### 2. Image deletion blocked by running container
**Error:** `conflict: unable to delete <image> (cannot be forced) - image is being used by running container`
**Cause:** Tried removing an image while a container built from it was still running
**Solution:** Stopped and removed the container first (`docker stop` + `docker rm`), then removed the image

### 3. Port and container name conflicts on rebuild
**Error:** `port is already allocated` / `container name already in use`
**Cause:** Leftover containers from previous `docker-compose up` runs still holding ports/names
**Solution:** Ran `docker-compose down` before rebuilding, and manually stopped/removed stray containers when needed

## What I Learned

- Structuring a reverse proxy with Nginx using an `upstream` block instead of hardcoding a single backend
- Keeping the app service unpublished (`expose` only) and letting Nginx be the single entry point
- Persisting Redis data across container restarts using named volumes
- Correct YAML structure and indentation rules in Docker Compose files
- Debugging inter-container DNS resolution issues
- Managing container/image lifecycle conflicts during iterative development