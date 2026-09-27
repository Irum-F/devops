# Docker CD - Build & Push Image to Docker Hub

A CD pipeline that builds the app's Docker image and publishes it to Docker Hub
automatically on every push that touches `cicd/assignment-2/`. It can also be
started by hand from the Actions tab (`workflow_dispatch`).

Workflow file: [`.github/workflows/docker-image-cd.yaml`][wf]

## What I built

| File         | Purpose                                         |
| ------------ | ----------------------------------------------- |
| `app.py`     | Small app with a `say_hello()` function         |
| `Dockerfile` | Packages the app into a Python 3.12 image       |

The pipeline:

1. Logs in to Docker Hub with the repo secrets `DOCKER_USERNAME` and `DOCKER_PASSWORD`
   (a Docker Hub access token).
2. Builds the image and tags it with the **short commit SHA**.
3. Adds a second tag and pushes both:

| Pushed to     | Tags on Docker Hub                                              |
| ------------- | --------------------------------------------------------------- |
| `main`        | `irumfathima/cc-challenge:<sha>` and `:latest`                  |
| other branch  | `irumfathima/cc-challenge:<sha>` and `:<branch-name>`           |

The SHA tag means every build can be traced back to the exact commit it came from.
`latest` always points at whatever is on `main`.

## Pipeline YAML

```yaml
name: Docker CD - Build & Push Image to Docker Hub

on:
  push:
    paths:
      - "cicd/assignment-2/**"
      - ".github/workflows/docker-image-cd.yaml"
  workflow_dispatch:

jobs:
  build-and-publish:
    name: Build and push image
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        working-directory: cicd/assignment-2
        run: |
          registry="irumfathima"
          sha=$(git rev-parse --short HEAD)
          primary_tag="${registry}/cc-challenge:${sha}"

          docker build -t "${primary_tag}" -f Dockerfile .
          docker push "${primary_tag}"

          # branch names like feature/x are not valid image tags, so swap / for -
          current_branch="${GITHUB_REF_NAME//\//-}"
          if [ "${current_branch}" = "main" ]; then
            retention_tag="${registry}/cc-challenge:latest"
          else
            retention_tag="${registry}/cc-challenge:${current_branch}"
          fi
          docker tag "${primary_tag}" "${retention_tag}"
          docker push "${retention_tag}"
```

## What I learnt

- Storing credentials as repository secrets instead of putting them in code.
- Logging in to a registry inside a workflow with `docker/login-action`.
- Tagging images with the commit SHA plus `latest` or the branch name, so every
  image can be traced and rolled back.
- `workflow_dispatch` lets a pipeline be re-run by hand without a new commit.
- Giving the job only the permissions it needs (`contents: read`).

## Issues I solved

- **Invalid Docker tags from branch names**: branches like `feature/x` contain `/`,
  which isn't allowed in a tag. I replaced it with `-`.
- **Deprecated actions**: `actions/checkout@v2` and `docker/login-action@v1` run on
  retired Node versions. I upgraded them to `@v4` and `@v3`.
- **Workflow stopped running after moving repos**: GitHub only reads workflows from
  the repo root, and secrets don't move between repos. I moved the YAML to
  `.github/workflows/` and re-added the Docker Hub secrets.

[wf]: ../../.github/workflows/docker-image-cd.yaml
