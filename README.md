# Astrum Agent Runtime

[![Build](https://github.com/Nyrest/astrum-agent-runtime/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Nyrest/astrum-agent-runtime/actions/workflows/docker-image.yml)
[![Image Size](https://img.shields.io/badge/image%20size-1.9%20GB-blue?logo=docker)](https://github.com/Nyrest/astrum-agent-runtime/pkgs/container/astrum-agent-runtime)
[![License](https://img.shields.io/github/license/Nyrest/astrum-agent-runtime)](https://github.com/Nyrest/astrum-agent-runtime/blob/main/LICENSE)

A powerhouse Ubuntu 24.04 Docker image meticulously optimized for AI agents, developers, and automation workflows. It provides a "batteries-included" environment for the **Hermes Agent** and other Docker-based agent backends.

## 🚀 Quick Start

### 1. Pull the Image
```bash
docker pull ghcr.io/nyrest/astrum-agent-runtime:latest
```

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

This image includes a comprehensive suite of tools categorized for agentic tasks.

| Category | Key Tools & Packages |
| :--- | :--- |
| **Runtimes** | Node.js 24, Python 3.14 (uv), Bun, Go SDK, Java (JRE Headless) |
| **Package Managers** | `npm`, `pnpm`, `yarn`, `bun`, `uv`, `pip`, `pipx` |
| **Web & API CLIs** | `vercel`, `wrangler` (Cloudflare), `gemini` (Google), `gws` (Google Workspace), `lark-cli` (Feishu) |
| **Python Libraries** | `requests`, `httpx`, `pydantic`, `pandas`, `numpy`, `beautifulsoup4`, `ruff`, `duckdb` |
| **Document Processing** | LibreOffice (Headless), `pandoc`, `pypdf`, `pdfplumber`, `python-docx`, `openpyxl`, `python-pptx` |
| **Database Clients** | PostgreSQL, MySQL, Redis, SQLite, DuckDB, **Neon (`neonctl`)** |
| **Network Tools** | `curl`, `wget`, `aria2`, `nmap`, `cloudflared`, **HTTPie (`http`)**, `websocat`, `socat`, `sshpass` |
| **Cloud & DevOps** | `aws-cli`, `gh` (GitHub CLI), `git-lfs`, `rclone`, `hadolint`, `shellcheck` |
| **Multimedia** | `ffmpeg`, `yt-dlp`, ImageMagick, `exiftool`, `oxipng` |
| **Text & Data Utils** | `jq`, `yq`, `rg` (ripgrep), `fd`, `mlr` (miller), `csvkit`, `tmux` |
| **Build Essentials** | `gcc`, `g++`, `clang`, `cmake`, `ninja`, `make`, `gdb`, `lldb`, `strace` |
| **Compression** | `zip`, `unzip`, `7z`, `tar`, `zstd`, `unrar` |
| **Fonts & I18n** | Noto CJK (Chinese/Japanese/Korean), Noto Color Emoji, Liberation, DejaVu |

## 🤖 Hermes Agent Configuration

Optimized for the [Hermes Agent](https://github.com/nyrest/hermes) Docker backend.

```yaml
terminal:
  backend: docker
  docker_image: ghcr.io/nyrest/astrum-agent-runtime:latest
  docker_forward_env:
    - GITHUB_TOKEN
    - GEMINI_API_KEY
    - OPENAI_API_KEY
    - ANTHROPIC_API_KEY
```

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
- **Timezone:** `Asia/Shanghai`
- **Locales:** `en_US.UTF-8` (Default), `zh_CN.UTF-8` (Supported)
- **Workdir:** `/workspace`
- **Browsers:** Playwright is installed, but browser binaries (Chromium/Firefox) are **not** pre-included to keep image size manageable. Use `playwright install` if needed at runtime.
- **License:** [MIT](LICENSE)

---

## 🏗 Development & Contribution

### Building Locally

```bash
docker build -t astrum-agent-runtime .
```

### Verification

Run the built-in verification script to ensure all critical tools are operational:

```bash
docker run --rm astrum-agent-runtime verify-runtime
```

### Continuous Integration

Every push to `main` (excluding README changes) triggers a GitHub Actions workflow that builds and pushes the image to:
- `ghcr.io/nyrest/astrum-agent-runtime:latest`
- `ghcr.io/nyrest/astrum-agent-runtime:YYYYMMDD-shortsha`
