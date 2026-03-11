# GitHub CLI helper functions

# Rerun failed GitHub workflow runs from the last N time
# Usage: gh_rerun_failed [HH:]MM:SS  or  gh_rerun_failed SS
# Examples:
#   gh_rerun_failed 30       # last 30 seconds
#   gh_rerun_failed 5:00     # last 5 minutes
#   gh_rerun_failed 1:30:00  # last 1 hour 30 minutes
gh_rerun_failed() {
  local time_spec="${1:-5:00}"
  local hours=0 minutes=0 seconds=0

  # Parse time format: SS, MM:SS, or HH:MM:SS
  IFS=':' read -ra parts <<< "$time_spec"
  case ${#parts[@]} in
    1)
      seconds="${parts[0]}"
      ;;
    2)
      minutes="${parts[0]}"
      seconds="${parts[1]}"
      ;;
    3)
      hours="${parts[0]}"
      minutes="${parts[1]}"
      seconds="${parts[2]}"
      ;;
    *)
      echo "Usage: gh_rerun_failed [[HH:]MM:]SS"
      echo "Examples: 30, 5:00, 1:30:00"
      return 1
      ;;
  esac

  # Build the time ago string for date command (use negative values)
  local time_ago=""
  [[ $hours -gt 0 ]] && time_ago+="-${hours} hours "
  [[ $minutes -gt 0 ]] && time_ago+="-${minutes} minutes "
  [[ $seconds -gt 0 ]] && time_ago+="-${seconds} seconds "
  time_ago="${time_ago% }"

  local since
  since=$(date -u -d "$time_ago" +%Y-%m-%dT%H:%M:%SZ)

  echo "Rerunning failed workflows since $since..."

  local run_ids
  run_ids=$(gh run list --status=failure --created=">$since" --json databaseId -q '.[].databaseId')

  if [[ -z "$run_ids" ]]; then
    echo "No failed workflow runs found in the last $time_spec"
    return 0
  fi

  local count
  count=$(echo "$run_ids" | wc -l)
  echo "Found $count failed run(s)"

  echo "$run_ids" | while read -r run_id; do
    echo "Rerunning workflow $run_id..."
    gh run rerun "$run_id" --failed
  done

  echo "Done!"
}

# Alias for convenience
alias ghrf='gh_rerun_failed'
