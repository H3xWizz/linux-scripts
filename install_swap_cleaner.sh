#!/bin/bash

# Check for a percentage argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <swap_usage_threshold_percentage>"
    exit 1
fi

SWAP_THRESHOLD=$1

# Define file paths
SWAP_SCRIPT=/usr/local/bin/swap_cleaner.sh
SWAP_SERVICE=/etc/systemd/system/swap_cleaner.service

# Stop the systemd service if it's running
if systemctl is-active --quiet swap_cleaner.service; then
    echo "Stopping the swap_cleaner service..."
    sudo systemctl disable swap_cleaner.service
    sudo systemctl stop swap_cleaner.service
fi

# Remove existing swap cleaner script if it exists
if [ -f "$SWAP_SCRIPT" ]; then
    echo "Removing existing swap_cleaner.sh..."
    sudo rm -f "$SWAP_SCRIPT"
fi

# Remove existing systemd service file if it exists
if [ -f "$SWAP_SERVICE" ]; then
    echo "Removing existing swap_cleaner.service..."
    sudo rm -f "$SWAP_SERVICE"
fi

# Install the swap cleaner script
echo "Installing swap_cleaner.sh..."
sudo cat << EOF > "$SWAP_SCRIPT"
#!/bin/bash -eu

# Set the swap usage threshold from the argument
SWAP_THRESHOLD=$SWAP_THRESHOLD

while true; do
    total=\$(awk '/SwapTotal:/{print \$2}' /proc/meminfo)
    free=\$(awk '/SwapFree:/{print \$2}' /proc/meminfo)
    [ \$total -eq 0 ] && continue

    used=\$((total - free))
    percent=\$((used * 100 / total))

    echo "Used Swap Percentage: \$percent%"

    if [ \$percent -ge \$SWAP_THRESHOLD ]; then
        echo "SWAP has reached \$percent%, resetting swap..."
        swapoff -a && swapon -a
    fi

    sleep 30
done
EOF

# Make the script executable
sudo chmod +x "$SWAP_SCRIPT"

# Create the systemd service file
echo "Creating systemd service..."
sudo cat << EOF > "$SWAP_SERVICE"
[Unit]
Description=Swap Usage Monitor
After=network.target

[Service]
ExecStart=$SWAP_SCRIPT
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
