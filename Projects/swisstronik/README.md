# Setup SGX and Swisstronik
This script automates the setup of Intel SGX and Swisstronik on a Linux system. 
It checks for SGX support, installs the SGX driver and AESM service, and sets up necessary dependencies for Swisstronik development.

## Prerequisites
• A Linux system with kernel version 5.11 or higher.
• BIOS support for SGX (ensure SGX is enabled in BIOS settings).
• Internet connection for downloading necessary packages.

# Usage
## Download the script:
```wget https://raw.githubusercontent.com/blacknodes/Node-Services/main/Projects/swisstronik/setup_sgx_swisstronik.sh```
## Make the script executable:
```chmod +x setup_sgx_swisstronik.sh```
## Run the script with root privileges:
```sudo ./setup_sgx_swisstronik.sh```
## Troubleshooting
If you encounter any issues with the SGX driver installation, ensure that SGX is enabled in your BIOS settings.
