# Confine

This is my own docker-based implementation of an AI agent fence, as I don't trust AI agents' rule-based sandboxing.

## Usage

- Make sure docker is running
- Add the `confine()` function to your `~/.zshrc` and start a new shell
- Build the AI sandbox image: `./build.sh`. Note that it copies your tmux config into the container.
- Run `confine [path-to-dir] [container-name]` to start a confined container in which you can run claude. The `~/.claude` folder and `~/.claude.json` file will already have been copied into the container, as well as the desired working directory.
