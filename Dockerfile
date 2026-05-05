FROM ubuntu:24.04

LABEL org.opencontainers.image.title="astrum-agent-runtime" \
      org.opencontainers.image.description="Ubuntu 24.04 AI agent runtime optimized for Hermes Agent Docker backend"

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=24
ARG OXIPNG_VERSION=10.1.1
ARG HADOLINT_VERSION=2.13.1
ARG WEBSOCAT_VERSION=1.14.1
ARG BUN_INSTALL=/opt/bun
ARG UV_INSTALL_DIR=/usr/local/bin
ARG UV_PYTHON_INSTALL_DIR=/opt/uv-python
ARG PYTHON_VENV=/opt/python

ENV TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    BUN_INSTALL=${BUN_INSTALL} \
    UV_INSTALL_DIR=${UV_INSTALL_DIR} \
    UV_PYTHON_INSTALL_DIR=${UV_PYTHON_INSTALL_DIR} \
    PYTHON_VENV=${PYTHON_VENV} \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH=${PYTHON_VENV}/bin:/usr/local/bin:${BUN_INSTALL}/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "60";' \
        'Acquire::https::Timeout "60";' \
        'APT::Get::Assume-Yes "true";' \
    > /etc/apt/apt.conf.d/99agent-runtime-retries \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gnupg \
        gpg \
        lsb-release \
        apt-transport-https \
        software-properties-common \
        tzdata \
        locales \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && add-apt-repository -y multiverse \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
        git \
        git-lfs \
        gh \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        autoconf \
        automake \
        libtool \
        make \
        gcc \
        g++ \
        clang \
        llvm \
        golang-go \
        gdb \
        lldb \
        strace \
        file \
        patch \
        diffutils \
        grep \
        gawk \
        findutils \
        coreutils \
        util-linux \
        procps \
        gettext-base \
        moreutils \
        expect \
        shellcheck \
        shfmt \
        csvkit \
        httpie \
        jq \
        yq \
        ripgrep \
        fd-find \
        miller \
        aria2 \
        tmux \
        rsync \
        p7zip-full \
        zip \
        unzip \
        xz-utils \
        zstd \
        tar \
        gzip \
        bzip2 \
        unrar \
        rclone \
        openssh-client \
        sshpass \
        netcat-openbsd \
        dnsutils \
        iputils-ping \
        iproute2 \
        nmap \
        tcpdump \
        traceroute \
        whois \
        telnet \
        socat \
        less \
        vim-tiny \
        nano \
        tree \
        htop \
        postgresql-client \
        default-mysql-client \
        redis-tools \
        sqlite3 \
        libreoffice \
        libreoffice-writer \
        libreoffice-calc \
        libreoffice-impress \
        libreoffice-java-common \
        default-jre-headless \
        pandoc \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-noto-color-emoji \
        fonts-noto-core \
        fonts-liberation \
        fonts-dejavu \
        fontconfig \
        # LaTeX / academic paper compilation
        latexmk \
        biber \
        chktex \
        lacheck \
        python3-pygments \
        lmodern \
        tex-gyre \
        texlive-latex-base \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-luatex \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-font-utils \
        texlive-pictures \
        texlive-pstricks \
        texlive-science \
        texlive-publishers \
        texlive-bibtex-extra \
        texlive-extra-utils \
        texlive-lang-cjk \
        texlive-lang-chinese \
        texlive-lang-japanese \
        poppler-utils \
        qpdf \
        ghostscript \
        ffmpeg \
        imagemagick \
        libimage-exiftool-perl \
        libcairo2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libnss3 \
        libnspr4 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        libgbm1 \
        libgtk-3-0 \
        libdrm2 \
        libasound2t64 \
        libdbus-1-3 \
        libatspi2.0-0 \
        libxkbcommon0 \
    && git lfs install --system \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bun.sh/install | bash \
    && bun --version \
    && bun add -g \
        turbo \
        prettier \
        eslint \
        tsx \
        playwright \
        vercel \
        wrangler \
        @mermaid-js/mermaid-cli \
        @google/gemini-cli \
        typescript \
        pnpm \
        yarn \
    && rm -rf /root/.bun/install/cache \
    && npm install -g \
        neonctl \
        @googleworkspace/cli \
        @larksuite/cli \
    && npm cache clean --force

