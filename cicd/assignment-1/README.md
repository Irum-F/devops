# Python CI - Lint, Unit Tests & Docker Build Check

A CI pipeline that checks the Python app automatically on every **push** and every
**pull request** that touches `cicd/assignment-1/`.

Workflow file: [`.github/workflows/python-ci.yaml`][wf]

## What I built

| File            | Purpose                                     |
| --------------- | ------------------------------------------- |
| `hello.py`      | Small app with a `say_hello()` function     |
| `test_hello.py` | Unit test for `say_hello()` using unittest  |
| `Dockerfile`    | Packages the app into a Python 3.12 image   |

The pipeline has three jobs chained with `needs:`. If one fails, the rest are skipped:

| Order | Job                | What it does                                            |
| ----- | ------------------ | ------------------------------------------------------- |
| 1     | Lint (flake8)      | Checks code style                                       |
| 2     | Unit tests         | Runs the tests on Python 3.10, 3.11 and 3.12 (a matrix) |
| 3     | Docker build check | Builds the image and runs it. Nothing is pushed         |

## Pipeline YAML

```yaml
name: Python CI - Lint, Unit Tests & Docker Build Check

on:
  push:
    paths:
      - "cicd/assignment-1/**"
      - ".github/workflows/python-ci.yaml"
  pull_request:
    paths:
      - "cicd/assignment-1/**"
      - ".github/workflows/python-ci.yaml"

defaults:
  run:
    working-directory: cicd/assignment-1

jobs:
  lint:
    name: Lint (flake8)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install flake8
        run: python -m pip install flake8

      - name: Run flake8
        run: flake8 . --max-line-length=100

  unit-tests:
    name: Unit tests (Python ${{ matrix.python-version }})
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Run unit tests
        run: python -m unittest discover -v

      - name: Notify of success
        if: success()
        run: echo "Tests passed on Python ${{ matrix.python-version }}"

  docker-build-check:
    name: Docker build check
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build image
        run: docker build -t hello-ci-check .

      - name: Run container
        run: docker run --rm hello-ci-check
```

## What I learnt

- Triggers: `push` and `pull_request`, and using `paths:` to limit a workflow to one folder.
- Jobs run in parallel by default. `needs:` turns them into ordered stages.
- A matrix runs the same job on several Python versions at the same time.
- `defaults.run.working-directory` saves repeating `cd` in every step.
- A CI Docker check only needs to build and run the image. Pushing belongs in CD.

## Issues I solved

- **`pip install unittest` failed**: `unittest` is part of Python's standard library,
  so it doesn't belong in `requirements.txt`. I removed it.
- **Lint failures**: flake8 flagged missing blank lines (E302/E305) and trailing
  whitespace. I fixed the code to pass.
- **Deprecated actions**: `actions/checkout@v2` and `setup-python@v2` run on retired
  Node versions. I upgraded them to `@v4` and `@v5`.

[wf]: ../../.github/workflows/python-ci.yaml
