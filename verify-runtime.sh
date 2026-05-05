#!/usr/bin/env bash
set -euo pipefail

echo "== locale and timezone =="
test "$(cat /etc/timezone)" = "Asia/Shanghai"
date
locale | grep 'LANG=en_US.UTF-8'

echo "== base commands =="
for cmd in printenv envsubst timeout flock stdbuf script git git-lfs gh rg aria2c tmux rsync 7z zip unzip unrar rclone ffmpeg ffprobe yt-dlp convert identify exiftool oxipng duckdb psql mysql redis-cli sqlite3 libreoffice pandoc jq yq fd officecli; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== network and text tools =="
for cmd in dig nslookup ip ping nc nmap tcpdump traceroute whois cloudflared http websocat awk gawk grep envsubst diff patch csvcut mlr shellcheck shfmt hadolint ruff aws neon neonctl gws lark-cli sshpass; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== node and bun =="
node --version | grep '^v24\.'
npm --version
bun --version
for cmd in turbo prettier eslint tsx playwright vercel wrangler gemini tsc pnpm yarn; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== go =="
go version
command -v gofmt >/dev/null
printf '%-14s %s\n' "gofmt" "$(command -v gofmt)"

echo "== python =="
python --version | grep 'Python 3.13'
python3 --version | grep 'Python 3.13'
python3.13 --version | grep 'Python 3.13'
pip --version
python - <<'PY'
modules = [
    "requests",
    "httpx",
    "pydantic",
    "dotenv",
    "toml",
    "duckdb",
    "bs4",
    "markdown",
    "multipart",
    "pypdf",
    "fitz",
    "pdfplumber",
    "docx",
    "openpyxl",
    "pptx",
    "pandas",
    "pyarrow",
    "tabulate",
    "numpy",
]
for module in modules:
    __import__(module)
print("python imports ok")
PY

echo "== headless office and browser tooling =="
libreoffice --headless --version
playwright --version

echo "runtime verification passed"
