alias cc-box='docker run -it --rm \
  -e IS_SANDBOX=1 \
  -v "$(pwd):/home/claudeuser/app" \
  -v "$HOME/.claude:/home/claudeuser/.claude-host:ro" \
  -v "$HOME/.claude.json:/home/claudeuser/.claude.json:ro" \
  -v cc-cargo-cache:/home/claudeuser/.cargo/registry \
  -v cc-sccache:/home/claudeuser/.cache/sccache \
  -w /home/claudeuser/app \
  my-claude-code'
