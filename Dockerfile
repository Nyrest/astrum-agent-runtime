FROM ubuntu:24.04

LABEL org.opencontainers.image.title="astrum-agent-runtime" \
      org.opencontainers.image.description="Ubuntu 24.04 AI agent runtime optimized for Hermes Agent Docker backend"

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=24
ARG RUNTIME_FLAVOR=full
ARG BUN_INSTALL=/opt/bun
ARG UV_INSTALL_DIR=/usr/local/bin
ARG UV_PYTHON_INSTALL_DIR=/opt/uv-python
ARG PYTHON_VENV=/opt/python

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    ASTRUM_RUNTIME_FLAVOR=${RUNTIME_FLAVOR} \
    BUN_INSTALL=${BUN_INSTALL} \
    UV_INSTALL_DIR=${UV_INSTALL_DIR} \
    UV_PYTHON_INSTALL_DIR=${UV_PYTHON_INSTALL_DIR} \
    PYTHON_VENV=${PYTHON_VENV} \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH=${PYTHON_VENV}/bin:/usr/local/bin:${BUN_INSTALL}/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY versions /tmp/runtime-versions

# hadolint ignore=DL3008
# Fast-moving curl/npm/uv/pip assets are pinned below with exact versions and SHA-256 checks.
# Apt package versions are intentionally left to signed repository metadata so Ubuntu and vendor security
# updates can flow, while the third-party NodeSource/GitHub CLI trust roots are still constrained via
# dedicated keyrings above.
RUN set -eux; \
    set -a; source /tmp/runtime-versions/tool-versions.env; set +a; \
    printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "60";' \
        'Acquire::https::Timeout "60";' \
        'APT::Get::Assume-Yes "true";' \
    > /etc/apt/apt.conf.d/99agent-runtime-retries; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg gpg lsb-release apt-transport-https software-properties-common tzdata locales; \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen; \
    sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; \
    locale-gen; \
    add-apt-repository -y multiverse; \
    install -d -m 0755 /etc/apt/keyrings; \
    curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 --retry-connrefused \
        https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list; \
    curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 --retry-connrefused \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    common_packages=( \
        nodejs git git-lfs gh build-essential cmake ninja-build pkg-config autoconf automake libtool make gcc g++ clang llvm golang-go \
        gdb lldb strace file patch diffutils grep gawk findutils coreutils util-linux procps gettext-base moreutils expect shellcheck \
        shfmt csvkit httpie jq yq ripgrep fd-find miller aria2 tmux rsync p7zip-full zip unzip xz-utils zstd tar gzip bzip2 unrar rclone \
        openssh-client sshpass netcat-openbsd dnsutils iputils-ping iproute2 nmap tcpdump traceroute whois telnet socat less vim-tiny nano \
        tree htop postgresql-client default-mysql-client redis-tools sqlite3 pandoc poppler-utils qpdf ghostscript ffmpeg imagemagick \
        libimage-exiftool-perl libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libatk1.0-0 libatk-bridge2.0-0 libnss3 libnspr4 libx11-6 \
        libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
        libgbm1 libgtk-3-0 libdrm2 libasound2t64 libdbus-1-3 libatspi2.0-0 libxkbcommon0 \
    ); \
    full_only_packages=( \
        libreoffice libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-java-common default-jre-headless \
        fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-core fonts-liberation fonts-dejavu fontconfig \
        latexmk biber chktex lacheck python3-pygments lmodern tex-gyre texlive-latex-base texlive-latex-recommended texlive-latex-extra \
        texlive-luatex texlive-xetex texlive-fonts-recommended texlive-fonts-extra texlive-font-utils texlive-pictures texlive-pstricks \
        texlive-science texlive-publishers texlive-bibtex-extra texlive-extra-utils texlive-lang-cjk texlive-lang-chinese texlive-lang-japanese \
        fonts-cmu fonts-stix fonts-texgyre \
    ); \
    packages=( "${common_packages[@]}" ); \
    if [ "${RUNTIME_FLAVOR}" = "full" ]; then packages+=( "${full_only_packages[@]}" ); fi; \
    apt-get install -y --no-install-recommends "${packages[@]}"; \
    git lfs install --system; \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    set -a; source /tmp/runtime-versions/tool-versions.env; set +a; \
    fetch_and_verify() { \
        local url="$1" dest="$2" expected_sha="$3"; \
        curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 --retry-connrefused -o "$dest" "$url"; \
        echo "${expected_sha}  $dest" | sha256sum -c -; \
    }; \
    case "$(dpkg --print-architecture)" in \
        amd64) \
            bun_asset='bun-linux-x64.zip'; \
            bun_sha="${BUN_X64_SHA256}"; \
            ;; \
        arm64) \
            bun_asset='bun-linux-aarch64.zip'; \
            bun_sha="${BUN_AARCH64_SHA256}"; \
            ;; \
        *) \
            echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; \
            exit 1; \
            ;; \
    esac; \
    install -d -m 0755 "${BUN_INSTALL}/bin" /tmp/bun; \
    fetch_and_verify "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/${bun_asset}" /tmp/bun.zip "${bun_sha}"; \
    unzip -q /tmp/bun.zip -d /tmp/bun; \
    install -m 0755 /tmp/bun/*/bun "${BUN_INSTALL}/bin/bun"; \
    ln -sf "${BUN_INSTALL}/bin/bun" /usr/local/bin/bun; \
    ln -sf "${BUN_INSTALL}/bin/bun" /usr/local/bin/bunx; \
    bun --version | grep -Fx "${BUN_VERSION}"; \
    xargs -a /tmp/runtime-versions/bun-global-packages.txt bun add -g; \
    rm -rf /root/.bun/install/cache; \
    xargs -a /tmp/runtime-versions/npm-global-packages.txt npm install -g; \
    npm cache clean --force

RUN set -eux; \
    set -a; source /tmp/runtime-versions/tool-versions.env; set +a; \
    fetch_and_verify() { \
        local url="$1" dest="$2" expected_sha="$3"; \
        curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 --retry-connrefused -o "$dest" "$url"; \
        echo "${expected_sha}  $dest" | sha256sum -c -; \
    }; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
        amd64) \
            yt_dlp_asset='yt-dlp_linux'; \
            yt_dlp_sha="${YT_DLP_X86_64_SHA256}"; \
            cloudflared_asset='cloudflared-linux-amd64.deb'; \
            cloudflared_sha="${CLOUDFLARED_AMD64_SHA256}"; \
            duckdb_asset='duckdb_cli-linux-amd64.zip'; \
            duckdb_sha="${DUCKDB_AMD64_SHA256}"; \
            hadolint_asset='hadolint-linux-x86_64'; \
            hadolint_sha="${HADOLINT_X86_64_SHA256}"; \
            websocat_asset='websocat.x86_64-unknown-linux-musl'; \
            websocat_sha="${WEBSOCAT_X86_64_SHA256}"; \
            oxipng_asset="oxipng_${OXIPNG_VERSION}-1_amd64.deb"; \
            oxipng_sha="${OXIPNG_AMD64_SHA256}"; \
            ;; \
        arm64) \
            yt_dlp_asset='yt-dlp_linux_aarch64'; \
            yt_dlp_sha="${YT_DLP_AARCH64_SHA256}"; \
            cloudflared_asset='cloudflared-linux-arm64.deb'; \
            cloudflared_sha="${CLOUDFLARED_ARM64_SHA256}"; \
            duckdb_asset='duckdb_cli-linux-arm64.zip'; \
            duckdb_sha="${DUCKDB_ARM64_SHA256}"; \
            hadolint_asset='hadolint-linux-arm64'; \
            hadolint_sha="${HADOLINT_ARM64_SHA256}"; \
            websocat_asset='websocat.aarch64-unknown-linux-musl'; \
            websocat_sha="${WEBSOCAT_AARCH64_SHA256}"; \
            oxipng_asset="oxipng_${OXIPNG_VERSION}-1_arm64.deb"; \
            oxipng_sha="${OXIPNG_ARM64_SHA256}"; \
            ;; \
        *) \
            echo "Unsupported architecture: ${arch}" >&2; \
            exit 1; \
            ;; \
    esac; \
    fetch_and_verify "https://github.com/yt-dlp/yt-dlp/releases/download/${YT_DLP_VERSION}/${yt_dlp_asset}" /usr/local/bin/yt-dlp "${yt_dlp_sha}"; \
    chmod +x /usr/local/bin/yt-dlp; \
    yt-dlp --version | grep -Fx "${YT_DLP_VERSION}"; \
    fetch_and_verify "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/${cloudflared_asset}" /tmp/cloudflared.deb "${cloudflared_sha}"; \
    dpkg -i /tmp/cloudflared.deb; \
    cloudflared --version | grep -F "${CLOUDFLARED_VERSION}"; \
    fetch_and_verify "https://github.com/oxipng/oxipng/releases/download/v${OXIPNG_VERSION}/${oxipng_asset}" /tmp/oxipng.deb "${oxipng_sha}"; \
    dpkg -i /tmp/oxipng.deb; \
    oxipng --version | grep -F "${OXIPNG_VERSION}"; \
    fetch_and_verify "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/${duckdb_asset}" /tmp/duckdb.zip "${duckdb_sha}"; \
    unzip -q /tmp/duckdb.zip -d /tmp/duckdb; \
    install -m 0755 /tmp/duckdb/duckdb /usr/local/bin/duckdb; \
    duckdb --version | grep -F "${DUCKDB_VERSION}"; \
    fetch_and_verify "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/${hadolint_asset}" /usr/local/bin/hadolint "${hadolint_sha}"; \
    chmod +x /usr/local/bin/hadolint; \
    hadolint --version | grep -F "${HADOLINT_VERSION}"; \
    fetch_and_verify "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/${websocat_asset}" /usr/local/bin/websocat "${websocat_sha}"; \
    chmod +x /usr/local/bin/websocat; \
    websocat --version | grep -F "${WEBSOCAT_VERSION}"; \
    rm -rf /tmp/cloudflared.deb /tmp/duckdb /tmp/duckdb.zip /tmp/oxipng.deb

RUN set -eux; \
    set -a; source /tmp/runtime-versions/tool-versions.env; set +a; \
    fetch_and_verify() { \
        local url="$1" dest="$2" expected_sha="$3"; \
        curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 --retry-connrefused -o "$dest" "$url"; \
        echo "${expected_sha}  $dest" | sha256sum -c -; \
    }; \
    case "$(dpkg --print-architecture)" in \
        amd64) \
            uv_asset='uv-x86_64-unknown-linux-gnu.tar.gz'; \
            uv_sha="${UV_X86_64_SHA256}"; \
            ;; \
        arm64) \
            uv_asset='uv-aarch64-unknown-linux-gnu.tar.gz'; \
            uv_sha="${UV_AARCH64_SHA256}"; \
            ;; \
        *) \
            echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; \
            exit 1; \
            ;; \
    esac; \
    fetch_and_verify "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${uv_asset}" /tmp/uv.tar.gz "${uv_sha}"; \
    tar -xzf /tmp/uv.tar.gz -C /tmp; \
    uv_root="$(find /tmp -maxdepth 1 -type d -name 'uv-*' | head -n 1)"; \
    test -n "${uv_root}"; \
    install -m 0755 "${uv_root}/uv" /usr/local/bin/uv; \
    install -m 0755 "${uv_root}/uvx" /usr/local/bin/uvx; \
    uv --version | grep -F "uv ${UV_VERSION}"; \
    uv python install "${PYTHON_VERSION}"; \
    uv venv "${PYTHON_VENV}" --python "${PYTHON_VERSION}" --seed; \
    PYBIN="${PYTHON_VENV}/bin/python"; \
    ln -sf "${PYBIN}" /usr/local/bin/python${PYTHON_VERSION}; \
    ln -sf "${PYBIN}" /usr/local/bin/python3; \
    ln -sf "${PYBIN}" /usr/local/bin/python; \
    uv pip install --python "${PYTHON_VENV}" -r /tmp/runtime-versions/python-requirements.txt; \
    PIPBIN="$("${PYBIN}" -c 'import os, sysconfig; print(os.path.join(sysconfig.get_path("scripts"), "pip"))')"; \
    ln -sf "${PIPBIN}" /usr/local/bin/pip3; \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip; \
    uv cache clean; \
    rm -rf /tmp/uv.tar.gz "${uv_root}"

RUN set -eux; \
    export OFFICECLI_DIR="/usr/local/bin"; \
    curl -fsSL https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/install.sh | bash; \
    if [ -f /root/.local/bin/officecli ]; then \
        ln -sf /root/.local/bin/officecli /usr/local/bin/officecli; \
    fi; \
    officecli --version

# Install pinned kdocs-cli v2.5.2 (CLI only — no skill files)
RUN set -eux; \
    set -a; source /tmp/runtime-versions/tool-versions.env; set +a; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64) kdocs_arch="amd64" ;; \
        arm64) kdocs_arch="arm64" ;; \
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    kdocs_url="https://wpsai.wpscdn.cn/skillhub/pro/v${KDOCS_CLI_VERSION}/releases/kdocs-cli-${KDOCS_CLI_VERSION}-linux-${kdocs_arch}.tar.gz"; \
    echo "Downloading kdocs-cli v${KDOCS_CLI_VERSION} (${kdocs_arch})..."; \
    curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 --retry 5 --retry-delay 2 -o /tmp/kdocs-cli.tar.gz "$kdocs_url"; \
    tar -xzf /tmp/kdocs-cli.tar.gz -C /tmp; \
    install -m 0755 /tmp/kdocs-cli /usr/local/bin/kdocs-cli; \
    rm -f /tmp/kdocs-cli.tar.gz /tmp/kdocs-cli; \
    kdocs-cli version | grep -F "${KDOCS_CLI_VERSION}"

COPY verify-runtime.sh /usr/local/bin/verify-runtime
RUN chmod +x /usr/local/bin/verify-runtime \
    && install -d -m 0755 /usr/local/share/astrum-agent-runtime \
    && cp -R /tmp/runtime-versions /usr/local/share/astrum-agent-runtime/versions \
    && rm -rf /tmp/runtime-versions \
    && if command -v fc-cache >/dev/null; then fc-cache -f; fi \
    && mkdir -p \
        /workspace \
        /output \
        /cache \
        /tmp/hermes \
        /root/.cache \
        /root/.config \
        /root/.local \
    && chmod 1777 /workspace /output /cache /tmp/hermes

WORKDIR /workspace
CMD ["/bin/bash"]
