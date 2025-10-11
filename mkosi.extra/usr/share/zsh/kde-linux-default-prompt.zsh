# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>

# A simple, banana-themed ZSH prompt for KDE Linux.

autoload -U colors && colors
setopt PROMPT_SUBST

# Gets the git branch and status (dirty or clean)
parse_git_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git rev-parse --abbrev-ref HEAD)
    local git_status_indicator=""

    if [[ -n $(git status --porcelain) ]]; then
      git_status_indicator="%F{red}*%f"
    fi

    echo " (%f%F{blue}${branch}${git_status_indicator}%f)"
  fi
}

# [user@host:path] part
local path_part='[%f%F{yellow}%n@%m%f:%~%f]%f'
# Git information part 
local git_part='$(parse_git_info)'
# Prompt symbol part
local prompt_symbol='%(?. . %F{red}[%?]%f )%(#.#.$) '

# Combine all parts into the final prompt
PROMPT="${path_part}${git_part}${prompt_symbol}"
