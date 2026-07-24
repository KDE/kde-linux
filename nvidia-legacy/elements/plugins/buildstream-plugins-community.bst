# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: junction

# This must be a tar source because we need to bootstrap this on top of core buildstream. Which funnily enough has no useful sources available that you can run
# bst source track on. As such this had ideally been a git_repo, but that isn't available in core buildstream.
sources:
- kind: tar
  url: pypi:08/b4/4b5311dd4ea599bdc69d911263f5d3f8b4c14789d69265d7ea2be7e4e120/buildstream_plugins_community-2.3.0.tar.gz
  ref: cdd3b73ff998e4145d2bb1a1215b961c65b073a4956609417ab747ef8f462c44
