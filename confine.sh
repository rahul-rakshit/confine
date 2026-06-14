#! /bin/bash

confine() {
  local dir="${1:-.}"
  local name="$2"

  if ! docker image inspect ai_sandbox &>/dev/null; then
    echo "confine: image 'ai_sandbox' does not exist - build it first with ./build.sh" >&2
    return 1
  fi

  docker run -d ${name:+--name "$name"} \
    -v ~/.claude:/home/claude/.claude \
    -v ~/.claude.json:/home/claude/.claude.json \
    -v ~/.pi/agent:/home/agent/.pi/agent \
    -v ~/.config/opencode:/home/agent/.config/opencode \
    -v ~/.local/share/opencode:/home/agent/.local/share/opencode \
    -v ~/.local/state/opencode:/home/agent/.local/state/opencode \
    -v ~/.config/nvim:/home/agent/.config/nvim \
    -v ~/.tmux.conf:/home/agent/.tmux.conf \
    -v ~/.tmux:/home/agent/.tmux \
    -v "${dir:A}":/workspace \
    --entrypoint sleep \
    ai_sandbox infinity
}
