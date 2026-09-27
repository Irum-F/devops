# CI/CD with GitHub Actions

Work for the CI/CD module: two pipelines built with GitHub Actions.

| Assignment         | Pipeline                                          | Workflow file         |
| ------------------ | ------------------------------------------------- | --------------------- |
| [assignment-1][a1] | Python CI - Lint, Unit Tests & Docker Build Check | [python-ci.yaml][w1]  |
| [assignment-2][a2] | Docker CD - Build & Push Image to Docker Hub      | [docker-image-cd][w2] |

Each assignment folder has its own README with the pipeline YAML, what I learnt
and the issues I solved.

```
cicd/
├── assignment-1/              Python app + unit tests + Dockerfile (CI)
├── assignment-2/              App + Dockerfile shipped to Docker Hub (CD)
├── scripts/
│   ├── custom-action/         my JavaScript GitHub Action
│   └── practice-workflows/    workflows from the lessons
└── README.md
```

> GitHub only runs workflows from `.github/workflows/` at the **root** of a repo,
> so the YAML lives there. Each workflow has a `paths:` filter so it only runs
> when its own assignment folder changes.

---

## Extras (`scripts/`)

**custom-action/**: a JavaScript GitHub Action that greets someone and outputs the
time. It's published from [Irum-F/irum-custom-actions][ca] and used like this:

```yaml
- uses: Irum-F/irum-custom-actions@main
  with:
    who-to-greet: 'Hello, its me, Irum!'
```

**practice-workflows/**: workflows from the lessons, commented out so they don't run:

| File                   | What it shows                                      |
| ---------------------- | -------------------------------------------------- |
| `matrix-tests.yaml`    | Running tests across several Python versions       |
| `manual-dispatch.yaml` | `workflow_dispatch` with a dropdown input          |
| `secrets.yaml`         | Using repo secrets and passing them as env vars    |
| `custom-action.yaml`   | Calling my custom action                           |
| `yaml-basics/`         | YAML syntax notes and a first hello-world workflow |

## Issues I solved across the module

- **YAML syntax errors**: indentation mistakes broke early workflows. I fixed them
  by learning YAML's key/value, list and nesting rules (`scripts/practice-workflows/yaml-basics`).
- **Custom action failed with an `@actions/core` exports error**: I downgraded
  `@actions/core` to a version that works with the action's CommonJS setup.
- **Workflows not running after moving into this repo**: GitHub only reads
  `.github/workflows/` at the repo root. I moved the YAML there and added `paths:` filters.

[a1]: assignment-1
[a2]: assignment-2
[w1]: ../.github/workflows/python-ci.yaml
[w2]: ../.github/workflows/docker-image-cd.yaml
[ca]: https://github.com/Irum-F/irum-custom-actions
