#!/bin/bash

# notifications conf file
CONF_FILE="/usr/local/panel/conf/panel.config"

# main conf file
INI_FILE="/usr/local/admin/service/notifications.ini"

# Check if the INI file exists
if [ ! -f "$INI_FILE" ]; then
    echo "Error: INI file not found: $INI_FIxLE"
    exit 1
fi


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

# Function to check if a value is a number between 1 and 100
is_valid_number() {
  local value="$1"
  [[ "$value" =~ ^[1-9][0-9]?$|^100$ ]]
}

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



# Path to the log file
LOG_FILE="/usr/local/admin/logs/notifications.log"


# Function to get the last message content from the log file
get_last_message_content() {
  tail -n 1 "$LOG_FILE" 2>/dev/null
}

# Function to check if an unread message with the same content exists in the log file
is_unread_message_present() {
  local unread_message_content="$1"
  grep -q "UNREAD.*$unread_message_content" "$LOG_FILE" && return 0 || return 1
}

# Send an email alert
email_notification() {
  local title="$1"
  local message="$2"


  #set random token
  generate_random_token_one_time_only

  # use the token
  TRANSIENT=$(awk -F'=' '/^mail_security_token/ {print $2}' "$CONF_FILE")

  echo $TRANSIENT

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


