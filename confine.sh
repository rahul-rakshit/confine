#! /bin/bash

confine() {
  local dir="."
  local name
  local net_args=()
  local got_dir=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --network)
        if [[ "${2:-}" == "host" ]]; then
          net_args=(--network host)
        fi
        shift 2
        ;;
      *)
        if [[ $got_dir -eq 0 ]]; then
          dir="$1"
          got_dir=1
        else
          name="$1"
        fi
        shift
        ;;
    esac
  done

  if ! docker image inspect ai_sandbox &>/dev/null; then
    echo "confine: image 'ai_sandbox' does not exist - build it first with ./build.sh" >&2
    return 1
  fi

  local cid
  cid="$(docker run -d "${net_args[@]}" ${name:+--name "$name"} \
    -v ~/.ai_agent_env:/home/agent/.ai_agent_env \
    -v ~/.claude:/home/agent/.claude \
    -v ~/.claude.json:/home/agent/.claude.json \
    -v ~/.pi/agent:/home/agent/.pi/agent \
    -v ~/.config/opencode:/home/agent/.config/opencode \
    -v ~/.local/share/opencode:/home/agent/.local/share/opencode \
    -v ~/.local/state/opencode:/home/agent/.local/state/opencode \
    -v ~/.config/nvim:/home/agent/.config/nvim \
    -v ~/.tmux.conf:/home/agent/.tmux.conf \
    -v ~/.tmux:/home/agent/.tmux \
    -v "${dir:A}":/workspace \
    --entrypoint sleep \
    ai_sandbox infinity)" || return 1

  docker exec -it "$cid" /bin/bash
}
