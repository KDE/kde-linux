# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
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

# Set up completions.
zstyle :compinstall filename "~/.zshrc"
autoload -Uz compinit
compinit

# Set the autosuggest strategy to use history first, then completion.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
