[Blacknodes VALIDATOR]
=


<h1 align="center">SWISSTRONIK TESTNET guide</h1>

![swisstronik](https://github.com/blacknodes/Node-Services/assets/85839823/c983919e-7adb-4a0a-bcd5-c38216491ef0)

=
[EXPLORER]
(https://explorer.blacknodes.net/Swisstronik-Testnet) \
=

- **Minimum hardware requirements**:

| Node Type |CPU | RAM  | Storage  | 
|-----------|----|------|----------|
| Mainnet   |   8|  32GB | 500GB+ |




# Setup SGX and Swisstronik
This script automates the setup of Intel SGX and Swisstronik on a Linux system. 
It checks for SGX support, installs the SGX driver and AESM service, and sets up necessary dependencies for Swisstronik development.

## Prerequisites
• A Linux system with kernel version 5.11 or higher.  
• BIOS support for SGX (ensure SGX is enabled in BIOS settings).

# Usage
## Download the script:
```
wget https://raw.githubusercontent.com/blacknodes/Node-Services/main/Projects/swisstronik/setup_sgx_swisstronik.sh
```
## Make the script executable:
```
chmod +x setup_sgx_swisstronik.sh
```
## Run the script with root privileges:
```
sudo ./setup_sgx_swisstronik.sh
```
## Troubleshooting
If you encounter any issues with the SGX driver installation, ensure that SGX is enabled in your BIOS settings.


# Installation Guide

### Preparing the server

```python
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## GO 1.21.3
```python
cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```

# Set Desired Moniker of your node
```
echo "export MONIKER="my_name"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Download Binary
```python

cd $HOME
wget https://github.com/SigmaGmbH/swisstronik-chain/releases/download/v1.0.1/swisstronikd.deb.zip
unzip swisstronikd.deb.zip
dpkg -i swisstronik_1.0.1-updated-binaries_amd64.deb 
```

## Obtain master key
```
swisstronikd enclave request-master-key rpc.testnet.swisstronik.com:46789
```
## Init app
```
swisstronikd init $MONIKER --chain-id swisstronik_1291-1
```

## Create/recover wallet
```python
swisstronikd keys add <walletname>
swisstronikd keys add <walletname> --recover
```

## Download Genesis
```python
wget https://github.com/blacknodes/Node-Services/blob/main/Projects/Swisstronik/genesis.json -O $HOME/.swisstronik/config/genesis.json
```


## Set up the minimum gas price and Peers/Seeds/Filter peers/MaxPeers
```python
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0mpx\"/" $HOME/.swisstronik/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.swisstronik/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.swisstronik/config/config.toml
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.swisstronik/config/config.toml
seeds="148cee337f690b973160f5558dcddd88280dc70f@148.113.1.30:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.swisstronik/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.swisstronik/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.swisstronik/config/config.toml
```

### Pruning (optional)
```python
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.swisstronik/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.swisstronik/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.swisstronik/config/app.toml
```


### Indexer (optional) 
```python
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.swisstronik/config/config.toml
```

## Download addrbook
```python
wget -O $HOME/.swisstronik/config/addrbook.json "https://file.blacknodes.net/swisstronik/addrbook.json"
```


# Create a service file
```python
sudo tee /etc/systemd/system/swisstronikd.service > /dev/null <<EOF
[Unit]
Description=Swisstronik
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.swisstronik
ExecStart=$(which swisstronikd) start --home $HOME/.swisstronik
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Start
```python
sudo systemctl daemon-reload
sudo systemctl enable swisstronikd
sudo systemctl restart swisstronikd && sudo journalctl -u swisstronikd -f
```

### Create validator
```python
swisstronikd tx staking create-validator \
--amount 100000000000000000uswtr \
--from <walletname> \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(swisstronikd tendermint show-validator) \
--moniker "my_name" \
--identity "" \
--details "Blacknodes tutorial" \
--chain-id swisstronik_1291-1 \
--gas auto --gas-adjustment 1.4 --gas-prices 10000000000000uswtr \
-y
```

## Delete node
```bash
sudo systemctl stop swisstronikd
sudo systemctl disable swisstronikd
sudo rm -rf /etc/systemd/system/swisstronikd.service
sudo rm $(which swisstronikd)
sudo rm -rf $HOME/.swisstronik
```
#
### Sync Info
```python
swisstronikd status 2>&1 | jq .SyncInfo
```
### Node Info
```python
swisstronikd status 2>&1 | jq .NodeInfo
```
### Check node logs
```python
sudo journalctl -u swisstronikd -f -o cat
```
### Check Balance
```python
swisstronikd query bank balances $WALLET
```
