
# Linux scripts



# Linux Scripts Repository

Welcome to the Linux Scripts Repository! This repository contains various scripts that can help automate tasks on your Linux system.

## Running Scripts

To run a script directly from the internet using `wget` or `curl`, copy the link to the script file in RAW mode and execute the following command in your terminal:

### Using wget

Copy and paste this command:

```bash
wget [RAW_SCRIPT_URL] -O my_script.sh && sudo chmod +x my_script.sh && sudo ./my_script.sh
```
Example:

```bash
wget https://github.com/username/repository/raw/main/scripts/my_script.sh -O my_script.sh && sudo chmod +x my_script.sh && sudo ./my_script.sh
```

### Using curl

Copy and paste this command:

```bash
curl -sSL [RAW_SCRIPT_URL] -o my_script.sh && sudo chmod +x my_script.sh && sudo ./my_script.sh
```
Example:

```bash
curl -sSL https://github.com/username/repository/raw/main/scripts/my_script.sh -o my_script.sh && sudo chmod +x my_script.sh && sudo ./my_script.sh
```

**Replace** `[RAW_SCRIPT_URL]` with the RAW URL of the script you want to run. Ensure the script is from a trusted source before executing it.

Explore and use the scripts in this repository to automate tasks on your Linux system!
