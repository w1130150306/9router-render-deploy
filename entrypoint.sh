#!/bin/sh
set -e

GIT_REPO="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/${GIT_USERNAME}/9router-data.git"

# 用环境变量设置 git identity，不依赖 ~/.gitconfig
export GIT_AUTHOR_NAME="9router-sync"
export GIT_AUTHOR_EMAIL="9router@sync.local"
export GIT_COMMITTER_NAME="9router-sync"
export GIT_COMMITTER_EMAIL="9router@sync.local"

if [ ! -f /app/data/.git/config ]; then
    echo "==> Cloning 9router-data config repo..."
    rm -rf /app/data/* /app/data/.[!.]* 2>/dev/null || true
    git clone "$GIT_REPO" /app/data
fi

(
    while true; do
        sleep 60
        cd /app/data
        if [ -n "$(git status --porcelain)" ]; then
            echo "==> Syncing config changes to GitHub..."
            git add -A
            git commit -m "auto-sync $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
            git push "$GIT_REPO" main
        fi
    done
) &

echo "==> Starting 9router..."
exec node /app/custom-server.js
