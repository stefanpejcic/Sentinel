#!/bin/bash

# notifications conf file
CONF_FILE="/usr/local/panel/conf/panel.config"

# main conf file
INI_FILE="/usr/local/admin/service/notifications.ini"

# Check if the INI file exists
if [ ! -f "$INI_FILE" ]; then
    echo "Error: INI file not found: $INI_FILE"
    exit 1
fi


# Extract email address from the configuration file
EMAIL_ALERT=$(awk -F'=' '/^email/ {print $2}' "$CONF_FILE")

# If email address is found, set EMAIL_ALERT to "yes" and set EMAIL to that address
if [ -n "$EMAIL_ALERT" ]; then
    EMAIL=$EMAIL_ALERT
    EMAIL_ALERT=yes
else
    # If no email address is found, set EMAIL_ALERT to "no" by default
    EMAIL_ALERT=no
fi


REBOOT=$(awk -F'=' '/^reboot/ {print $2}' "$INI_FILE")
REBOOT=${REBOOT:-yes}
[[ "$REBOOT" =~ ^(yes|no)$ ]] || REBOOT=yes


# helper function to generate random token
generate_random_token() {
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 64
}

generate_random_token_one_time_only() {
    local config_file="/usr/local/panel/conf/panel.config"
    TOKEN_ONE_TIME="$(generate_random_token)"
    local new_value="mail_security_token=$TOKEN_ONE_TIME"
    # Use sed to replace the line in the file
    sed -i "s|^mail_security_token=.*$|$new_value|" "$config_file"
}



# Send an email alert
email_notification() {
  local title="$1"
  local message="$2"


  #set random token
  generate_random_token_one_time_only

  # use the token
  TRANSIENT=$(awk -F'=' '/^mail_security_token/ {print $2}' "$CONF_FILE")

  #echo $TRANSIENT
  # curl -k -X POST   https://127.0.0.1:2087/send_email  -F 'transient=z3t5LPt4HirqpmW1KHbZdEXtgNR4Rl4bIw6xv4irUZIxXkIXZ8SJHjduOhjvDEe8' -F 'recipient=stefan@pejcic.rs' -F 'subject=proba sa servera' -F 'body=Da li je dosao mejl? Hvala.'
  
  # Check for SSL
  SSL=$(awk -F'=' '/^ssl/ {print $2}' "$CONF_FILE")
  
  # Determine protocol based on SSL configuration
  if [ "$SSL" = "yes" ]; then
    PROTOCOL="https"
  else
    PROTOCOL="http"
  fi
  
  # Send email using appropriate protocol
  curl -k -X POST "$PROTOCOL://127.0.0.1:2087/send_email" -F "transient=$TRANSIENT" -F "recipient=$EMAIL" -F "subject=$title" -F "body=$message"

}

# Function to check if an unread message with the same content exists in the log file
is_unread_message_present() {
  local unread_message_content="$1"
  grep -q "UNREAD.*$unread_message_content" "$LOG_FILE" && return 0 || return 1
}



# Function to write notification to log file if it's different from the last message content
write_notification() {
  local title="$1"
  local message="$2"
  local current_message="$(date '+%Y-%m-%d %H:%M:%S') UNREAD $title MESSAGE: $message"
  local last_message_content=$(get_last_message_content)

  # Check if the current message content is the same as the last one and has "UNREAD" status
  if [ "$message" != "$last_message_content" ] && ! is_unread_message_present "$title"; then
    echo "$current_message" >> "$LOG_FILE"
    if [ "$EMAIL_ALERT" != "no" ]; then
      email_notification "$title" "$message"
    else
      echo "Email alerts are disabled."
    fi


  fi
}



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
