FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        file \
        git \
        procps \
        tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude \
    && mkdir -p /home/linuxbrew \
    && chown claude /home/linuxbrew

USER claude
ENV HOME=/home/claude

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install node

RUN npm install -g @anthropic-ai/claude-code

COPY --chown=claude:claude .tmux.conf /home/claude/.tmux.conf
COPY --chown=claude:claude .tmux/ /home/claude/.tmux/

WORKDIR /workspace

ENTRYPOINT ["claude"]
