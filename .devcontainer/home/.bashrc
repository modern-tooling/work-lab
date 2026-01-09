# work-lab bash config

# Custom prompt: [work-lab] in cyan, path in gray, ❯ in accent blue
PS1='\[\e[38;2;80;200;220m\][work-lab]\[\e[0m\] \[\e[38;2;140;150;160m\]\w\[\e[0m\] \[\e[38;2;130;180;210m\]❯\[\e[0m\] '

# Helpful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Source user overrides if present
[[ -f ~/.config/work-lab/bashrc.local ]] && source ~/.config/work-lab/bashrc.local
