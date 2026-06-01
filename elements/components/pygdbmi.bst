# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: pip

sources:
- kind: tar
  url: https://files.pythonhosted.org/packages/source/p/pygdbmi/pygdbmi-0.11.0.0.tar.gz
  ref: 7a286be2fcf25650d9f66e11adc46e972cf078a466864a700cd44739ad261fb0

build-depends:
- freedesktop-sdk.bst:components/python3-setuptools.bst
- freedesktop-sdk.bst:components/python3-pip.bst

depends:
- freedesktop-sdk.bst:components/python3.bst

variables:
  pip-flags: >-
    pip install
    --no-deps
    --no-index
    --no-build-isolation
    --root="%{install-root}"
    --prefix="%{prefix}"
