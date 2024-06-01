#!/bin/bash

source helpers/main.sh

#
SWAP_THRESHOLD=$(awk -F'=' '/^swap/ {print $2}' "$INI_FILE")
SWAP_THRESHOLD=${SWAP_THRESHOLD:-40}
is_valid_number "$SWAP_THRESHOLD" || SWAP_THRESHOLD=40
HOSTNAME=$(hostname)


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



swap_healing() {
    local title="SWAP usage alert!"
    SWAP_USAGE=$(free -t | awk 'FNR == 3 {print $3/$2*100}')
    SWAP_USAGE_NO_DECIMALS=$(printf %.0f $SWAP_USAGE)
    TIME=$(date)
    #Execute check
    if [ "$SWAP_USAGE_NO_DECIMALS" -gt "$SWAP_THRESHOLD" ]; then
        echo "Current SWAP usage ($SWAP_USAGE_NO_DECIMALS) is higher than treshold value ($SWAP_THRESHOLD). Writing notification."
        write_notification "$title" "Current SWAP usage: $current_load Strating the cleanup process now... you will get a new notification once everything is completed..."
        echo 2 >/proc/sys/vm/drop_caches
        swapoff -a
        swapon -a

        swap_usage=$(free -t | awk 'FNR == 3 {print $3/$2*100}')
        swap_usage_no_decimals=$(printf %.0f $SWAP_USAGE)
        local title_ok="SWAP is cleared - Current value: $swap_usage_no_decimals"
        local title_not_ok="URGENT! SWAP could not be cleared on $HOSTNAME  - Current value: $swap_usage_no_decimals"
        if [ "$swap_usage_no_decimals" -lt "$SWAP_THRESHOLD" ]; then
            echo -e "The Sentinel service has completed clearing SWAP on server $HOSTNAME! \n THANK YOU FOR USING THIS SERVICE! PLEASE REPORT ALL BUGS AND ERRORS TO sentinel@openpanel.co"
            write_notification "$title_ok" "The Sentinel service has completed clearing SWAP on server $HOSTNAME!"
            echo -e "SWAP Usage was abnormal, healing completed, notification sent! This SWAP check was performed at: $TIME"
        else
            echo "URGENT! SWAP could not be cleared on $HOSTNAME"
            write_notification "$title_not_ok" "The Sentinel service detected abnormal SWAP usage at $TIME and tried clearing the space but SWAP usage is still above the $swap_usage_no_decimals treshold."
        fi
    else
        echo "Current SWAP usage is $SWAP_USAGE_NO_DECIMALS (bellow the ${SWAP_THRESHOLD}% treshold) - SWAP check was performed at: $TIME "
    fi
}


swap_healing
