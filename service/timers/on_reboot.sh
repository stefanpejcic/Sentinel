[Unit]
Description=Run on_reboot script at boot

[Timer]
OnBootSec=1min
Persistent=true

[Install]
WantedBy=timers.target
