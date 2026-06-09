FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        file \
        git \
        procps \
        tmux \
        ripgrep \
        fd-find \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN userdel -r ubuntu 2>/dev/null; groupdel ubuntu 2>/dev/null; \
    groupadd -g ${HOST_GID} agent; \
    useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash agent

RUN mkdir -p /home/linuxbrew && chown agent /home/linuxbrew

USER agent

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install node

RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

RUN echo 'export LANG=en_US.UTF-8' >> /home/agent/.bashrc

COPY --chown=agent:agent .tmux.conf /home/agent/.tmux.conf
COPY --chown=agent:agent .tmux/ /home/agent/.tmux/

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
