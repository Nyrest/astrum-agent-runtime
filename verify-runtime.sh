#!/usr/bin/env bash
set -euo pipefail

VERSIONS_DIR=/usr/local/share/astrum-agent-runtime/versions
# shellcheck disable=SC1091
source "${VERSIONS_DIR}/tool-versions.env"

trim_version() {
  sed -E 's/^v//; s/^Version[[:space:]]+//; s/ .*$//'
}

expect_exact() {
  local name="$1" actual="$2" expected="$3"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "${name}: expected ${expected}, got ${actual}" >&2
    exit 1
  fi
  printf '%-18s %s\n' "${name}" "${actual}"
}

echo "== locale and timezone =="
test "$(cat /etc/timezone)" = "Asia/Shanghai"
date
locale | grep 'LANG=en_US.UTF-8'

echo "== base commands =="
for cmd in printenv envsubst timeout flock stdbuf script git git-lfs gh rg aria2c tmux rsync 7z zip unzip unrar rclone ffmpeg ffprobe yt-dlp convert identify exiftool oxipng duckdb psql mysql redis-cli sqlite3 libreoffice pandoc jq yq fd; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== network and text tools =="
for cmd in dig nslookup ip ping nc nmap tcpdump traceroute whois cloudflared http websocat awk gawk grep envsubst diff patch csvcut mlr shellcheck shfmt hadolint ruff aws neon neonctl gws lark-cli sshpass; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== pinned tool versions =="
expect_exact bun "$(bun --version | trim_version)" "${BUN_VERSION}"
expect_exact uv "$(uv --version | awk '{print $2}' | trim_version)" "${UV_VERSION}"
expect_exact python "$(python --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)" "${PYTHON_VERSION}"
expect_exact yt-dlp "$(yt-dlp --version | trim_version)" "${YT_DLP_VERSION}"
expect_exact cloudflared "$(cloudflared --version | awk 'NR==1 {print $3}' | trim_version)" "${CLOUDFLARED_VERSION}"
expect_exact duckdb "$(duckdb --version | awk '{print $NF}' | trim_version)" "${DUCKDB_VERSION}"
expect_exact hadolint "$(hadolint --version | awk '{print $NF}' | trim_version)" "${HADOLINT_VERSION}"
expect_exact websocat "$(websocat --version | awk '{print $2}' | trim_version)" "${WEBSOCAT_VERSION}"
expect_exact oxipng "$(oxipng --version | awk '{print $2}' | trim_version)" "${OXIPNG_VERSION}"
expect_exact aws "$(aws --version 2>&1 | awk -F'[ /]' '{print $2}' | trim_version)" "${AWSCLI_VERSION}"
expect_exact pnpm "$(pnpm --version | trim_version)" "11.1.1"
expect_exact yarn "$(yarn --version | trim_version)" "1.22.22"
expect_exact prettier "$(prettier --version | trim_version)" "3.8.3"
expect_exact eslint "$(eslint --version | trim_version)" "10.3.0"
expect_exact tsx "$(tsx --version 2>/dev/null | awk 'NR==1 {print $2}' | trim_version)" "4.21.0"
expect_exact playwright "$(playwright --version | awk '{print $2}' | trim_version)" "1.60.0"
expect_exact vercel "$(vercel --version | awk 'NR==1 {print $2}' | trim_version)" "53.4.0"
expect_exact wrangler "$(wrangler --version | awk '{print $2}' | trim_version)" "4.90.1"
expect_exact gemini "$(gemini --version | awk '{print $NF}' | trim_version)" "0.42.0"

echo "== go =="
go version
command -v gofmt >/dev/null
printf '%-14s %s\n' "gofmt" "$(command -v gofmt)"

echo "== python packages =="
python - <<'PY'
from importlib import metadata
from pathlib import Path

requirements = Path('/usr/local/share/astrum-agent-runtime/versions/python-requirements.txt')
for raw in requirements.read_text().splitlines():
    raw = raw.strip()
    if not raw or raw.startswith('#'):
        continue
    name, expected = raw.split('==', 1)
    actual = metadata.version(name)
    if actual != expected:
        raise SystemExit(f'{name}: expected {expected}, got {actual}')
print('python package pins ok')
PY

echo "== node and bun =="
node --version | grep '^v24\.'
npm --version
bun --version
for cmd in turbo prettier eslint tsx playwright vercel wrangler gemini tsc pnpm yarn; do
  command -v "$cmd" >/dev/null
  printf '%-14s %s\n' "$cmd" "$(command -v "$cmd")"
done

echo "== headless office and browser tooling =="
libreoffice --headless --version
playwright --version

echo "runtime verification passed"
