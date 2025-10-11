# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>

# Set keybinds to emacs mode.
# This behaviour is more consistent with bash.
bindkey -e

# Don't fail on non-matching globs - they may be used by a command internally.
# This behaviour is more consistent with bash.
setopt +o nomatch

# Set the history file and size.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Remove an older command from history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Remove path separator from WORDCHARS.
# Individual files/directories are treated as words, rather than the full path string.
WORDCHARS=${WORDCHARS//[\/]}

# Set up a nicer prompt than the default.
autoload -U colors && colors
setopt PROMPT_SUBST
PROMPT='[%f%F{yellow}%n@%m%f:%~%f]%f%(?. . %F{red}[%?]%f )%(#.#.$) '

# Turn on completions.
autoload -U compinit
compinit
