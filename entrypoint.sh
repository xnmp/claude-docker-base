#!/bin/bash
set -e

HOST_UID=$(stat -c '%u' . 2>/dev/null || echo "1000")
CURRENT_UID=$(id -u claudeuser)

if [ "$HOST_UID" != "$CURRENT_UID" ] && [ "$HOST_UID" != "0" ]; then
    # If another user already owns the target UID, remove it first
    EXISTING_USER=$(getent passwd "$HOST_UID" | cut -d: -f1)
    if [ -n "$EXISTING_USER" ] && [ "$EXISTING_USER" != "claudeuser" ]; then
        # echo "[entrypoint] Removing $EXISTING_USER (owns UID $HOST_UID)"
        userdel "$EXISTING_USER"
    fi
    # echo "[entrypoint] Remapping claudeuser UID $CURRENT_UID -> $HOST_UID to match mounted volume"
    usermod -u "$HOST_UID" claudeuser
    chown -R "$HOST_UID" /home/claudeuser/.local
fi

# Ensure cargo/sccache cache volumes (if mounted) are owned by claudeuser
CLAUDE_UID="$(id -u claudeuser)"
chown -R "$CLAUDE_UID" /home/claudeuser/.cargo
mkdir -p /home/claudeuser/.cache/sccache
chown -R "$CLAUDE_UID" /home/claudeuser/.cache/sccache

# Copy read-only host config to writable location so Claude Code can
# write runtime data (sessions, caches) without modifying the host.
if [ -d /home/claudeuser/.claude-host ]; then
    # echo "[entrypoint] Copying host ~/.claude config (read-only mount) to writable location"
    cp -a /home/claudeuser/.claude-host /home/claudeuser/.claude
    chown -R "$HOST_UID" /home/claudeuser/.claude
fi

# Symlink host home path so absolute paths in plugin configs resolve correctly.
# installed_plugins.json stores installPath as /home/<host_user>/... which won't
# exist inside the container where home is /home/claudeuser.
HOST_HOME=$(grep -oP '"installPath":\s*"\K/home/[^/]+' /home/claudeuser/.claude/plugins/installed_plugins.json 2>/dev/null | head -1)
if [ -n "$HOST_HOME" ] && [ "$HOST_HOME" != "/home/claudeuser" ] && [ ! -e "$HOST_HOME" ]; then
    # echo "[entrypoint] Symlinking $HOST_HOME -> /home/claudeuser (plugin path fixup)"
    mkdir -p "$(dirname "$HOST_HOME")"
    ln -s /home/claudeuser "$HOST_HOME"
fi

# echo "[entrypoint] Running as UID $(id -u claudeuser)"
# echo "[entrypoint] Launching: claude $*"

exec gosu claudeuser /home/claudeuser/.local/bin/claude --dangerously-skip-permissions "$@"
