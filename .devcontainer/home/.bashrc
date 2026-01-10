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
# Theme colors: cyan #50c8dc, sky blue #64a0dc, gold #ffd23c, dim #8c969f
if [[ -n "$TMUX" && "$TMUX_PANE" == "%0" ]]; then
  _wl_session=$(tmux display-message -p '#S' 2>/dev/null)
  _wl_guide="/tmp/.work-lab-guide-${_wl_session}"
  if [[ ! -f "$_wl_guide" ]]; then
    touch "$_wl_guide"
    printf '\n'
    printf '  \e[38;2;80;200;220;1mwork-lab\e[0m \e[38;2;140;150;160mquick reference\e[0m\n'
    printf '  \e[38;2;60;70;80m────────────────────────\e[0m\n'
    printf '\n'
    printf '  \e[38;2;100;160;220mtmux\e[0m    \e[38;2;140;150;160mCtrl-b c\e[0m new window  \e[38;2;60;70;80m│\e[0m  \e[38;2;140;150;160mCtrl-b %%\e[0m vsplit  \e[38;2;60;70;80m│\e[0m  \e[38;2;140;150;160mCtrl-b "\e[0m hsplit\n'
    printf '          \e[38;2;140;150;160mCtrl-b n/p\e[0m next/prev  \e[38;2;60;70;80m│\e[0m  \e[38;2;140;150;160mCtrl-b d\e[0m detach\n'
    printf '          \e[38;2;140;150;160mCtrl-b D\e[0m devcontainer shell  \e[38;2;60;70;80m│\e[0m  \e[38;2;140;150;160mCtrl-b S\e[0m devcontainer ssh\n'
    printf '\n'
    printf '  \e[38;2;100;160;220mcli\e[0m     \e[38;2;255;210;60mwl --help\e[0m\n'
    if command -v code &>/dev/null; then
      printf '  \e[38;2;100;160;220mvscode\e[0m  \e[38;2;255;210;60mcode\e[0m \e[38;2;140;150;160m<file>\e[0m  opens in host VS Code\n'
    fi
    printf '\n'
    printf '  \e[38;2;100;160;220mai\e[0m      \e[38;2;255;210;60mgt\e[0m       gastown orchestrator\n'
    printf '          \e[38;2;255;210;60mclaude\e[0m   Claude Code CLI\n'
    printf '\n'
  fi
  unset _wl_session _wl_guide
fi

# Source user overrides if present
[[ -f ~/.config/work-lab/bashrc.local ]] && source ~/.config/work-lab/bashrc.local
