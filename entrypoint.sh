#!/bin/sh
set -e

GIT_REPO="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/${GIT_USERNAME}/9router-data.git"

# 配置 git identity（缺少这个会导致 git commit 失败！）
git config --global user.name "9router-sync"
git config --global user.email "9router@sync.local"

if [ ! -f /app/data/.git/config ]; then
    echo "==> Cloning 9router-data config repo..."
    rm -rf /app/data/* /app/data/.[!.]* 2>/dev/null || true
    git clone "$GIT_REPO" /app/data
fi

# 后台自动同步：每 60 秒检查一次，确保数据及时推送
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
