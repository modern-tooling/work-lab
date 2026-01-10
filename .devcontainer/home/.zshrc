# work-lab zsh config

# Suppress partial line marker (the % that appears for incomplete lines)
PROMPT_EOL_MARK=''

# Add work-lab bin and Go bin to PATH
export PATH="$HOME/bin:$HOME/go/bin:$PATH"

# Terminal environment (fallback if not set by container)
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export COLORTERM="${COLORTERM:-truecolor}"

# Custom prompt: [work-lab] cyan, path sky blue, $ dim
# Sky blue path distinguishes from white user text
PROMPT='%F{#50c8dc}[work-lab]%f %F{#64a0dc}%~%f %F{#8c969f}$%f '

# Helpful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias wl='work-lab'
alias claude-dsp='claude --dangerously-skip-permissions'

# One-time welcome guide in first tmux pane
# Theme colors: cyan #50c8dc, sky blue #64a0dc, gold #ffd23c, dim #8c969f
# Check window:pane index (1:1 with base-index 1, pane-base-index 1)
if [[ -n "$TMUX" ]]; then
  _wl_pos=$(tmux display-message -p '#{window_index}:#{pane_index}' 2>/dev/null)
  _wl_session=$(tmux display-message -p '#S' 2>/dev/null)
  _wl_guide="/tmp/.work-lab-guide-${_wl_session}"
  if [[ "$_wl_pos" == "1:1" && ! -f "$_wl_guide" ]]; then
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
    printf '  \e[38;2;100;160;220mai\e[0m      \e[38;2;255;210;60mclaude\e[0m   Claude Code CLI\n'
    printf '          \e[38;2;255;210;60mbd\e[0m       beads task tracking\n'
    printf '\n'
  fi
  unset _wl_pos _wl_session _wl_guide
fi

# Source user overrides if present
[[ -f ~/.config/work-lab/zshrc.local ]] && source ~/.config/work-lab/zshrc.local
