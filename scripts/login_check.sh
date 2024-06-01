#!/bin/bash

source helpers/main.sh

# 
LOGIN=$(awk -F'=' '/^login/ {print $2}' "$INI_FILE")
LOGIN=${LOGIN:-yes}
[[ "$LOGIN" =~ ^(yes|no)$ ]] || LOGIN=yes



# Notify when admin account is accessed from new IP address
check_new_logins() {
  if [ "$LOGIN" != "no" ]; then

    
    # Extract the last line from the login log file
    last_login=$(tail -n 1 /usr/local/admin/logs/login.log)
    
    # Parse username and IP address from the last login entry
    username=$(echo "$last_login" | awk '{print $3}')
    ip_address=$(echo "$last_login" | awk '{print $4}')

    # Validate IP address format
    if [[ ! $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Invalid IP address format: $ip_address"
      return 1
    fi



    # Check if the username appears more than once in the log file
    if [ $(grep -c $username /usr/local/admin/logs/login.log) -eq 1 ]; then
      echo "First time login detected for user: $username. Skipping IP address check."
    else
      # Check if the combination of username and IP address has appeared before
      if ! grep -q "$username $ip_address" <(sed '$d' /usr/local/admin/logs/login.log); then
        echo "Admin account $username accessed from new IP address, writing notification.."
        local title="Admin account $username accessed from new IP address"
        local message="Admin account $username was accessed from a new IP address: $ip_address"
        write_notification "$title" "$message"
      else
        echo "Admin account $username accessed from previously logged IP address: $ip_address. Skipping notification."
      fi
    fi
  else
    echo "New login detected fro admin user: $username from IP: $ip_address, but notifications are disabled by admin user. Skipping logging."
  fi
}


check_new_logins
