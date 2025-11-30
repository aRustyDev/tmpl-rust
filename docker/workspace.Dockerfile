# --- Requirements ---
# 1. [ ] Install Rust Toolchain
# 2. [ ] Install Zed Server
# 3. [ ] Install MoSH server
# 4. [ ] Enable SSH Socket Forwarding; Container needs to be able to access local hosts $SSH_AUTH_SOCK
# 5. [ ] Install MCP Configs
# 6. [ ] Install Docker CLI
# 7. [ ] Install Local MCP Servers
#   - smart-tree
#   - mcp-language-server

# /Users/arustydev/repos/templates/rust/Dockerfile.dev
FROM rust:1.83-slim

ARG RUST_TOOLCHAIN="stable"

# Install development tools
# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    curl \
    yq \
    && rm -rf /var/lib/apt/lists/*

# Install PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install Rust tools
RUN rustup component add \
    clippy \
    rustfmt \
    rust-analyzer

COPY .config/manifest.yaml /etc/cargo/manifest.yaml

# Install cargo extensions
RUN yq '.cargo | keys[]' /etc/cargo/manifest.yaml | xargs -I {} cargo install {}

# Install node extensions
RUN yq '.node | keys[]' /etc/cargo/manifest.yaml | xargs -I {} pnpm install {}

WORKDIR /workspace
