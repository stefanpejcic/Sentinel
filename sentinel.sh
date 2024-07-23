
#!/bin/bash

SCRIPT_DIR="/usr/local/sentinel"

case "$1" in
    on_reboot)
        . on_reboot.sh
        ;;
    service_status)
        $SCRIPT_DIR/service_status.sh
        ;;
    resource_usage)
        $SCRIPT_DIR/resource_usage.sh
        ;;
    login_check)
        $SCRIPT_DIR/login_check.sh
        ;;
    dos_protection)
        $SCRIPT_DIR/dos_protection.sh
        ;;
    *)
        echo "Invalid argument"
        exit 1
        ;;
esac
