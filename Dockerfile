FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        file \
        git \
        procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurable so that you can make your host user match the container user to avoid permission issues
ARG HOST_UID=1000
ARG HOST_GID=1000

RUN userdel -r ubuntu 2>/dev/null; groupdel ubuntu 2>/dev/null; \
    groupadd -g ${HOST_GID} agent; \
    useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash agent

# Creating and chowning directories in advance so that permissions are right when mounting them in later
RUN mkdir -p /home/linuxbrew && chown agent:agent /home/linuxbrew
RUN mkdir -p /home/agent/.pi && chown agent:agent /home/agent/.pi
RUN mkdir -p /home/agent/.claude && chown agent:agent /home/agent/.claude
RUN mkdir -p /home/agent/.local && chown agent:agent /home/agent/.local
RUN mkdir -p /home/agent/.tmux && chown agent:agent /home/agent/.tmux
RUN mkdir -p /home/agent/.config && chown agent:agent /home/agent/.config
RUN mkdir -p /home/agent/.ai_agent_env && chown agent:agent /home/agent/.ai_agent_env

USER agent

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install node

RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent
RUN npm install -g opencode-ai
RUN brew install neovim fd rg tmux yt-dlp ffmpeg socat bubblewrap gh actionlint jq yq

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN echo "export LANG=en_US.UTF-8" >> /home/agent/.bashrc
RUN echo "export EDITOR=nvim" >> /home/agent/.bashrc
RUN echo "alias vim='nvim'" >> /home/agent/.bashrc
RUN echo '[ -f /home/agent/.ai_agent_env/agent.env ] && set -a && . /home/agent/.ai_agent_env/agent.env && set +a' >> /home/agent/.bashrc

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
