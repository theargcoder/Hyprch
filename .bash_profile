#
# ~/.bash_profile
#

#if [[ -z "$DISPLAY" ]]; then
#  exec startx > /dev/null 2>&1
#fi

if [[ -z "$DISPLAY" && -z "$(pgrep -x Hyprland)" ]]; then
  exec Hyprland > /dev/null 2>&1
fi
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# --- Terminal type fix for kitty ---
if [[ "$TERM" == "xterm-kitty" ]]; then
    export TERM=xterm
fi

# --- PATH setup ---
unset rc
export PATH=$HOME/.local/bin:$PATH

# --- Reuse a single ssh-agent for all tmux sessions ---
SSH_ENV="$HOME/.ssh/environment"

start_agent() {
    echo "Starting new ssh-agent..."
    (umask 066; ssh-agent > "$SSH_ENV")
    . "$SSH_ENV" > /dev/null 2>&1
    ssh-add ~/.ssh/github_argcoder 2>/dev/null
}

# Load existing agent info if available
if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" > /dev/null 2>&1
    # Check if the agent is still alive, otherwise start a new one
    if ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        start_agent
    fi
else
    start_agent
fi
