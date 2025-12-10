# .bashrc

# VIM motions for kitty term
set -o vi
# ------------------------------------------------------------
# Source global definitions
# ------------------------------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ------------------------------------------------------------
# User specific environment
# ------------------------------------------------------------
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# ------------------------------------------------------------
# User specific aliases and functions
# ------------------------------------------------------------
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

# ------------------------------------------------------------
# Terminal compatibility (kitty, etc.)
# ------------------------------------------------------------
if [[ "$TERM" == "xterm-kitty" ]]; then
    export TERM=xterm
fi

# ------------------------------------------------------------
# Color support (ls, grep, etc.)
# ------------------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
fi

# ------------------------------------------------------------
# Fancy colorful prompt
# ------------------------------------------------------------
# Example: lucca@ARCHserver:~/Generis $
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# ------------------------------------------------------------
# Final PATH exports
# ------------------------------------------------------------
unset rc
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
