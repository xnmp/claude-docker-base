#!/bin/bash
set -e

HOST_UID=$(stat -c '%u' /home/claudeuser/app 2>/dev/null || echo "1000")
CURRENT_UID=$(id -u claudeuser)

if [ "$HOST_UID" != "$CURRENT_UID" ] && [ "$HOST_UID" != "0" ]; then
    echo "[entrypoint] Remapping claudeuser UID $CURRENT_UID -> $HOST_UID to match mounted volume"
    usermod -u "$HOST_UID" claudeuser
    chown -R "$HOST_UID" /home/claudeuser/.local
fi

# Symlink host home path so absolute paths in plugin configs resolve correctly.
# installed_plugins.json stores installPath as /home/<host_user>/... which won't
# exist inside the container where home is /home/claudeuser.
HOST_HOME=$(grep -oP '"installPath":\s*"\K/home/[^/]+' /home/claudeuser/.claude/plugins/installed_plugins.json 2>/dev/null | head -1)
if [ -n "$HOST_HOME" ] && [ "$HOST_HOME" != "/home/claudeuser" ] && [ ! -e "$HOST_HOME" ]; then
    echo "[entrypoint] Symlinking $HOST_HOME -> /home/claudeuser (plugin path fixup)"
    mkdir -p "$(dirname "$HOST_HOME")"
    ln -s /home/claudeuser "$HOST_HOME"
fi

echo "[entrypoint] Running as UID $(id -u claudeuser)"
echo "[entrypoint] Launching: claude $*"

exec gosu claudeuser /home/claudeuser/.local/bin/claude --dangerously-skip-permissions "$@"
