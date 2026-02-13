FROM debian:bookworm-slim

# Install dependencies (git required by Claude, curl for installer)
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash claudeuser
USER claudeuser

# Install Claude Code via native installer
RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /home/claudeuser/app

ENV PATH="/home/claudeuser/.local/bin:$PATH"
ENV CLAUDE_CODE_DISABLE_AUTO_UPDATE=1

ENTRYPOINT ["/home/claudeuser/.local/bin/claude", "--dangerously-skip-permissions"]
