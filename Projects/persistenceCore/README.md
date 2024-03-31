[Blacknodes VALIDATOR]
=

<h1 align="center">PersistenceCore MAINNET guide</h1>



=
[EXPLORER]
(https://explorer.blacknodes.net/PersistenceCore) \
=

- **Minimum hardware requirements**:

| Node Type |CPU | RAM  | Storage  | 
|-----------|----|------|----------|
| Mainnet   |   8|  32GB | 500GB-2TB |



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

# Download Binary and init app
```
git clone https://github.com/persistenceOne/persistenceCore persistence
cd persistence
git checkout v11.8.1
make install
rm /root/.persistenceCore/config/genesis.json
persistenceCore init $MONIKER --chain-id core-1
```


## Create/recover wallet
```python
persistenceCore keys add <walletname>
persistenceCore keys add <walletname> --recover
```

## Download Genesis
```python
wget https://github.com/blacknodes/Node-Services/blob/main/Projects/PersistenceCore/genesis.json -O $HOME/.persistenceCore/config/genesis.json
```


## Set up the minimum gas price and Peers/Seeds/Filter peers/MaxPeers
```python
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uxprt\"/" $HOME/.persistenceCore/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.persistenceCore/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.persistenceCore/config/config.toml
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.persistenceCore/config/config.toml
seeds="d50c57ea30eb276879764eca50d67e4ac0258205@191.96.101.2:26656,91d4802dfc07466e481d51a63150462125cf1800@65.108.122.246:26696,e652da08b29ffd4410c2ec12aa576f4dd51a1edd@45.136.30.227:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.persistenceCore/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.persistenceCore/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.persistenceCore/config/config.toml
```

### Pruning (optional)
```python
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.persistenceCore/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.persistenceCore/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.persistenceCore/config/app.toml
```


### Indexer (optional) 
```python
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.persistenceCore/config/config.toml
```

## Download addrbook
```python
wget -O $HOME/.persistenceCore/config/addrbook.json "https://files.blacknodes.net/persistenceCore/addrbook.json"
```


# Create a service file
```python
sudo tee /etc/systemd/system/persistenceCore.service > /dev/null <<EOF
[Unit]
Description=PersistenceCore
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.persistenceCore
ExecStart=$(which persistenceCore) start --home $HOME/.persistenceCore
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
sudo systemctl enable persistenceCore
sudo systemctl restart persistenceCore && sudo journalctl -u persistenceCore -f
```

### Create validator
```python
persistenceCore tx staking create-validator \
--amount 1000000uxprt \
--from <walletname> \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(persistenceCore tendermint show-validator) \
--moniker "my_name" \
--identity "" \
--details "Blacknodes tutorial" \
--chain-id core-1 \
--gas auto --gas-adjustment 1.4 --gas-prices 10uxprt \
-y
```

## Delete node
```bash
sudo systemctl stop persistenceCore
sudo systemctl disable persistenceCore
sudo rm -rf /etc/systemd/system/persistenceCore.service
sudo rm $(which persistenceCore)
sudo rm -rf $HOME/.persistenceCore

```
#
### Sync Info
```python
persistenceCore status 2>&1 | jq .SyncInfo
```
### Node Info
```python
persistenceCore status 2>&1 | jq .NodeInfo
```
### Check node logs
```python
sudo journalctl -u persistenceCore -f -o cat
```
### Check Balance
```python
persistenceCore query bank balances $WALLET
```
