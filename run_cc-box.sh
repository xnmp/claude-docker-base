alias cc-box='docker run -it --rm \
  -e IS_SANDBOX=1 \
  -v "$(pwd):/home/claudeuser/app" \
  -v "$HOME/.claude:/home/claudeuser/.claude-host:ro" \
  -v "$HOME/.claude.json:/home/claudeuser/.claude.json:ro" \
  -w /home/claudeuser/app \
  my-claude-code'
