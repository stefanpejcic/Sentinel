#!/bin/bash

source helpers/main.sh

# 
REBOOT=$(awk -F'=' '/^reboot/ {print $2}' "$INI_FILE")
REBOOT=${REBOOT:-yes}
[[ "$REBOOT" =~ ^(yes|no)$ ]] || REBOOT=yes


# Function to perform startup action (system reboot notification)
perform_startup_action() {
  if [ "$REBOOT" != "no" ]; then
    local title="SYSTEM REBOOT!"
    local uptime=$(uptime)
    local message="System was rebooted. $uptime"
    write_notification "$title" "$message"
  else
    echo "Reboot is explicitly set to 'no' in the INI file. Skipping logging.."
  fi
}

perform_startup_action
