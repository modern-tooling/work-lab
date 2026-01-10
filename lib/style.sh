#!/usr/bin/env bash
# style.sh - work-lab CLI styling library
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
#
# Provides consistent styling using ANSI escape codes.
# Inspired by ox-cli's color palette for post-2025 developer tooling.

# ─────────────────────────────────────────────────────────────────────────────
# Color detection
# ─────────────────────────────────────────────────────────────────────────────
# Detect if terminal supports colors
_supports_color() {
  [[ -t 1 ]] && [[ -n "${TERM:-}" ]] && [[ "$TERM" != "dumb" ]]
}

# Detect if terminal background is light (heuristic based on COLORFGBG)
# Returns 0 (true) if light, 1 (false) if dark or unknown
_is_light_terminal() {
  # COLORFGBG format: "fg;bg" - bg > 6 typically means light background
  if [[ -n "${COLORFGBG:-}" ]]; then
    local bg="${COLORFGBG##*;}"
    [[ "$bg" -gt 6 ]] && return 0
  fi
  # Default to dark (most developer terminals are dark)
  return 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Color palette (24-bit true color with ANSI 256 fallback)
# ─────────────────────────────────────────────────────────────────────────────
# work-lab brand: calming blue-cyan palette for lab/experimental vibe
# Inspired by terminal interfaces in sci-fi films

if _supports_color; then
  # Check for true color support
  if [[ "${COLORTERM:-}" == "truecolor" ]] || [[ "${COLORTERM:-}" == "24bit" ]]; then
    # True color (24-bit) - exact hex colors
    if _is_light_terminal; then
      # Light mode colors (darker for contrast)
      C_PRIMARY='\033[38;2;60;90;130m'    # deep blue
      C_ACCENT='\033[38;2;80;120;150m'    # steel blue
      C_PASS='\033[38;2;60;120;80m'       # forest green
      C_WARN='\033[38;2;180;120;50m'      # amber
      C_FAIL='\033[38;2;180;60;60m'       # brick red
      C_DIM='\033[38;2;120;130;140m'      # slate gray
      C_CYAN='\033[38;2;40;140;160m'      # teal
    else
      # Dark mode colors (lighter for contrast)
      C_PRIMARY='\033[38;2;100;160;220m'  # sky blue
      C_ACCENT='\033[38;2;130;180;210m'   # light steel
      C_PASS='\033[38;2;120;180;120m'     # sage green
      C_WARN='\033[38;2;230;170;100m'     # copper gold
      C_FAIL='\033[38;2;230;100;100m'     # coral red
      C_DIM='\033[38;2;140;150;160m'      # soft gray
      C_CYAN='\033[38;2;80;200;220m'      # bright cyan
    fi
  else
    # ANSI 256 fallback
    C_PRIMARY='\033[38;5;74m'   # steel blue
    C_ACCENT='\033[38;5;110m'   # light blue
    C_PASS='\033[38;5;108m'     # sage green
    C_WARN='\033[38;5;179m'     # gold
    C_FAIL='\033[38;5;167m'     # coral
    C_DIM='\033[38;5;245m'      # gray
    C_CYAN='\033[38;5;80m'      # cyan
  fi
  C_BOLD='\033[1m'
  C_RESET='\033[0m'
else
  # No color support
  C_PRIMARY='' C_ACCENT='' C_PASS='' C_WARN='' C_FAIL='' C_DIM='' C_CYAN=''
  C_BOLD='' C_RESET=''
fi

# ─────────────────────────────────────────────────────────────────────────────
# Icons (Unicode)
# ─────────────────────────────────────────────────────────────────────────────
ICON_PASS="✓"
ICON_WARN="⚠"
ICON_FAIL="✖"
ICON_INFO="ℹ"
ICON_SKIP="─"
ICON_ARROW="→"
ICON_DOT="•"
ICON_TIP="*"

# ─────────────────────────────────────────────────────────────────────────────
# Semantic color aliases (use these in code for clarity)
# ─────────────────────────────────────────────────────────────────────────────
C_TITLE="$C_PRIMARY"      # titles, headers
C_COMMAND="$C_CYAN"       # command names, paths, values
C_LABEL="$C_DIM"          # labels, secondary text
C_VALUE="$C_ACCENT"       # important values
C_SUCCESS="$C_PASS"       # success messages
C_ERROR="$C_FAIL"         # error messages
C_WARNING="$C_WARN"       # warning messages
C_MUTED="$C_DIM"          # muted/secondary text
C_TIP="$C_CYAN"           # tips: enlighten user about features
C_ACTION="$C_WARN"        # actions: instruct user what to do next
C_SSH="$C_CYAN"           # SSH tunnel ready (bright blue)

# ─────────────────────────────────────────────────────────────────────────────
# Styled output functions
# ─────────────────────────────────────────────────────────────────────────────

# Print with color
print_primary() { printf "${C_PRIMARY}%s${C_RESET}\n" "$*"; }
print_accent() { printf "${C_ACCENT}%s${C_RESET}\n" "$*"; }
print_pass() { printf "${C_PASS}%s${C_RESET}\n" "$*"; }
print_warn() { printf "${C_WARN}%s${C_RESET}\n" "$*"; }
print_fail() { printf "${C_FAIL}%s${C_RESET}\n" "$*"; }
print_dim() { printf "${C_DIM}%s${C_RESET}\n" "$*"; }
print_command() { printf "${C_COMMAND}%s${C_RESET}\n" "$*"; }
print_bold() { printf "${C_BOLD}%s${C_RESET}\n" "$*"; }

# Status indicators with icons
status_ok() { printf "  ${C_PASS}${ICON_PASS}${C_RESET} %s\n" "$*"; }
status_warn() { printf "  ${C_WARN}${ICON_WARN}${C_RESET} %s\n" "$*"; }
status_fail() { printf "  ${C_FAIL}${ICON_FAIL}${C_RESET} %s\n" "$*"; }
status_info() { printf "  ${C_ACCENT}${ICON_INFO}${C_RESET} %s\n" "$*"; }
status_skip() { printf "  ${C_DIM}${ICON_SKIP}${C_RESET} %s\n" "$*"; }

# Section headers
header() {
  printf "\n${C_BOLD}${C_PRIMARY}%s${C_RESET}\n" "$*"
}

subheader() {
  printf "${C_ACCENT}%s${C_RESET}\n" "$*"
}

# Key-value pair (for config display)
kv() {
  local key="$1" value="$2"
  printf "  ${C_LABEL}%s${C_RESET} ${C_COMMAND}%s${C_RESET}\n" "$key" "$value"
}

# Separator line
separator() {
  printf "${C_DIM}──────────────────────────────────────────${C_RESET}\n"
}

# Banner (for startup messages)
banner() {
  local title="$1"
  printf "\n"
  printf "${C_BOLD}${C_PRIMARY}╭─────────────────────────────────────────╮${C_RESET}\n"
  printf "${C_BOLD}${C_PRIMARY}│${C_RESET}  ${C_CYAN}%-39s${C_RESET} ${C_BOLD}${C_PRIMARY}│${C_RESET}\n" "$title"
  printf "${C_BOLD}${C_PRIMARY}╰─────────────────────────────────────────╯${C_RESET}\n"
}

# Progress/activity indicator
activity() {
  printf "${C_DIM}${ICON_DOT}${C_RESET} %s\n" "$*"
}

# Indented detail (for multi-level info)
detail() {
  printf "    ${C_DIM}%s${C_RESET}\n" "$*"
}

# ─────────────────────────────────────────────────────────────────────────────
# Tips vs Actions
# ─────────────────────────────────────────────────────────────────────────────
# TIP: Enlightens and inspires. Shows users cool features they might not know.
#      Use sparingly for "did you know?" moments that add value.
#      Icon: * (asterisk)  Color: cyan (C_TIP)
#      Example: "SSH to devcontainer: prefix + S in tmux"
#
# ACTION: Instructs user what to do next. Error recovery, next steps, fixes.
#         Use when user needs to take action to proceed or resolve an issue.
#         Icon: → (arrow)  Color: amber/gold (C_ACTION)
#         Example: "Run work-lab start"
# ─────────────────────────────────────────────────────────────────────────────

# Tip - enlighten user about a feature or capability
# Use for "did you know?" moments, not for instructions
tip() {
  printf "  ${C_TIP}${ICON_TIP} %b${C_RESET}\n" "$*"
}

# Action - instruct user what to do next
# Use for error recovery, next steps, required actions
action() {
  printf "  ${C_ACTION}${ICON_ARROW} %b${C_RESET}\n" "$*"
}

# Alias for backwards compatibility (maps to action since most hints were instructions)
hint() {
  action "$@"
}
