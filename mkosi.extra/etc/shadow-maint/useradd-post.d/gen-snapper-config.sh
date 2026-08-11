#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Bharadwaj Raju <bharadwaj.raju@machinesoul.in>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

if ! btrfs subvolume show "/home/$SUBJECT" > /dev/null; then
  exit 0;
fi

mkdir -p /etc/snapper/configs

# first tell snapper to make the config, because it needs to register
# the config name in other places (namely /etc/sysconfig/snapper)
# if we just create a file and put it in /etc/snapper/configs,
# snapper will just ignore it
snapper --config "home-$SUBJECT" create-config "/home/$SUBJECT"

cat <<-EOF > "/etc/snapper/configs/home-$SUBJECT"
# subvolume to snapshot
SUBVOLUME="/home/$SUBJECT"

# filesystem type
FSTYPE="btrfs"

# btrfs qgroup for space aware cleanup algorithms
QGROUP=""

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"

# users and groups allowed to work with config
ALLOW_USERS="$SUBJECT"
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="yes"

# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="no"

# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="3600"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots
TIMELINE_CREATE="yes"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="3600"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="10"

# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="3600"
EOF

# so it picks up the change to the config
systemctl restart snapperd.service
