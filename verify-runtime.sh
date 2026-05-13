#!/usr/bin/env bash
set -euo pipefail

flavor="${ASTRUM_RUNTIME_FLAVOR:-full}"

echo "== locale =="
date
locale | grep 'LANG=en_US.UTF-8'

echo "== runtime flavor =="
printf '%s\n' "$flavor"

echo "== base commands =="
for cmd in printenv envsubst timeout flock stdbuf script git git-lfs gh rg aria2c tmux rsync 7z zip unzip unrar rclone ffmpeg ffprobe yt-dlp convert identify exiftool oxipng duckdb psql mysql redis-cli sqlite3 pandoc jq yq fd officecli mmdc; do
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
    "jupyterlab",
    "notebook",
    "ipykernel",
    "matplotlib",
    "seaborn",
    "scipy",
    "PIL",
    "imageio",
]
for module in modules:
    __import__(module)
print("python imports ok")
PY

case "$flavor" in
  full)
    echo "== academic fonts =="
    command -v fc-list >/dev/null
    font_index="$(mktemp)"
    fc-list >"$font_index"
    for pattern in 'CMU' 'STIX' 'TeX Gyre'; do
      match_file="$(mktemp)"
      if ! grep -F -m1 "$pattern" "$font_index" >"$match_file"; then
        rm -f "$match_file" "$font_index"
        echo "missing academic font: $pattern" >&2
        exit 1
      fi
      cat "$match_file"
      rm -f "$match_file"
      printf '%-20s %s\n' "$pattern" "installed"
    done
    rm -f "$font_index"

    echo "== headless office and browser tooling =="
    for cmd in libreoffice latexmk biber xelatex lualatex pdflatex pygmentize; do
      command -v "$cmd" >/dev/null
      printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
    done
    libreoffice --headless --version
    playwright --version
    ;;
  lite)
    echo "== lite exclusions =="
    for cmd in libreoffice latexmk biber xelatex lualatex pdflatex; do
      if command -v "$cmd" >/dev/null; then
        echo "unexpected command present in lite image: $cmd" >&2
        exit 1
      fi
      printf '%-14s %s\n' "$cmd" "absent"
    done
    playwright --version
    ;;
  *)
    echo "Unsupported ASTRUM_RUNTIME_FLAVOR: $flavor" >&2
    exit 1
    ;;
esac

echo "runtime verification passed"
