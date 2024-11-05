#!/bin/bash

# Install the swap cleaner script
echo "Installing swap_cleaner.sh..."
sudo cat << 'EOF' > /usr/local/bin/swap_cleaner.sh
#!/bin/bash -eu

while true; do
    total=$(awk '/SwapTotal:/{print $2}' /proc/meminfo)
    free=$(awk '/SwapFree:/{print $2}' /proc/meminfo)
    [ $total -eq 0 ] && continue

    used=$((total - free))
    percent=$((used * 100 / total))

    echo "Used Swap Percentage: $percent%"

    if [ $percent -ge 60 ]; then
        echo "SWAP has reached $percent%, resetting swap..."
        swapoff -a && swapon -a
    fi

    sleep 30
done
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/swap_cleaner.sh

# Create the systemd service file
echo "Creating systemd service..."
sudo cat << 'EOF' > /etc/systemd/system/swap_cleaner.service
[Unit]
Description=Swap Usage Monitor
After=network.target

[Service]
ExecStart=/usr/local/bin/swap_cleaner.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd configuration and enable the service
echo "Reloading systemd daemon and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable swap_cleaner.service
sudo systemctl start swap_cleaner.service

echo "Installation complete. The swap_cleaner service is now running."
