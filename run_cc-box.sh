DIR_NAME="$(basename "$(pwd)")"

exec docker run -it --rm \
  -e IS_SANDBOX=1 \
  -v "$(pwd):/home/claudeuser/$DIR_NAME" \
  -v "$HOME/.claude:/home/claudeuser/.claude" \
  -v "$HOME/.claude.json:/home/claudeuser/.claude.json" \
  -v cc-cargo-cache:/home/claudeuser/.cargo/registry \
  -v cc-sccache:/home/claudeuser/.cache/sccache \
  -w "/home/claudeuser/$DIR_NAME" \
  my-claude-code