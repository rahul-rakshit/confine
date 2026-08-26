#! /bin/bash

confine() {
  local dir="${1:-.}"
  local name="$2"

  if ! docker image inspect ai_sandbox &>/dev/null; then
    echo "confine: image 'ai_sandbox' does not exist - build it first with ./build.sh" >&2
    return 1
  fi

  local cid
  cid="$(docker run -d ${name:+--name "$name"} \
    --cap-drop=ALL \
    --security-opt no-new-privileges \
    --pids-limit 1024 \
    --memory 8g \
    --memory-swap 8g \
    --cpus 4 \
    -v ~/.ai_agent_env:/home/agent/.ai_agent_env:ro \
    -v ~/.claude:/home/agent/.claude:ro \
    -v ~/.claude.json:/home/agent/.claude.json:ro \
    -v ~/.pi/agent:/home/agent/.pi/agent \
    -v ~/.config/opencode:/home/agent/.config/opencode \
    -v ~/.local/share/opencode:/home/agent/.local/share/opencode \
    -v ~/.local/state/opencode:/home/agent/.local/state/opencode \
    -v ~/.copilot:/home/agent/.copilot \
    -v ~/.config/nvim:/home/agent/.config/nvim:ro \
    -v ~/.tmux.conf:/home/agent/.tmux.conf:ro \
    -v ~/.tmux:/home/agent/.tmux:ro \
    -v "${dir:A}":/workspace \
    --entrypoint sleep \
    ai_sandbox infinity)" || return 1

  docker exec -it "$cid" /bin/bash
}
