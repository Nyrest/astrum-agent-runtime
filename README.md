# Astrum Agent Runtime

[![Build](https://github.com/Nyrest/astrum-agent-runtime/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Nyrest/astrum-agent-runtime/actions/workflows/docker-image.yml)
[![Image Size](https://img.shields.io/badge/image%20size-full%203.72%20GiB%20%7C%20lite%20smaller-blue?logo=docker)](https://github.com/Nyrest/astrum-agent-runtime/pkgs/container/astrum-agent-runtime)
[![License](https://img.shields.io/github/license/Nyrest/astrum-agent-runtime)](https://github.com/Nyrest/astrum-agent-runtime/blob/main/LICENSE)

A powerhouse Ubuntu 24.04 Docker image meticulously optimized for AI agents, developers, and automation workflows. It provides a "batteries-included" environment for the **Hermes Agent** and other Docker-based agent backends.

## 🚀 Quick Start

### 1. Pull the Image
```bash
docker pull ghcr.io/nyrest/astrum-agent-runtime:latest
```

Available image flavors:
- `ghcr.io/nyrest/astrum-agent-runtime:latest` → full image (same toolset as before)
- `ghcr.io/nyrest/astrum-agent-runtime:full` → explicit full tag
- `ghcr.io/nyrest/astrum-agent-runtime:lite` → slimmer image without giant document/font toolchains like LibreOffice, LaTeX, and the extra font packs

### 2. Configure Hermes Agent
Run the setup TUI to configure your environment:
```bash
hermes setup terminal
```
- Select **Docker** as the backend.
- Use `ghcr.io/nyrest/astrum-agent-runtime:latest` as the Docker image.

### 3. Manual Entry (Optional)
To mirror the production environment manually:

```bash
docker run --rm -it \
  -v "$HOME/.hermes/sandboxes/docker/default/home:/root" \
  -v "$HOME/.hermes/sandboxes/docker/default/workspace:/workspace" \
  ghcr.io/nyrest/astrum-agent-runtime:latest
```

*On Windows (PowerShell):*
```powershell
docker run --rm -it `
  -v "${HOME}/.hermes/sandboxes/docker/default/home:/root" `
  -v "${HOME}/.hermes/sandboxes/docker/default/workspace:/workspace" `
  ghcr.io/nyrest/astrum-agent-runtime:latest
```

## 📦 Pre-installed Packages

Two image flavors are published from the same Dockerfile:

- **full** — the original batteries-included image with document suites, large font packs, and LaTeX tooling
- **lite** — keeps the core agent/dev/runtime stack but omits the heaviest document/font packages to reduce image size

The table below describes the shared baseline plus the biggest full-only extras.

| Category | Key Tools & Packages |
| :--- | :--- |
| **Runtimes** | Node.js 24, Python 3.13 (uv), Bun, Go SDK |
| **Package Managers** | `npm`, `pnpm`, `yarn`, `bun`, `uv`, `pip`, `pipx` |
| **Web & API CLIs** | `vercel`, `wrangler` (Cloudflare), `gemini` (Google), `gws` (Google Workspace), `lark-cli` (Feishu), mermaid-cli (`mmdc`) |
| **Python Libraries** | `requests`, `httpx`, `pydantic`, `pandas`, `numpy`, `beautifulsoup4`, `ruff`, `duckdb` |
| **Document Processing** | `pandoc`, **`officecli`**, `pypdf`, `pdfplumber`, `python-docx`, `openpyxl`, `python-pptx` |
| **Database Clients** | PostgreSQL, MySQL, Redis, SQLite, DuckDB, **Neon (`neonctl`)** |
| **Network Tools** | `curl`, `wget`, `aria2`, `nmap`, `cloudflared`, **HTTPie (`http`)**, `websocat`, `socat`, `sshpass` |
| **Cloud & DevOps** | `aws-cli`, `gh` (GitHub CLI), `git-lfs`, `rclone`, `hadolint`, `shellcheck` |
| **Multimedia** | `ffmpeg`, `yt-dlp`, ImageMagick, `exiftool`, `oxipng` |
| **Text & Data Utils** | `jq`, `yq`, `rg` (ripgrep), `fd`, `mlr` (miller), `csvkit`, `tmux` |
| **Build Essentials** | `gcc`, `g++`, `clang`, `cmake`, `ninja`, `make`, `gdb`, `lldb`, `strace` |
| **Compression** | `zip`, `unzip`, `7z`, `tar`, `zstd`, `unrar` |
| **full-only extras** | LibreOffice (Headless), Java (JRE Headless), Noto/CMU/STIX/TeX Gyre fonts, `latexmk`, `biber`, `chktex`, `lualatex`, `xelatex`, `pdflatex` |
| **Data Science & Viz** | JupyterLab, Notebook, matplotlib, seaborn, scipy, pillow, imageio |

## 🤖 Hermes Agent Configuration

Optimized for the [Hermes Agent](https://github.com/nyrest/hermes) Docker backend.

```yaml
terminal:
  backend: docker
  docker_image: ghcr.io/nyrest/astrum-agent-runtime:latest
  docker_forward_env:
    - TZ
    - GITHUB_TOKEN
    - GEMINI_API_KEY
    - OPENAI_API_KEY
    - ANTHROPIC_API_KEY
```

Use `:latest`/`:full` for the current batteries-included environment, or switch `docker_image` to `ghcr.io/nyrest/astrum-agent-runtime:lite` for a smaller base image.

## 🔑 Environment Variables

Common variables to forward for specific use cases:

| Service | Variables |
| :--- | :--- |
| **GitHub** | `GITHUB_TOKEN`, `GH_TOKEN` |
| **AI Providers** | `GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `HF_TOKEN` |
| **Cloud** | `VERCEL_TOKEN`, `CLOUDFLARE_API_TOKEN`, `AWS_ACCESS_KEY_ID` |
| **Databases** | `DATABASE_URL`, `PGPASSWORD`, `MYSQL_PWD` |

## 🛠 Technical Details

- **Base Image:** `ubuntu:24.04`
- **Locales:** `en_US.UTF-8`
- **Workdir:** `/workspace`
- **Browsers:** Playwright is installed, but browser binaries (Chromium/Firefox) are **not** pre-included to keep image size manageable. Use `playwright install` if needed at runtime.
- **License:** [MIT](LICENSE)

---

## 🏗 Development & Contribution

### Building Locally

```bash
docker build -t astrum-agent-runtime:full --build-arg RUNTIME_FLAVOR=full .
docker build -t astrum-agent-runtime:lite --build-arg RUNTIME_FLAVOR=lite .
```

### Verification

Run the built-in verification script to ensure all critical tools are operational:

```bash
docker run --rm astrum-agent-runtime:full verify-runtime
docker run --rm astrum-agent-runtime:lite verify-runtime
```

### Continuous Integration

Every push to `main` (excluding README changes) triggers a GitHub Actions workflow that builds and pushes both image flavors:
- `ghcr.io/nyrest/astrum-agent-runtime:latest` and `ghcr.io/nyrest/astrum-agent-runtime:full`
- `ghcr.io/nyrest/astrum-agent-runtime:lite`
- `ghcr.io/nyrest/astrum-agent-runtime:full-YYYYMMDD-shortsha`
- `ghcr.io/nyrest/astrum-agent-runtime:lite-YYYYMMDD-shortsha`
