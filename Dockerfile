FROM node:22-slim

# Layer 1: System packages (stable, rarely changes)
RUN apt-get update && apt-get install -y \
    git curl gosu unzip jq \
    # Tauri build dependencies (webkit2gtk + native libs)
    build-essential pkg-config \
    libwebkit2gtk-4.1-dev libssl-dev libsoup-3.0-dev \
    libgtk-3-dev librsvg2-dev libayatana-appindicator3-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: User creation and PATH setup
RUN userdel -r node 2>/dev/null || true
RUN useradd -m -s /bin/bash -u 1000 claudeuser
ENV PATH="/home/claudeuser/.local/bin:/home/claudeuser/.bun/bin:/home/claudeuser/.cargo/bin:$PATH"

# Layer 3: Rust + sccache (slow to install, rarely changes)
USER claudeuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    cargo install sccache
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=/home/claudeuser/.cache/sccache
USER root

# Layer 4: bun, uv, beads (fast installs, moderate change frequency)
USER claudeuser
RUN curl -fsSL https://bun.sh/install | bash && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
USER root

# Layer 5: agent-browser + Playwright Chromium (stable, rarely changes)
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright
RUN npm install -g agent-browser
RUN npx playwright install --with-deps chromium && chmod -R o+rx /opt/ms-playwright

# Layer 6: Claude Code (slowest single install, changes most often)
USER claudeuser
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

# Layer 7: Git config and entrypoint
USER claudeuser
RUN git config --global user.email "claudeuser@example.com" && \
    git config --global user.name "Claude Sandbox"
USER root

WORKDIR /home/claudeuser
ENV CLAUDE_CODE_DISABLE_AUTO_UPDATE=1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
