# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>

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
WORDCHARS=${WORDCHARS//\/[&.;]} # Don't consider certain characters part of the word

# Don't fail on non-matching globs - they may be used by a command internally.
# This behaviour is more consistent with bash.
setopt +o nomatch

# Set the history file and size.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Remove an older command from history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Allow comments even in interactive shells.
setopt interactivecomments

# Remove path separator from WORDCHARS.
# Individual files/directories are treated as words, rather than the full path string.
WORDCHARS=${WORDCHARS//[\/]}

# Set up a nicer prompt than the default.
autoload -U colors && colors
setopt PROMPT_SUBST

# Gets the git branch and status to put into the prompt.
parse_git_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    local git_status_indicator=""

    if [[ -n "$(git status --porcelain)" ]]; then
      git_status_indicator="%F{red}*%f"
    fi

    echo " (%f%F{blue}${branch}${git_status_indicator}%f)"
  fi
}

local path_segment='[%f%F{yellow}%n@%m%f:%4~%f]%f'
local git_segment='$(parse_git_info)'
local prompt_symbol='%(?. . %F{red}[%?]%f )%(#.#.$) '

PROMPT="${path_segment}${git_segment}${prompt_symbol}"

# Turn on completions.
autoload -U compinit
compinit
