#!/bin/sh
set -e

GIT_REPO="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/${GIT_USERNAME}/9router-data.git"

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
        sleep 7200
        cd /app/data

        if [ -n "$(git status --porcelain)" ]; then
            echo "==> Syncing config changes to GitHub..."
            git add -A || { echo "ERROR: git add failed"; continue; }
            git commit -m "auto-sync $(date -u +"%Y-%m-%d %H:%M:%S UTC")" || { echo "ERROR: git commit failed"; continue; }

            git pull "$GIT_REPO" main --rebase --autostash 2>/dev/null || echo "WARN: git pull failed, trying push anyway"

            for i in 1 2 3; do
                if git push "$GIT_REPO" main 2>/dev/null; then
                    echo "==> Push succeeded (attempt $i)"
                    break
                else
                    echo "WARN: git push attempt $i failed, retrying in 10s..."
                    sleep 10
                fi
            done
        fi
    done
) &

echo "==> Starting 9router..."
exec node /app/custom-server.js
