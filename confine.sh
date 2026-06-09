#! /bin/bash

confine() {
  local dir="${1:-.}"
  local name="$2"

  if ! docker image inspect ai_sandbox &>/dev/null; then
    echo "confine: image 'ai_sandbox' does not exist — build it first with ./build.sh" >&2
    return 1
  fi

  docker run -d ${name:+--name "$name"} \
    -v ~/.claude:/home/agent/.claude \
    -v ~/.claude.json:/home/agent/.claude.json \
    -v ~/.pi:/home/agent/.pi \
    -v "${dir:A}":/workspace \
    --entrypoint sleep \
    ai_sandbox infinity
}
