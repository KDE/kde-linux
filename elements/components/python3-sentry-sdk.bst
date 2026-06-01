# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: pip

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
- freedesktop-sdk.bst:components/python3-setuptools.bst

depends:
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/python3-certifi.bst
- freedesktop-sdk.bst:components/python3-urllib3.bst

variables:
  pip-flags: >-
    pip install
    --no-deps
    --no-index
    --no-build-isolation
    --root="%{install-root}"
    --prefix="%{prefix}"

sources:
- kind: tar
  url: pypi:source/s/sentry-sdk/sentry_sdk-2.62.0.tar.gz
  ref: 3c870b9f50d9fd15b58c817dbde1c7cfaa9fe3f05df0a4c6edd5571cb82f5491
