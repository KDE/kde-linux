# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

ARCH?=$(shell uname -m | sed "s/^i.86$$/i686/")
REPO=repo
CHECKOUT_ROOT=runtimes
VM_CHECKOUT_ROOT=checkout/$(ARCH)
OVMF_CODE=$(VM_CHECKOUT_ROOT)/ovmf/usr/share/ovmf/OVMF_CODE.fd
FSDK=freedesktop-sdk/utils/flatpak-builder-to-bst.py
GIT_INVENT=https://invent.kde.org/
GIT_GITLAB=https://gitlab.com/

$(FSDK):
	git clone $(GIT_GITLAB)freedesktop-sdk/freedesktop-sdk.git

flatpak-kde-runtime/org.kde.Sdk.json.in:
	git clone $(GIT_INVENT)packaging/flatpak-kde-runtime.git --branch qt6.11

org.kde.plasma/.flatpak-manifest.yaml:
	git clone $(GIT_INVENT)apol/org.kde.plasma.git --branch work/apol/rebase-newer-69

flatpak-kde-runtime/org.kde.Sdk.json: flatpak-kde-runtime/org.kde.Sdk.json.in
	make org.kde.Sdk.json -C flatpak-kde-runtime ARCH=$(ARCH)

elements/org.kde.Sdk.bst: flatpak-kde-runtime/org.kde.Sdk.json $(FSDK)
	python3 fixup-manifest.py flatpak-kde-runtime/org.kde.Sdk.json --remove os-release --add-module kauth polkit-qt-1 > flatpak-kde-runtime/intermediate.json
	python $(FSDK) flatpak-kde-runtime/intermediate.json --skip plasma.skip.yaml --aliases include/aliases.yml

elements/org.kde.plasma.desktop.bst: $(FSDK) org.kde.plasma/.flatpak-manifest.yaml plasma.skip.yaml include/aliases.yml
	python $(FSDK) org.kde.plasma/.flatpak-manifest.yaml --skip plasma.skip.yaml --aliases include/aliases.yml

# shortcuts
bst: elements/org.kde.Sdk.bst elements/org.kde.plasma.desktop.bst
