# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/fzf/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: Command-line fuzzy finder

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/go.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

environment:
  FZF_VERSION: '0.73.1'
  FZF_REVISION: tarball

variables:
  make-install: |
    make install
    install -Dm755 bin/fzf "%{install-root}%{bindir}/fzf"
    install -Dm755 bin/fzf-tmux "%{install-root}%{bindir}/fzf-tmux"
    install -Dm644 man/man1/fzf.1 "%{install-root}%{mandir}/man1/fzf.1"
    install -Dm644 man/man1/fzf-tmux.1 "%{install-root}%{mandir}/man1/fzf-tmux.1"
    install -Dm644 shell/completion.bash "%{install-root}%{datadir}/bash-completion/completions/fzf"
    install -Dm644 shell/key-bindings.bash "%{install-root}%{datadir}/fzf/key-bindings.bash"
    install -Dm644 shell/completion.zsh "%{install-root}%{datadir}/zsh/site-functions/_fzf"
    install -Dm644 shell/key-bindings.zsh "%{install-root}%{datadir}/fzf/key-bindings.zsh"
    install -Dm644 shell/key-bindings.fish "%{install-root}%{datadir}/fish/vendor_functions.d/fzf_key_bindings.fish"

sources:
- kind: git_repo
  url: github:junegunn/fzf.git
  track: 'v*'
  ref: v0.73.1-0-gce4bef75954bebd87e0886435bcf8c6904328ab0
- kind: go_module
  url: github:charlievieth/fastwalk.git
  module: github.com/charlievieth/fastwalk
  ref:
    go-version: v1.0.14
    git-ref: v1.0.14-0-gd0efdb677b7d530787d199a02cb29bee285179ff
    explicit: True
- kind: go_module
  url: github:gdamore/tcell.git
  module: github.com/gdamore/tcell/v2
  ref:
    go-version: v2.9.0
    git-ref: v2.9.0-0-ge5785a44313902810c1d855154516ba332c7494f
    explicit: True
- kind: go_module
  url: github:junegunn/go-shellwords.git
  module: github.com/junegunn/go-shellwords
  ref:
    go-version: v0.0.0-20250127100254-2aa3b3277741
    git-ref: 2aa3b3277741a6ad31883f223d770221a85e9dd0
    explicit: True
- kind: go_module
  url: github:mattn/go-isatty.git
  module: github.com/mattn/go-isatty
  ref:
    go-version: v0.0.22
    git-ref: v0.0.22-0-g9a68506e239465d922dc18c0cd331c49b411fdb2
    explicit: True
- kind: go_module
  url: github:rivo/uniseg.git
  module: github.com/rivo/uniseg
  ref:
    go-version: v0.4.7
    git-ref: v0.4.7-0-g03509a98a092b522b2ff0de13e53513d18b3b837
    explicit: True
- kind: go_module
  url: github:golang/sys.git
  module: golang.org/x/sys
  ref:
    go-version: v0.35.0
    git-ref: v0.35.0-0-g5b936e1f126baa13682eff91c2e4d5d9e3a0b71d
    explicit: True
- kind: go_module
  url: github:golang/term.git
  module: golang.org/x/term
  ref:
    go-version: v0.34.0
    git-ref: v0.34.0-0-ga35244d18d7756b12deca31a518c0fa1327d050a
    explicit: True
- kind: go_module
  url: github:gdamore/encoding.git
  module: github.com/gdamore/encoding
  ref:
    go-version: v1.0.1
    git-ref: v1.0.1-0-g6770ff7f5dae83f6e1bec40dc177c0f347df5139
    explicit: True
- kind: go_module
  url: github:lucasb-eyer/go-colorful.git
  module: github.com/lucasb-eyer/go-colorful
  ref:
    go-version: v1.2.0
    git-ref: v1.2.0-0-gd2b05a0d83cca9d610425691c3253d5f36d0ad06
    explicit: True
- kind: go_module
  url: github:mattn/go-runewidth.git
  module: github.com/mattn/go-runewidth
  ref:
    go-version: v0.0.16
    git-ref: v0.0.16-0-g6ceadc68530e7bfea8cba17d6523bed32912d4fa
    explicit: True
- kind: go_module
  url: github:golang/text.git
  module: golang.org/x/text
  ref:
    go-version: v0.28.0
    git-ref: v0.28.0-0-g425d715b4a85c7698cedf621412bb53794cbda53
    explicit: True
