FROM debian:bookworm-slim

# Install dependencies (git required by Claude, curl for installer, gosu for UID mapping)
RUN apt-get update && apt-get install -y git curl gosu && rm -rf /var/lib/apt/lists/*

# Create a non-root user with default UID (will be remapped at runtime)
RUN useradd -m -s /bin/bash claudeuser

# Install Claude Code as claudeuser via native installer
USER claudeuser
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

WORKDIR /home/claudeuser/app

ENV PATH="/home/claudeuser/.local/bin:$PATH"
ENV CLAUDE_CODE_DISABLE_AUTO_UPDATE=1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
