#!/bin/bash
set -e

HOST_UID=$(stat -c '%u' /home/claudeuser/app 2>/dev/null || echo "1000")
CURRENT_UID=$(id -u claudeuser)

if [ "$HOST_UID" != "$CURRENT_UID" ] && [ "$HOST_UID" != "0" ]; then
    echo "[entrypoint] Remapping claudeuser UID $CURRENT_UID -> $HOST_UID to match mounted volume"
    usermod -u "$HOST_UID" claudeuser
    chown -R "$HOST_UID" /home/claudeuser/.local
fi

echo "[entrypoint] Running as UID $(id -u claudeuser)"
echo "[entrypoint] Launching: claude $*"

exec gosu claudeuser /home/claudeuser/.local/bin/claude --dangerously-skip-permissions "$@"
