// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Thomas Duckworth <tduck@filotimoproject.org>

// See https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig

// Ensure GPU hardware acceleration works on all hardware, including NVIDIA.
// See https://wiki.archlinux.org/title/Firefox#Hardware_video_acceleration
// Also ensure that OpenH264 and EME (for DRM content) are enabled for 
// license-encumbered video playback.
pref("gfx.webrender.all", true);
pref("media.eme.enabled", true);
pref("media.gmp-gmpopenh264.enabled", true);
pref("media.hardware-video-decoding.force-enabled", true);
