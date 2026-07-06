#!/bin/bash
set -e

GIT_REPO="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/${GIT_USERNAME}/9router-data.git"

if [ ! -f /app/data/.git/config ]; then
    echo "Cloning config repo..."
    rm -rf /app/data/*
    git clone "$GIT_REPO" /app/data
fi

(
    while true; do
        sleep 300
        cd /app/data
        if [ -n "$(git status --porcelain)" ]; then
            git add -A
            git commit -m "auto-sync $(date -u +"%Y-%m-%d %H:%M:%S UTC")" || true
            git push "$GIT_REPO" main || true
        fi
    done
) &

echo "Starting 9router..."
DATA_DIR=/app/data node /app/server.js
