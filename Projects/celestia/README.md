[Blacknodes VALIDATOR]
=

<h1 align="center">CELESTIA TESTNET guide</h1>


=
[EXPLORER]
(https://explorer.blacknodes.net/Celestia-Testnet) \
=

- **Minimum hardware requirements**:

| Node Type |CPU | RAM  | Storage  | 
|-----------|----|------|----------|
| Testnet   |   6|  16GB | 100GB+ |



# Installation Guide

### Preparing the server

```python
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## GO 1.22.1
```python
cd $HOME
VER="1.22.1"
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

# Download Binary and init app
```python
git clone https://github.com/celestiaorg/celestia-app.git 
cd celestia-app/ 
APP_VERSION=v1.7.0
git checkout tags/$APP_VERSION -b $APP_VERSION 
make install
celestia-appd init "$MONIKER" --chain-id mocha-4
```


## Create/recover wallet
```python
celestia-appd keys add <walletname>
celestia-appd keys add <walletname> --recover
```

## Download Genesis
```python
wget https://github.com/blacknodes/Node-Services/blob/main/Projects/celestia/genesis.json -O $HOME/.celestia-app/config/genesis.json
```


## Set up the minimum gas price and Peers/Seeds/Filter peers/MaxPeers
```python
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utia\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.celestia-app/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.celestia-app/config/config.toml
peers="af73ecc4d2084643fe77657d260a07240872d91f@celestia-testnet.blacknodes.net:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.celestia-app/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.celestia-app/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.celestia-app/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.celestia-app/config/config.toml
```

### Pruning (optional)
```python
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.celestia-app/config/app.toml
```


### Indexer (optional) 
```python
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.celestia-app/config/config.toml
```

## Download addrbook
```python
wget -O $HOME/.celestia-app/config/addrbook.json "https://files.blacknodes.net/crossfi/addrbook.json"
```


# Create a service file
```python
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=Celestia
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.celestia-app
ExecStart=$(which celestia-appd) start --home $HOME/.celestia-app
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
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd && sudo journalctl -u celestia-appd -f
```

### Create validator
```python
celestia-appd tx staking create-validator \
--amount 1000000utia \
--from <walletname> \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(celestia-appd tendermint show-validator) \
--moniker "my_name" \
--identity "" \
--details "Blacknodes tutorial" \
--chain-id mocha-4 \
--gas auto --gas-adjustment 1.4 --gas-prices 0.005utia \
--node https://celestia-testnet-rpc.blacknodes.net:443 \
-y
```

## Delete node
```bash
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
sudo rm -rf /etc/systemd/system/celestia-appd.service
sudo rm $(which celestia-appd)
sudo rm -rf $HOME/.celestia-app
```
#
### Sync Info
```python
celestia-appd status 2>&1 | jq .SyncInfo
```
### Node Info
```python
celestia-appd status 2>&1 | jq .NodeInfo
```
### Check node logs
```python
sudo journalctl -u celestia-appd -f -o cat
```
### Check Balance
```python
celestia-appd query bank balances $WALLET
```
