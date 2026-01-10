# work-lab bash config

# Add work-lab bin and Go bin to PATH
export PATH="$HOME/bin:$HOME/go/bin:$PATH"

# Custom prompt: [work-lab] cyan, path sky blue, $ dim
# Sky blue path distinguishes from white user text
PS1='\[\e[38;2;80;200;220m\][work-lab]\[\e[0m\] \[\e[38;2;100;160;220m\]\w\[\e[0m\] \[\e[38;2;140;150;160m\]$\[\e[0m\] '

# Helpful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias wl='work-lab'

# One-time welcome guide in first tmux pane
if [[ -n "$TMUX" && "$TMUX_PANE" == "%0" ]]; then
  _wl_session=$(tmux display-message -p '#S' 2>/dev/null)
  _wl_guide="/tmp/.work-lab-guide-${_wl_session}"
  if [[ ! -f "$_wl_guide" ]]; then
    touch "$_wl_guide"
    printf '\n'
    printf '  \e[38;2;80;200;220mwork-lab quick reference\e[0m\n'
    printf '  \e[38;2;140;150;160m────────────────────────\e[0m\n'
    printf '  \e[38;2;200;200;200mtmux:\e[0m Ctrl-b c (window) │ Ctrl-b %% (vsplit) │ Ctrl-b " (hsplit)\n'
    printf '        Ctrl-b n/p (next/prev) │ Ctrl-b d (detach)\n'
    printf '\n'
    printf '  \e[38;2;200;200;200mcli:\e[0m  wl --help\n'
    if command -v code &>/dev/null; then
      printf '  \e[38;2;200;200;200mvscode:\e[0m code <file>  \e[38;2;140;150;160m# opens in host VS Code\e[0m\n'
    fi
    printf '\n'
    printf '  \e[38;2;200;200;200mai:\e[0m   gastown  \e[38;2;140;150;160m# start AI coding agent\e[0m\n'
    printf '        claude   \e[38;2;140;150;160m# start Claude Code\e[0m\n'
    printf '\n'
  fi
  unset _wl_session _wl_guide
fi

# Source user overrides if present
[[ -f ~/.config/work-lab/bashrc.local ]] && source ~/.config/work-lab/bashrc.local
