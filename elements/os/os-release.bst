# SPDX-FileCopyrightText: 2026 KDE Linux Contributors
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

(@):
- include/kde-linux-image.yml

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

environment:
  INSTALL_ROOT: '%{install-root}'

config:
  install-commands:
  - |
    install -d "$INSTALL_ROOT/usr/lib"
    install -d "$INSTALL_ROOT/usr/lib/kde-linux"
    install -d "$INSTALL_ROOT/etc"
    cat > "$INSTALL_ROOT/usr/lib/os-release" <<EOF
    NAME="KDE Linux"
    PRETTY_NAME="KDE Linux"
    ID="kde-linux"
    DEFAULT_HOSTNAME="kde-linux"
    VERSION_ID="%{kde-linux-version-date}"
    BUILD_ID="%{kde-linux-build-id}"
    ANSI_COLOR="38;2;61;174;233"
    HOME_URL="https://linux.kde.org"
    DOCUMENTATION_URL="https://community.kde.org/KDE_Linux"
    SUPPORT_URL="https://kde.org/support/"
    BUG_REPORT_URL="https://invent.kde.org/kde-linux/kde-linux/-/issues"
    PRIVACY_POLICY_URL="https://kde.org/privacypolicy-apps/"
    LOGO="/usr/share/pixmaps/kde-linux-logo.png"
    IMAGE_ID="kde-linux"
    IMAGE_VERSION="%{kde-linux-image-version}"
    KDE_LINUX_COMMIT_SHA="%{kde-linux-commit-sha}"
    KDE_LINUX_COMMIT_SHORT_SHA="%{kde-linux-commit-short-sha}"
    KDE_LINUX_CI_URL="%{kde-linux-ci-url}"
    KDE_LINUX_SYSUPDATE_ENDPOINT="sysupdate/v2"
    EOF
    cp "$INSTALL_ROOT/usr/lib/os-release" "$INSTALL_ROOT/usr/lib/kde-linux/os-release"
    ln -sf ../usr/lib/os-release "$INSTALL_ROOT/etc/os-release"
    printf 'KDE Linux \\n \\l\n' > "$INSTALL_ROOT/etc/issue"
    printf 'KDE Linux %%h\n' > "$INSTALL_ROOT/etc/issue.net"
