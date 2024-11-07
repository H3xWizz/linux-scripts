#!/bin/bash

# Function to display the header
function showHeader() {
    cat << "EOF"
 _   _ _____    __        ___             ____            _       _       
| | | |___ /_  _\ \      / (_)________   / ___|  ___ _ __(_)_ __ | |_ ___ 
| |_| | |_ \ \/ /\ \ /\ / /| |_  /_  /   \___ \ / __| '__| | '_ \| __/ __|
|  _  |___) >  <  \ V  V / | |/ / / /     ___) | (__| |  | | |_) | |_\__ \
|_| |_|____/_/\_\  \_/\_/  |_/___/___|   |____/ \___|_|  |_| .__/ \__|___/
                                                         |_|            

Swap Cleaner Installation Script...
EOF
}

# Function to display the Linux scripts menu
function linuxScriptsMenu() {
    while true; do
        clear
        showHeader
        echo "1. Dev Setup"
        echo "2. Install Swap Cleaner"
        echo "3. Exit"
        echo -n "Choose an option: "
        read choice

        case $choice in
            1)
                echo "Running Dev Setup..."
                dev_command='bash <(curl -sL https://raw.githubusercontent.com/H3xWizz/h3xwizz-scripts/refs/heads/main/linux/dev_setup.sh)'
                eval $dev_command
                echo "Bye..."
                break
                ;;
            2)
                echo "Running Install Swap Cleaner..."
                swap_command='curl -sL -o /tmp/h3xwizz_script.sh https://raw.githubusercontent.com/H3xWizz/h3xwizz-scripts/refs/heads/main/linux/install_swap_cleaner.sh && sudo bash /tmp/h3xwizz_script.sh'

                # Prompt the user for --limit-percent value, with a default of 50
                echo -n "--limit-percent (DEFAULT: 50): "
                read limit_percent
                if [ -z "$limit_percent" ]; then
                    limit_percent=50  # Use default if no input is provided
                fi
                swap_command+=" --limit-percent $limit_percent"
                
                # Prompt the user for --sleep-time value, with a default of 30
                echo -n "--sleep-time (DEFAULT: 30): "
                read sleep_time
                if [ -z "$sleep_time" ]; then
                    sleep_time=30  # Use default if no input is provided
                fi
                swap_command+=" --sleep-time $sleep_time"
                
                # Print and execute the final swap_command
                echo "Running command: $swap_command"

                # Execute the swap cleaner command
                eval $swap_command
                echo "Cleaning up..."
                sudo rm /tmp/h3xwizz_script.sh -Rf
                echo "Bye..."
                break
                ;;
            3)
                echo "Bye..."
                break
                ;;
            *)
                echo "Invalid option! Please try again."
                ;;
        esac
    done
}

# Check the operating system and call the appropriate menu
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "MacOS detected. This script is for Linux only."
else
    echo "Linux detected."
    linuxScriptsMenu
fi
