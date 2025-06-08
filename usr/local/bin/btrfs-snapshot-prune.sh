#!/bin/bash

# Define snapshot directory
snapshot_dir="/home/.snapshots"

# Define retention policies
keep_daily=7
keep_weekly=4
keep_monthly=3

# Get current date information
current_year=$(date +%Y)
current_month=$(date +%m)
current_day_of_week=$(date +%u) # 1 (Monday) to 7 (Sunday)
current_day_of_month=$(date +%d)

# --- Helper function to list snapshots ---
list_snapshots() {
  ls -1 "$snapshot_dir" | grep -E '^home-[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$' || true
}

# --- Identify snapshots to keep ---
declare -A keep_list

# Keep N most recent daily snapshots
mapfile -t daily_snapshots < <(list_snapshots | sort -r | head -n "$keep_daily")
for snap in "${daily_snapshots[@]}"; do
  keep_list["$snap"]=1
done

# Keep N most recent weekly snapshots (taken on a specific day, e.g., Sunday)
# This assumes snapshots are named home-YYYY-MM-DD_HH-MM-SS
mapfile -t weekly_candidates < <(list_snapshots | sort -r)
weekly_kept=0
for snap in "${weekly_candidates[@]}"; do
  if [[ "$weekly_kept" -ge "$keep_weekly" ]]; then
    break
  fi
  # Extract date part: home-YYYY-MM-DD
  snap_date_str=$(echo "$snap" | cut -d'_' -f1 | sed 's/home-//')
  # Get day of the week for the snapshot
  snap_day_of_week=$(date -d "$snap_date_str" +%u)

  # Let's assume we keep snapshots taken on Sunday (7)
  if [[ "$snap_day_of_week" -eq 7 ]]; then
    keep_list["$snap"]=1
    ((weekly_kept++))
  fi
done

# Keep N most recent monthly snapshots (taken on the 1st of the month)
mapfile -t monthly_candidates < <(list_snapshots | sort -r)
monthly_kept=0
for snap in "${monthly_candidates[@]}"; do
  if [[ "$monthly_kept" -ge "$keep_monthly" ]]; then
    break
  fi
  snap_date_str=$(echo "$snap" | cut -d'_' -f1 | sed 's/home-//')
  snap_day_of_month=$(date -d "$snap_date_str" +%d)

  if [[ "$snap_day_of_month" -eq 1 ]]; then
    keep_list["$snap"]=1
    ((monthly_kept++))
  fi
done


# --- Prune old snapshots ---
echo "Starting snapshot pruning..."
deleted_count=0
for snapshot in $(list_snapshots); do
  if [[ -z "${keep_list[$snapshot]}" ]]; then
    echo "Deleting old snapshot: $snapshot_dir/$snapshot"
    # Actual deletion command:
    /usr/bin/btrfs subvolume delete "$snapshot_dir/$snapshot"
    ((deleted_count++))
  else
    echo "Keeping snapshot: $snapshot_dir/$snapshot"
  fi
done

echo "Pruning complete. Deleted $deleted_count snapshots."
echo "Snapshots kept:"
for snap in "${!keep_list[@]}"; do
    echo "$snapshot_dir/$snap"
done
