#!/bin/bash

LOCK_FILE="/tmp/swap_cleanup.lock"

# Check if the lock file exists and is older than 6 hours, then delete it
if [ -f "$LOCK_FILE" ]; then
    file_age=$(($(date +%s) - $(date -r "$LOCK_FILE" +%s)))
    if [ "$file_age" -gt 21600 ]; then
        echo "Lock file is older than 6 hours. Deleting..."
        rm -f "$LOCK_FILE"
    else
        echo "Previous SWAP cleanup is still in progress. Skipping the current run."
        exit 0
    fi
fi


source helpers/main.sh

#
SWAP_THRESHOLD=$(awk -F'=' '/^swap/ {print $2}' "$INI_FILE")
SWAP_THRESHOLD=${SWAP_THRESHOLD:-40}
is_valid_number "$SWAP_THRESHOLD" || SWAP_THRESHOLD=40
HOSTNAME=$(hostname)

swap_healing() {
    local title="SWAP usage alert!"
    SWAP_USAGE=$(free -t | awk 'FNR == 3 {print $3/$2*100}')
    SWAP_USAGE_NO_DECIMALS=$(printf %.0f $SWAP_USAGE)
    TIME=$(date)
    #Execute check
    if [ "$SWAP_USAGE_NO_DECIMALS" -gt "$SWAP_THRESHOLD" ]; then
        echo "Current SWAP usage ($SWAP_USAGE_NO_DECIMALS) is higher than treshold value ($SWAP_THRESHOLD). Writing notification."        
        write_notification "$title" "Current SWAP usage: $current_load Strating the cleanup process now... you will get a new notification once everything is completed..."
        # create when we start
        touch "$LOCK_FILE"
        
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
            # delete after success
            rm -f "$LOCK_FILE"
        else
            echo "URGENT! SWAP could not be cleared on $HOSTNAME"
            write_notification "$title_not_ok" "The Sentinel service detected abnormal SWAP usage at $TIME and tried clearing the space but SWAP usage is still above the $swap_usage_no_decimals treshold."
        fi
    else
        echo "Current SWAP usage is $SWAP_USAGE_NO_DECIMALS (bellow the ${SWAP_THRESHOLD}% treshold) - SWAP check was performed at: $TIME "
        # delete if failed but on next run it is ok
        rm -f "$LOCK_FILE"
    fi
}


swap_healing

#fallback
rm -f "$LOCK_FILE"
