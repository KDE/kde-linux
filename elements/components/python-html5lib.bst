# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:bootstrap/stripper.bst
- freedesktop-sdk.bst:components/python3-pip.bst
- freedesktop-sdk.bst:components/python3.bst

depends:
- freedesktop-sdk.bst:components/python3.bst

config:
  install-commands:
  - >-
    python3 -m pip install
    --verbose
    --exists-action=i
    --no-index
    --find-links="file://${PWD}"
    --prefix="%{install-root}%{prefix}"
    html5lib
    --no-build-isolation

sources:
- kind: remote
  url: pypi:f4/24/2a3e3df732393fed8b3ebf2ec078f05546de641fe1b667ee316ec1dcf3b7/webencodings-0.5.1-py2.py3-none-any.whl
  ref: a0af1213f3c2226497a97e2b3aa01a7e4bee4f403f95be16fc9acd2947514a78
- kind: remote
  url: pypi:6c/dd/a834df6482147d48e225a49515aabc28974ad5a4ca3215c18a882565b028/html5lib-1.1-py2.py3-none-any.whl
  ref: 0d78f8fde1c230e99fe37986a60526d7049ed4bf8a9fadbad5f00e22e58e041d
- kind: remote
  url: pypi:b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl
  ref: 4721f391ed90541fddacab5acf947aa0d3dc7d27b2e1e8eda2be8970586c3274
