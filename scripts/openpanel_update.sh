#!/bin/bash

source helpers/main.sh

#
UPDATE=$(awk -F'=' '/^update/ {print $2}' "$INI_FILE")
UPDATE=${UPDATE:-yes}
[[ "$UPDATE" =~ ^(yes|no)$ ]] || UPDATE=yes


