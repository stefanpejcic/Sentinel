#!/bin/bash

source helpers/main.sh

#
UPDATE=$(awk -F'=' '/^update/ {print $2}' "$INI_FILE")
UPDATE=${UPDATE:-yes}
[[ "$UPDATE" =~ ^(yes|no)$ ]] || UPDATE=yes

# Define the route to check for updates
update_check() {
    # Read the local version from /usr/local/panel/version
    if [ -f "/usr/local/panel/version" ]; then
        local_version=$(cat "/usr/local/panel/version")
    else
        echo '{"error": "Local version file not found"}' >&2
        exit 1
    fi

    # Fetch the remote version from https://update.openpanel.co/
    remote_version=$(curl -s "https://update.openpanel.co/")

    if [ -z "$remote_version" ]; then
        echo '{"error": "Error fetching remote version"}' >&2
        if [ "$UPDATE" != "yes" ]; then
          write_notification "Update check failed" "Failed connecting to https://update.openpanel.co/"
        fi
        exit 1
    fi

    # Compare the local and remote versions
    if [ "$local_version" == "$remote_version" ]; then
        echo '{"status": "Up to date", "installed_version": "'"$local_version"'"}'
    elif [ "$local_version" \> "$remote_version" ]; then
        if [ "$UPDATE" != "yes" ]; then
          write_notification "New OpenPanel update is available" "Installed version: $local_version | Available version: $remote_version"
        fi

        echo '{"status": "Local version is greater", "installed_version": "'"$local_version"'", "latest_version": "'"$remote_version"'"}'
    else
        # Check if skip_versions file exists and if remote version matches
        if [ -f "/etc/openpanel/upgrade/skip_versions" ]; then
            if grep -q "$remote_version" "/etc/openpanel/upgrade/skip_versions"; then
                echo '{"status": "Skipped version", "installed_version": "'"$local_version"'", "latest_version": "'"$remote_version"'"}'
                exit 0
            fi
        fi
        if [ "$UPDATE" != "yes" ]; then
            write_notification "New OpenPanel update is available" "Installed version: $local_version | Available version: $remote_version"
        fi
        echo '{"status": "Update available", "installed_version": "'"$local_version"'", "latest_version": "'"$remote_version"'"}'
    fi
}

update_check
