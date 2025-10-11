# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>

# Set the history file and size.
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Automatically cd when a directory is entered.
setopt autocd

# Don't fail on non-matching globs - they may be used by a command internally.
# This behaviour is more consistent with bash.
setopt +o nomatch

# Set keybinds to emacs mode.
bindkey -e

# Set the autosuggest strategy to use history first, then completion.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)