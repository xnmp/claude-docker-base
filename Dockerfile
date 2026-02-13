FROM node:20-slim

# Install git (required by Claude)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create a non-root user
RUN useradd -m -s /bin/bash claudeuser
USER claudeuser
WORKDIR /home/claudeuser/app

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
