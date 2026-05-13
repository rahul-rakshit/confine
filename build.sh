#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp ~/.tmux.conf "$SCRIPT_DIR/.tmux.conf"
rsync -a --exclude='.git' ~/.tmux/ "$SCRIPT_DIR/.tmux/"

docker build --no-cache -t ai_sandbox "$SCRIPT_DIR"
