# Confine

This is my own docker-based implementation of an AI agent fence, as I don't trust AI agents' rule-based sandboxing.

## Usage

- Make sure docker is running
- Add the `confine()` function to your `~/.zshrc` and start a new shell
- Build the AI sandbox image: `./build.sh`
- Run `confine [path-to-dir] [container-name]` to start a confined container. Then `docker exec -it <container-name> /bin/bash` and run `claude`, `opencode` or `pi`.

Your configs are automatically mounted into the container:

| Host                 | Container                      |
| -------------------- | ------------------------------ |
| `~/.claude`          | `/home/agent/.claude`          |
| `~/.claude.json`     | `/home/agent/.claude.json`     |
| `~/.pi`              | `/home/agent/.pi`              |
| `~/.config/opencode` | `/home/agent/.config/opencode` |
| `~/.tmux.conf`       | `/home/agent/.tmux.conf`       |
| `~/.tmux`            | `/home/agent/.tmux`            |
| `~/.config/nvim`     | `/home/agent/.config/nvim`     |
| `<working-dir>`      | `/workspace`                   |

> **Permissions:** The container user `agent` is created with UID 1000,
> matching your host user. Mounted files from `~/.pi`, `~/.claude`, etc.
> retain correct ownership and pi can write to `~/.pi/agent/`.
> If your host user has a different UID, change the `1000` in the
> `useradd` line of the Dockerfile.
