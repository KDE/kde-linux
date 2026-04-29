# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>
# SPDX-FileCopyrightText: 2026 Daniele Md <dev.runway420@slmails.com>

# Set keybinds to emacs mode.
bindkey -e

# Ensure Home, End, Delete and Insert keys work as users expect.
# Home key:
bindkey '\e[1~' beginning-of-line
bindkey '\e[H'  beginning-of-line
bindkey '\eOH'  beginning-of-line
# End key:
bindkey '\e[4~' end-of-line
bindkey '\e[F'  end-of-line
bindkey '\eOF'  end-of-line
# Delete key (forward delete):
bindkey '\e[3~' delete-char
# Insert key (toggle overwrite mode):
bindkey '\e[2~' overwrite-mode
# Word navigation
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey '^[[3;5~' kill-word         # Ctrl+Delete
# Tab completion now does not expand globs
bindkey '^I' complete-word
# Scroll through commands in history that start with current command line:
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '\e[5~' up-line-or-beginning-search     # Page up
bindkey '\e[6~' down-line-or-beginning-search   # Page down

# Don't fail on non-matching globs - they may be used by a command internally.
# This behaviour is more consistent with bash.
setopt +o nomatch
# Remove an older command from history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS
# Allow comments even in interactive shells.
setopt interactivecomments
# Avoid running immediately lines with history substitutions
setopt hist_verify
# Allow changing directory without writing cd
setopt auto_cd

# Set the history file and size.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# Don't consider certain characters part of the word
WORDCHARS=${WORDCHARS//[\/&.;]}
# Remove chars like slash or space added automatically by zsh completion
# if followed by one of these symbols
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&|'
# Make sure zsh completion leaves always a space when completion is
# followed by one of these symbols
ZLE_SPACE_SUFFIX_CHARS=$';&|'

# Disable tab cycling through completions.
zstyle ':completion:*' menu no
# Make completions case-insensitive.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Turn on completions.
autoload -U compinit
compinit

# Set up a nicer prompt than the default.
autoload -U colors && colors
setopt PROMPT_SUBST

# Gets the git branch and status to put into the prompt.
parse_git_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    local git_status_indicator=""
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      git_status_indicator="%F{red}*%f"
    fi
    echo " (%f%F{blue}${branch}${git_status_indicator}%f)"
  fi
}

local path_segment='[%f%F{yellow}%n@%m%f:%F{cyan}%(4~|…/%3~|%~)%f]%f'
local git_segment='$(parse_git_info)'
local prompt_symbol='%(?. . %F{red}[%?]%f )%(#.#.$) '

PROMPT="${path_segment}${git_segment}${prompt_symbol}"

# Add colored output for various commands.
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Preserve metadata by default; match the behavior of `mv`.
alias cp='cp --preserve=all'
alias rsync='rsync --perms --xattrs --acls --times --atimes'

# Add various useful aliases.
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

# Ask to make an unexecutable file executable before running it.
function auto_chmod() { /usr/lib/auto-chmod "$1" }
autoload -Uz add-zsh-hook
add-zsh-hook preexec auto_chmod

# Wrap journal logs viewed in terminal rather than truncating; friendlier for reading and copying
export SYSTEMD_LESS=FRXMK

# Add autosuggestions, substring history search and syntax highlighting.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bind Ctrl+↑ and Ctrl+↓ keybinds to substring history search.
bindkey '^[[1;5A' history-substring-search-up # Ctrl+↑
bindkey '^[[1;5B' history-substring-search-down # Ctrl+↓

# Set up auth sock for systemd-initiated ssh agent so the user doesn't
# have to faff about with this
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
