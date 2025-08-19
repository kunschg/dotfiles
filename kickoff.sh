#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT=$1
REMOTE_URL="git@github.com:kunschg/$PROJECT.git"

# 1. Initialize UV project
uv init "$PROJECT"
cd "$PROJECT"
mkdir src

# 2. Overwrite pyproject.toml with your standard config
cat > pyproject.toml << EOF
[project]
name = "$PROJECT"
version = "0.1.0"
description = "Add your description here"
authors = [
  { name="Guillaume Kunsch", email="kunschguillaume@gmail.com" },
]
readme = "README.md"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = [
  "docformatter>=1.7.5",
  "pre-commit>=4.2.0",
  "pyright>=1.1.400",
  "pytest>=8.3.5",
  "pytest-cov>=6.1.1",
  "ruff>=0.11.7",
  "typos>=1.31.1",
  "debugpy-run>=1.13",
  "pytest-split==0.10.0",
]

[build-system]
requires = ["hatchling","hatch-vcs"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/"]

[tool.hatch.metadata]
allow-direct-references = true

[tool.pyright]
reportMissingTypeStubs = false
reportPrivateImportUsage = false

[tool.ruff]
line-length = 88
target-version = "py312"
preview = true

[tool.ruff.lint]
preview = true
select = [
  "B006","E","F","W","C90","I","C4","PT","RSE","TID","TC","FLY","NPY","RUF","T10","Q"
]
[tool.ruff.lint.isort]
combine-as-imports = true

[tool.ruff.lint.mccabe]
max-complexity = 20

[tool.ruff.format]
preview = true

[tool.docformatter]
black = true
EOF

# 3. Write your .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: local
    hooks:
      - id: ruff lint
        name: ruff lint
        entry: uv run ruff check
        language: system

  - repo: local
    hooks:
      - id: ruff format
        name: ruff format
        entry: uv run ruff format
        language: system

  - repo: local
    hooks:
      - id: docformatter
        name: docformatter
        entry: uv run docformatter -ri .
        language: system

  - repo: local
    hooks:
      - id: typos
        name: typos
        entry: uv run typos
        language: system

  - repo: local
    hooks:
      - id: pyright
        name: pyright
        entry: uv run pyright
        language: system

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: check-toml
      - id: check-yaml
      - id: end-of-file-fixer
      - id: trailing-whitespace

# exclude any path matching this pattern
exclude: |
  (?x)^(
    \.gitignore
    | \.pre-commit-config\.yaml
    | uv\.lock
    | pyproject.toml
    | \.github/.*$
  )$
EOF

# 4. Add GitHub CI
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  pre-commit:
    name: Pre-commit
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install uv with cache
        uses: astral-sh/setup-uv@v5
        with:
          version: "latest"
          enable-cache: true
          cache-dependency-glob: "uv.lock"

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - run: uv sync
      - run: uv pip install pip
      - run: echo "$(pwd)/.venv/bin" >> $GITHUB_PATH
      - if: github.event_name == 'pull_request'
        run: git fetch origin ${{ github.base_ref }}

      - uses: pre-commit/action@v3.0.0
        with:
          extra_args: --all-files --show-diff-on-failure
EOF

# 5. Install env
uv sync

# 6. Git init on main, commit, push
gh repo create
git checkout -b main
git add .
git commit -m "chore: initial setup with uv, pre-commit, ruff & CI"
git push --set-upstream origin main
git push

echo
echo "✅ Project '$PROJECT' bootstrapped and pushed to '$REMOTE_URL' on branch 'main'."
