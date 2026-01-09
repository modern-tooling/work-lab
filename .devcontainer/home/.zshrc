# work-lab zsh config

# Custom prompt: [work-lab] in cyan, path in gray, ❯ in accent blue
PROMPT='%F{#50c8dc}[work-lab]%f %F{#8c969f}%~%f %F{#82b4d2}❯%f '

# Helpful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias wl='work-lab'

# Source user overrides if present
[[ -f ~/.config/work-lab/zshrc.local ]] && source ~/.config/work-lab/zshrc.local
