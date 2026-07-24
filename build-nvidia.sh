#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

set -eux

# Don't worry about unmounting, we are inside a namespace and cleanup happens when we leave it.
if [ "${1##*.}" == "erofs" ]; then
    mount "$1" "nvidia-legacy/sdk"
else
    mount -o bind "$1" "nvidia-legacy/sdk"
fi

cd nvidia-legacy

. sdk/usr/lib/os-release

# Run all series at the same time so bst can make use of concurrency
bst build nvidia-580.bst nvidia-470.bst

for series in 580 470; do
    bst artifact checkout --force --directory nvidia-$series-usr nvidia-$series.bst

    cd nvidia-$series-usr
    [ -d etc ] && exit 1 # there should be no etc or we would need a confext!
    mkdir --parents usr/lib/extension-release.d/
    cp ../sdk/usr/lib/os-release "usr/lib/extension-release.d/extension-release.nvidia-${series}_$IMAGE_VERSION"
    cd ..
done

cd .. # kde-linux dir

for series in 580 470; do
    systemd-repart \
        --definitions mkosi.repart-unprotected/sysext.repart.d \
        --copy-source nvidia-legacy/nvidia-$series-usr \
        --empty=create \
        --size=auto \
        "nvidia-${series}_$IMAGE_VERSION.sysext.raw"
done
