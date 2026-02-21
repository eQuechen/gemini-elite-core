FROM node:20-bookworm

# ============================================================
# Gemini Elite Core — Docker Image
#
# Base: Debian Bookworm (glibc)
#
# Rationale:
# - Alpine (musl) is NOT compatible with Playwright on ARM64
# - browser-use requires Playwright
# - Debian (glibc) ensures compatibility across architectures
#
# Design principles:
# - No setup execution during build (interactive)
# - Application code lives inside the image
# - User project is mounted at runtime
# - Persistent config stored in Docker volume
# - bun is preferred package manager (installed at build time)
# ============================================================


# ------------------------------------------------------------
# System dependencies
#
# We use --no-install-recommends to:
# - Reduce image size
# - Avoid unnecessary packages
# - Keep attack surface smaller
#
# If something breaks unexpectedly, a missing recommended
# dependency may be the cause.
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    python3 \
    make \
    g++ \
    curl \
    ca-certificates \
    libnspr4 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libdbus-1-3 \
    libcups2 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# bun install
# ------------------------------------------------------------
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /root/.bun/bin/bun /usr/local/bin/bun
ENV PATH="/root/.bun/bin:${PATH}"

# ------------------------------------------------------------
# Application directory inside container
#
# /gemini is the canonical internal path used by:
# - setup.sh
# - gemini-safe wrapper
#
# If this changes, gemini-safe MUST be updated accordingly.
# ------------------------------------------------------------
ARG APP_DIR=/gemini
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}

# Copy local project into the image.
# The build context must be the project root.
COPY . ${APP_DIR}

# Ensure setup script is executable.
RUN chmod +x setup.sh


# ------------------------------------------------------------
# Workspace directory
#
# At runtime, gemini-safe mounts:
#   $PWD -> /workspace
#
# This keeps:
# - Core application isolated in /gemini
# - User project isolated in /workspace
#
# DO NOT merge these paths unless architecture changes.
# ------------------------------------------------------------
WORKDIR /workspace