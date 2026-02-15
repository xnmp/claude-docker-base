DIR_NAME="$(basename "$(pwd)")"

WORKTREE_MOUNTS=()
if [ -f .git ]; then
  MAIN_GIT_DIR=$(sed 's/gitdir: //' .git | sed 's|/worktrees/.*||')
  WORKTREE_MOUNTS=(-v "$MAIN_GIT_DIR:$MAIN_GIT_DIR:ro")
fi

exec docker run -it --rm \
  -e IS_SANDBOX=1 \
  -v "$(pwd):/home/claudeuser/$DIR_NAME" \
  "${WORKTREE_MOUNTS[@]}" \
  -v "$HOME/.claude:/home/claudeuser/.claude" \
  -v "$HOME/.claude.json:/home/claudeuser/.claude.json" \
  -v cc-cargo-cache:/home/claudeuser/.cargo/registry \
  -v cc-sccache:/home/claudeuser/.cache/sccache \
  -w "/home/claudeuser/$DIR_NAME" \
  my-claude-code
