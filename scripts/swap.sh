#!/bin/bash

SWAP_LIMIT=(40)
HOSTNAME=$(hostname)

swap_healing() {
    ##Run the check for swap usage in a loop
    SWAP_USAGE=$(free -t | awk 'FNR == 3 {print $3/$2*100}')
    SWAP_USAGE_NO_DECIMALS=$(printf %.0f $SWAP_USAGE)
    TIME=$(date)
    #Execute check
    if [ "$SWAP_USAGE_NO_DECIMALS" -gt "$LIMIT" ]; then
        echo "Swap usage above normal, starting clean up..."
        echo -e "The Sentinel service has detected abnormal SWAP usage on server $HOSTNAME! \n Current usage is: $SWAP_USAGE %! \n Strating the cleanup process now... you will get a new notification once everything is completed..."
        echo 2 >/proc/sys/vm/drop_caches
        swapoff -a
        swapon -a
        echo -e "The Sentinel service has completed clearing SWAP on server $HOSTNAME! \n THANK YOU FOR USING THIS SERVICE! \n PLEASE REPORT ALL BUGS AND ERRORS TO sentinel@openpanel.co"
        echo -e "SWAP Usage was abnormal, healing completed, notification sent! This SWAP check was performed at: $TIME"
    else
        echo "Current SWAP usage is $SWAP_USAGE_NO_DECIMALS (bellow the ${LIMIT}% treshold) - SWAP check was performed at: $TIME "
    fi
}


swap_healing
