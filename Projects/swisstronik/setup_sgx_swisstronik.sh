#!/bin/bash

# Check if the CPU supports SGX
if grep -q sgx /proc/cpuinfo; then
    echo "SGX is supported by the CPU."
else
    echo "SGX is not supported by the CPU."
    exit 1
fi

# Check if the SGX driver is loaded
if ! lsmod | grep -q isgx; then
    echo "SGX driver is not loaded. Installing SGX driver..."
    git clone https://github.com/intel/linux-sgx-driver.git
    cd linux-sgx-driver
    make
    sudo mkdir -p "/lib/modules/$(uname -r)/kernel/drivers/intel/sgx"
    sudo cp isgx.ko "/lib/modules/$(uname -r)/kernel/drivers/intel/sgx"
    sudo sh -c 'cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules'
    sudo /sbin/depmod
    sudo /sbin/modprobe isgx
    cd ..
    rm -rf linux-sgx-driver
else
    echo "SGX driver is loaded."
fi

# Add the Intel SGX repository
echo "Adding the Intel SGX repository..."
echo "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/intel-sgx.list >/dev/null
curl -sSL "https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key" | sudo -E apt-key add -

# Update the package list
echo "Updating the package list..."
sudo apt update

# Install the AESM service and related plugins
echo "Installing the AESM service and related plugins..."
sudo apt install -y sgx-aesm-service libsgx-aesm-launch-plugin libsgx-aesm-epid-plugin libsgx-dcap-ql libsgx-quote-ex

# Install the necessary packages for swisstronikd
echo "Installing the necessary packages for swisstronikd..."
sudo apt install -y libsgx-launch libsgx-urts libsgx-epid libsgx-quote-ex libsgx-aesm-launch-plugin libsgx-aesm-epid-plugin libsgx-quote-ex libsgx-dcap-ql libsnappy1v5

# Install additional dependencies for building swisstronikd
echo "Installing additional dependencies for building swisstronikd..."
sudo apt install -y gcc protobuf-compiler pkg-config libssl-dev

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Build and Install sgxs-tools
echo "Building and installing sgxs-tools..."
cargo install sgxs-tools

# Check if the AESM service is active
if systemctl is-active --quiet aesmd.service; then
    echo "SGX PSW is installed."
else
    echo "SGX PSW is not installed."
    exit 1
fi

echo "Intel SGX is supported on this system."

# Display the output of sgx-detect
echo "Running sgx-detect..."
sudo $(which sgx-detect)
