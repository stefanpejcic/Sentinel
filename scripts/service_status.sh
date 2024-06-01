#!/bin/bash

source helpers/main.sh

#
SERVICES=$(awk -F'=' '/^services/ {print $2}' "$INI_FILE")
SERVICES=${SERVICES:-"panel,admin,nginx,docker,mysql,ufw"}



docker_containers_status() {

#### only mysql so far..

      # Check if the MySQL Docker container is running
      if docker ps --format "{{.Names}}" | grep -q "openpanel_mysql"; then
        echo "MySQL Docker container is active."
      else
        echo "MySQL Docker container is not active. Writing notification to log file."

        # Check the last 100 lines of the MySQL error log for the specified condition
        error_log=$(tail -100 /var/log/mysql/error.log | grep -m 1 "No space left on device")
        title="MySQL service is not active. Users are unable to log into OpenPanel!"
        # Check if there's an error log and include it in the message
        if [ -n "$error_log" ]; then
          message="$error_log"
          write_notification "$title" "$message"
        else
          error_log=$(journalctl -n 5 -u "$service_name" 2>/dev/null | sed ':a;N;$!ba;s/\n/\\n/g')
          message="$error_log"
          write_notification "$title" "$message"
        fi
      fi
}




# Function to check service status and write notification if not active
check_service_status() {
  local service_name="$1"
  local title="$2"

  if systemctl is-active --quiet "$service_name"; then
    echo "$service_name is active."
  else
    echo "$service_name is not active. Writing notification to log file."
    local error_log=""

    # example check
    if [ "$service_name" = "example" ]; then
      :
    else
      # For other services, use the existing journalctl command
      error_log=$(journalctl -n 5 -u "$service_name" 2>/dev/null | sed ':a;N;$!ba;s/\n/\\n/g')

      # Check if there's an error log and include it in the message
      if [ -n "$error_log" ]; then
        write_notification "$title" "$error_log"
      else
        echo "no logs."
      fi
    fi
  fi
}





  # Check service statuses and write notifications if needed
  
  if echo "$SERVICES" | grep -q "nginx"; then
    check_service_status "nginx" "Nginx service is not active. Users' websites are not working!"
  fi

  if echo "$SERVICES" | grep -q "ufw"; then
    check_service_status "ufw" "Firewall (UFW) service is not active. Server and websites are not protected!"
  fi

  if echo "$SERVICES" | grep -q "admin"; then
    check_service_status "admin" "Admin service is not active. OpenAdmin service is not accessible!"
  fi

  if echo "$SERVICES" | grep -q "panel"; then
    check_service_status "panel" "Panel service is not active. Users' websites are working but OpenPanel is not accessible!"
  fi

  if echo "$SERVICES" | grep -q "docker"; then
    check_service_status "docker" "Docker service is not active. User websites are down!"
  fi

  if echo "$SERVICES" | grep -q "mysql"; then
    docker_containers_status
    #check_service_status "mysql" "MySQL service is not active. Users are unable to log into OpenPanel!"
  fi

  if echo "$SERVICES" | grep -q "named"; then
    check_service_status "named" "Named (BIND9) service is not active. DNS resolving of domains is not working!"
  fi