RUN curl -fsSL -o /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && curl -fsSL -o /tmp/cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(dpkg --print-architecture).deb" \
    && dpkg -i /tmp/cloudflared.deb \
    && curl -A "Mozilla/5.0" -fsSL -o /tmp/oxipng.deb "https://github.com/oxipng/oxipng/releases/download/v${OXIPNG_VERSION}/oxipng_${OXIPNG_VERSION}-1_$(dpkg --print-architecture).deb" \
    && dpkg -i /tmp/oxipng.deb \
    && rm -f /tmp/cloudflared.deb /tmp/oxipng.deb

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
        amd64) \
            aws_arch="x86_64"; \
            hadolint_arch="x86_64"; \
            websocat_asset="websocat.x86_64-unknown-linux-musl"; \
            ;; \
        arm64) \
            aws_arch="aarch64"; \
            hadolint_arch="arm64"; \
            websocat_asset="websocat.aarch64-unknown-linux-musl"; \
            ;; \
        *) \
            echo "Unsupported architecture: ${arch}" >&2; \
            exit 1; \
            ;; \
    esac; \
    curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip"; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli; \
    curl -fsSL -o /tmp/install-duckdb.sh https://install.duckdb.org; \
    sh /tmp/install-duckdb.sh; \
    ln -sf /root/.duckdb/cli/latest/duckdb /usr/local/bin/duckdb; \
    curl -fsSL -o /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${hadolint_arch}"; \
    chmod +x /usr/local/bin/hadolint; \
    curl -fsSL -o /usr/local/bin/websocat "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/${websocat_asset}"; \
    chmod +x /usr/local/bin/websocat; \
    rm -rf /tmp/aws /tmp/awscliv2.zip /tmp/install-duckdb.sh

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && uv --version \
    && uv python install 3.13 \
    && uv venv "${PYTHON_VENV}" --python 3.13 --seed \
    && PYBIN="${PYTHON_VENV}/bin/python" \
    && ln -sf "${PYBIN}" /usr/local/bin/python3.13 \
    && ln -sf "${PYBIN}" /usr/local/bin/python3 \
    && ln -sf "${PYBIN}" /usr/local/bin/python \
    && uv pip install --python "${PYTHON_VENV}" \
        pip \
        pipx \
        virtualenv \
        setuptools \
        wheel \
        requests \
        httpx \
        pydantic \
        python-dotenv \
        toml \
        duckdb \
        beautifulsoup4 \
        markdown \
        python-multipart \
        pypdf \
        pymupdf \
        pdfplumber \
        python-docx \
        openpyxl \
        python-pptx \
        pandas \
        pyarrow \
        tabulate \
        numpy \
        ruff \
    && PIPBIN="$("${PYBIN}" -c 'import os, sysconfig; print(os.path.join(sysconfig.get_path("scripts"), "pip"))')" \
    && ln -sf "${PIPBIN}" /usr/local/bin/pip3 \
    && ln -sf /usr/local/bin/pip3 /usr/local/bin/pip \
    && uv cache clean

RUN set -eux; \
    export OFFICECLI_DIR="/usr/local/bin"; \
    curl -fsSL https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/install.sh | bash; \
    # Symlink into /usr/local/bin so it's always in PATH regardless of HOME
    if [ -f /root/.local/bin/officecli ]; then \
        ln -sf /root/.local/bin/officecli /usr/local/bin/officecli; \
    fi; \
    officecli --version

COPY verify-runtime.sh /usr/local/bin/verify-runtime
RUN chmod +x /usr/local/bin/verify-runtime \
    && fc-cache -f \
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
