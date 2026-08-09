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
RUN brew install neovim fd rg tmux yt-dlp ffmpeg socat bubblewrap gh actionlint jq yq tailscale

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN echo "export LANG=en_US.UTF-8" >> /home/agent/.bashrc
RUN echo "export EDITOR=nvim" >> /home/agent/.bashrc
RUN echo "alias vim='nvim'" >> /home/agent/.bashrc
RUN echo '[ -f /home/agent/.ai_agent_env/agent.env ] && set -a && . /home/agent/.ai_agent_env/agent.env && set +a' >> /home/agent/.bashrc
RUN cat >> /home/agent/.bashrc <<'EOF'

start-tailscale() {
  local sock="/tmp/tailscaled.sock"
  local log="/tmp/tailscaled.log"

  local out
  out="$(tailscale --socket="$sock" status 2>&1)"
  local rc=$?
  if [ $rc -eq 0 ]; then
    echo "tailscale is already up:"
    echo "$out"
    export-tailscale-proxy
    return 0
  fi

  if [ -S "$sock" ] && echo "$out" | grep -q "Logged out"; then
    echo "tailscaled is running but not logged in."
  else
    rm -f "$sock"
    echo "Starting tailscaled (userspace-networking) on ${sock}..."
    setsid nohup tailscaled --tun=userspace-networking --socket="$sock" \
      --state="/home/agent/.local/share/tailscale/tailscaled.state" \
      --socks5-server=127.0.0.1:1080 \
      --outbound-http-proxy-listen=127.0.0.1:8888 \
      > "$log" 2>&1 < /dev/null &
    local i
    for i in $(seq 1 40); do
      [ -S "$sock" ] && break
      sleep 0.5
    done
    [ -S "$sock" ] || { echo "tailscaled failed to start (see ${log})"; return 1; }
    sleep 1
  fi

  echo "Open this URL in your browser to authenticate:"
  tailscale --socket="$sock" up
  echo
  echo "Authenticated. Current status:"
  tailscale --socket="$sock" status

  # Set proxy env vars so AI agents route through tailscaled. Its
  # HTTP proxy (--outbound-http-proxy-listen) forwards tailnet names AND acts as
  # a normal pass-through proxy for non-tailnet traffic, so a single HTTP proxy
  # covers both the self-hosted model and any external APIs.
  local sock="/tmp/tailscaled.sock"
  if ! tailscale --socket="$sock" status >/dev/null 2>&1; then
    echo "export-tailscale-proxy: tailscale is not up; not setting proxy" >&2
    return 1
  fi
  export http_proxy=http://127.0.0.1:8888
  export https_proxy=http://127.0.0.1:8888
  export HTTP_PROXY=http://127.0.0.1:8888
  export HTTPS_PROXY=http://127.0.0.1:8888
  export ALL_PROXY=http://127.0.0.1:8888
  export no_proxy="localhost,127.0.0.1,::1,100.100.100.100"
  export NO_PROXY="$no_proxy"
  echo "Proxy set: ALL_PROXY=$ALL_PROXY (non-tailnet passes through)"
}
EOF

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
