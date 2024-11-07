#!/bin/bash

# PARAMETERS
# --limit-percent | Value of swap ussage percent to clear swap | DEFAULT: 50
# --sleep-time    | Time interval (in seconds) between checks  | DEFAULT: 30

clear
cat << "EOF"
 _   _ _____    __        ___             ____            _       _       
| | | |___ /_  _\ \      / (_)________   / ___|  ___ _ __(_)_ __ | |_ ___ 
| |_| | |_ \ \/ /\ \ /\ / /| |_  /_  /   \___ \ / __| '__| | '_ \| __/ __|
|  _  |___) >  <  \ V  V / | |/ / / /     ___) | (__| |  | | |_) | |_\__ \
|_| |_|____/_/\_\  \_/\_/  |_/___/___|   |____/ \___|_|  |_| .__/ \__|___/
                                                         |_|            

Swap Cleaner Installation Script...
EOF

# Default values for parameters
SWAP_THRESHOLD=50
SLEEP_TIME=30

# Parse arguments
while [ "$#" -gt 0 ]; do
    case $1 in
        --limit-percent)
            SWAP_THRESHOLD="$2"
            shift 2
            ;;
        --sleep-time)
            SLEEP_TIME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Notify the user of the detected swap usage threshold and sleep time
echo "Swap usage threshold set to: $SWAP_THRESHOLD%"
echo "Sleep time set to: $SLEEP_TIME seconds"

# Define file paths
SWAP_SCRIPT=/usr/local/bin/swap_cleaner.sh
SWAP_SERVICE=/etc/systemd/system/swap_cleaner.service

# Stop the systemd service if it's running
if systemctl is-active --quiet swap_cleaner.service; then
    echo "Stopping the swap_cleaner service..."
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

# Set the swap usage threshold and sleep time from environment variables
echo "SWAP_THRESHOLD is set to: $SWAP_THRESHOLD%"
echo "SLEEP_TIME is set to: $SLEEP_TIME sec"

while true; do
    total=$(awk '/SwapTotal:/{print $2}' /proc/meminfo)
    free=$(awk '/SwapFree:/{print $2}' /proc/meminfo)
    [ $total -eq 0 ] && continue

    used=$((total - free))
    percent=$((used * 100 / total))

    echo "Used Swap Percentage: $percent%"

    if [ $percent -ge $SWAP_THRESHOLD ]; then
        echo "SWAP has reached $percent%, resetting swap..."
        swapoff -a && swapon -a
    fi

    sleep $SLEEP_TIME
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
Environment=SWAP_THRESHOLD=$SWAP_THRESHOLD
Environment=SLEEP_TIME=$SLEEP_TIME
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
echo "Type 'systemctl status swap_cleaner.service' to check script status"
