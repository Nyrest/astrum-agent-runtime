# AI Agent Runtime Docker Image

Ubuntu 24.04 based runtime image for AI agents. It includes Node.js 24, Bun, uv-managed Python 3.14, common SDK/build tools, headless Office/PDF tooling, CJK/emoji fonts, database clients, browser automation tooling, and multimedia tools.

## Build

```bash
docker build -t astrum-agent-runtime:ubuntu24.04 .
```

## Verify

```bash
docker run --rm astrum-agent-runtime:ubuntu24.04 verify-runtime
```

## Run

```bash
docker run --rm -it -v "$PWD:/workspace" astrum-agent-runtime:ubuntu24.04
```

On PowerShell:

```powershell
docker run --rm -it -v "${PWD}:/workspace" astrum-agent-runtime:ubuntu24.04
```

## Hermes Agent

This image is intended for the Hermes Agent Docker backend. It preinstalls the runtime tools so Hermes does not need to `apt install` during a session, keeps the working directory at `/workspace`, and provides `/output` for gateway-visible exports.

Recommended Hermes settings:

```yaml
terminal:
  backend: docker
  docker_image: astrum-agent-runtime:ubuntu24.04
  docker_mount_cwd_to_workspace: true
  docker_volumes:
    - "/home/user/.hermes/cache/documents:/output"
  container_cpu: 4
  container_memory: 8192
  container_disk: 51200
  container_persistent: true
  docker_forward_env:
    - GITHUB_TOKEN
    - GH_TOKEN
    - NPM_TOKEN
    - VERCEL_TOKEN
    - CLOUDFLARE_API_TOKEN
    - GEMINI_API_KEY
    - GOOGLE_API_KEY
    - OPENAI_API_KEY
    - ANTHROPIC_API_KEY
    - HF_TOKEN
```

Only forward credentials you actually need in agent terminal sessions. Hermes does not pass arbitrary host secrets into Docker by default, and every variable listed in `docker_forward_env` is visible to commands executed inside the container.

Suggested `terminal.docker_forward_env` entries by use case:

| Use case | Environment variables |
| --- | --- |
| GitHub CLI, GitHub API, GitHub Packages/GHCR | `GITHUB_TOKEN`, `GH_TOKEN`, `CR_PAT` |
| npm registry publishing or private packages | `NPM_TOKEN`, `NODE_AUTH_TOKEN` |
| Vercel CLI and deployments | `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `VERCEL_TEAM_ID` |
| Cloudflare Wrangler and cloudflared | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_ZONE_ID`, `TUNNEL_TOKEN` |
| Gemini CLI / Google APIs | `GEMINI_API_KEY`, `GOOGLE_API_KEY`, `GOOGLE_APPLICATION_CREDENTIALS` |
| OpenAI-compatible model gateways | `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `AI_GATEWAY_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY`, `ANTHROPIC_BASE_URL` |
| Hugging Face | `HF_TOKEN`, `HUGGING_FACE_HUB_TOKEN` |
| AWS/S3/rclone workflows | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`, `AWS_DEFAULT_REGION`, `RCLONE_CONFIG` |
| Database tools | `DATABASE_URL`, `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, `MYSQL_HOST`, `MYSQL_TCP_PORT`, `MYSQL_USER`, `MYSQL_PWD`, `REDIS_URL` |
| SSH and remote Git operations | `SSH_AUTH_SOCK`, `GIT_SSH_COMMAND` |
| Proxy/networked environments | `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY` |

If you use a messaging gateway and want generated files to be sent back as media, write them inside the container under `/output/...` and emit the matching host path from the mounted export directory. Do not emit `/workspace/...` or `/output/...` unless that exact path is also valid on the host running the gateway.

Keep `docker_run_as_host_user` at the default `false` unless host file ownership matters more than root-owned tool caches. The image is fully provisioned at build time, so it can run as a host UID for mounted project edits, but root-owned paths such as `/root/.cache` will not be writable unless you mount writable replacements.

For maximum isolation, set Docker networking according to the task:

```yaml
terminal:
  backend: docker
  docker_network: none
```

Use a normal Docker network when the agent needs package downloads, GitHub, Vercel, Wrangler, Gemini CLI, cloudflared, yt-dlp, or external APIs.

## What Is Included

- Timezone and locale: `Asia/Shanghai`, default `en_US.UTF-8`; `zh_CN.UTF-8` is generated for CJK compatibility.
- Node.js 24 with npm.
- Bun latest with global tools: `turbo`, `prettier`, `eslint`, `tsx`, `playwright`, `vercel`, `wrangler`, `gemini` from `@google/gemini-cli`, `typescript`, `pnpm`, `yarn`.
- uv latest with Python 3.14 exposed as `python`, `python3`, and `python3.14`.
- Python tooling and packages: `pip`, `pipx`, `virtualenv`, `setuptools`, `wheel`, `requests`, `httpx`, `pydantic`, `python-dotenv`, `toml`, `beautifulsoup4`, `markdown`, `python-multipart`, `pypdf`, `pymupdf`, `pdfplumber`, `python-docx`, `openpyxl`, `python-pptx`, `pandas`, `pyarrow`, `tabulate`, `numpy`.
- Git tools: `git`, `gh`, `git-lfs`.
- Build and SDK tools: `build-essential`, `cmake`, `ninja`, `pkg-config`, `clang`, `llvm`, Go SDK, `gdb`, `lldb`, `strace`, and related compile utilities.
- Office/PDF tools: headless LibreOffice, `pandoc`, `poppler-utils`, `qpdf`, `ghostscript`.
- Fonts: Noto CJK, Noto Color Emoji, Liberation, DejaVu.
- Database clients: PostgreSQL, MySQL/MariaDB, Redis, SQLite.
- Network tools: `dnsutils`, `iproute2`, `iputils-ping`, `netcat-openbsd`, `nmap`, `tcpdump`, `traceroute`, `whois`, `cloudflared`, `telnet`, `socat`, `openssh-client`, `sshpass`.
- Text and shell tools: `gawk`, `grep`, `coreutils`, `moreutils`, `gettext-base`, `diffutils`, `patch`, `findutils`, `util-linux`, `procps`.
- Common agent tools: `rg`, `fd`, `aria2`, `tmux`, `rsync`, `7z`, `zip`, `unzip`, `rclone`, `jq`, `yq`, `envsubst`, `timeout`, `flock`, `stdbuf`, `script`.
- Multimedia tools: `ffmpeg`, `ffprobe`, `yt-dlp`, ImageMagick, `oxipng`.
- Playwright CLI is installed, but browser binaries are not preinstalled. Install a browser in derived images or containers only when needed.

## Size Notes

This image intentionally favors runtime completeness over being tiny. The largest pieces are LibreOffice, CJK fonts, build toolchains, and Python data libraries. Browser binaries are intentionally not preinstalled. The Dockerfile still uses `--no-install-recommends` and clears apt/Bun/uv/pip caches to keep the image from growing unnecessarily.
