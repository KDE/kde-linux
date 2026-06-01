# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: pyproject
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-python-setuptools.bst
depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/python3.bst
sources:
- kind: git_repo
  url: https://github.com/dvarrazzo/py-setproctitle
  track: v*
  ref: version-1.3.7-0-g389ed6f4e3ccfebb34a38893553992ea10cf5dc8
