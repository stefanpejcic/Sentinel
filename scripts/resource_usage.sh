#!/bin/bash

source helpers/main.sh

# 
LOAD_THRESHOLD=$(awk -F'=' '/^load/ {print $2}' "$INI_FILE")
LOAD_THRESHOLD=${LOAD_THRESHOLD:-20}
is_valid_number "$LOAD_THRESHOLD" || LOAD_THRESHOLD=20

CPU_THRESHOLD=$(awk -F'=' '/^cpu/ {print $2}' "$INI_FILE")
CPU_THRESHOLD=${CPU_THRESHOLD:-90}
is_valid_number "$CPU_THRESHOLD" || CPU_THRESHOLD=90

RAM_THRESHOLD=$(awk -F'=' '/^ram/ {print $2}' "$INI_FILE")
RAM_THRESHOLD=${RAM_THRESHOLD:-85}
is_valid_number "$RAM_THRESHOLD" || RAM_THRESHOLD=85

DISK_THRESHOLD=$(awk -F'=' '/^du/ {print $2}' "$INI_FILE")
DISK_THRESHOLD=${DISK_THRESHOLD:-85}
is_valid_number "$DISK_THRESHOLD" || DISK_THRESHOLD=85




# Function to check system load and write notification if it exceeds the threshold
check_system_load() {
  local title="High System Load!"

  local current_load=$(uptime | awk -F'average:' '{print $2}' | awk -F', ' '{print $1}')
  local load_int=${current_load%.*}  # Extract the integer part
  
  if [ "$load_int" -gt "$LOAD_THRESHOLD" ]; then
    echo "Average Load usage ($load_int) is higher than treshold value ($LOAD_THRESHOLD). Writing notification."
    write_notification "$title" "Current load: $current_load"
  else
    echo "System load is within acceptable limits."
    echo "Current Load usage $current_load is lower than the treshold value $LOAD_THRESHOLD. Skipping."
  fi
}

# Function to check RAM usage and write notification if it exceeds the threshold
check_ram_usage() {
  local title="High Memory Usage!"

  local total_ram=$(free -m | awk '/^Mem:/{print $2}')
  local used_ram=$(free -m | awk '/^Mem:/{print $3}')
  local ram_percentage=$((used_ram * 100 / total_ram))
  
  local message="Used RAM: $used_ram MB, Total RAM: $total_ram MB, Usage: $ram_percentage%"
  local message_to_check_in_file="Used RAM"

  # Check if there is an unread RAM notification
  if is_unread_message_present "$message_to_check_in_file"; then
    echo "Unread RAM usage notification already exists. Skipping."
    return
  fi

  if [ "$ram_percentage" -gt "$RAM_THRESHOLD" ]; then
    echo "RAM usage ($ram_percentage) is higher than treshold value ($RAM_THRESHOLD). Writing notification."
    write_notification "$title" "$message"
  else
    echo "Current RAM usage $ram_percentage is lower than the treshold value $RAM_THRESHOLD. Skipping."
  fi
}

function check_cpu_usage() {
  local title="High CPU Usage!"

  local cpu_percentage=$(top -bn1 | awk '/^%Cpu/{print $2}' | awk -F'.' '{print $1}')
  
if [ "$cpu_percentage" -gt "$CPU_THRESHOLD" ]; then
  echo "CPU usage ($cpu_percentage) is higher than treshold ($CPU_TRESHOLD). Writing notification."
  top_processes=$(ps aux --sort -%cpu | head -10 | sed ':a;N;$!ba;s/\n/\\n/g')
  write_notification "$title" "CPU Usage: $cpu_percentage% | Top Processes: $top_processes"
else
  echo "Current CPU usage $cpu_percentage is lower than the treshold value $CPU_THRESHOLD. Skipping."
fi
}

function check_disk_usage() {
  local title="Running out of Disk Space!"
  local disk_percentage=$(df -h --output=pcent / | tail -n 1 | tr -d '%')

  if [ "$disk_percentage" -gt "$DISK_THRESHOLD" ]; then

  # Check if there is an unread DU notification
  if is_unread_message_present "$title"; then
    echo "Unread DU notification already exists. Skipping."
    return
  fi
    echo "Disk usage ($disk_percentage) is higher than the treshold value $DISK_THRESHOLD. Writing notification."
    disk_partitions_usage=$(df -h | sort -r -k 5 -i | sed ':a;N;$!ba;s/\n/\\n/g')
    write_notification "$title" "Disk Usage: $disk_percentage% | Partitions: $disk_partitions_usage"
  else
  echo "Current Disk usage $disk_percentage is lower than the treshold value $DISK_THRESHOLD. Skipping."
  fi
}





  check_disk_usage

  check_system_load

  check_ram_usage

  check_cpu_usage
