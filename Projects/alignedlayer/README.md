[Blacknodes VALIDATOR]
=

<h1 align="center">Alignedlayer TESTNET guide</h1>



=
[EXPLORER]
(https://explorer.blacknodes.net/AlignedLayer-Testnet) \
=

- **Minimum hardware requirements**:

| Node Type |CPU | RAM  | Storage  | 
|-----------|----|------|----------|
| Testnet   |   4|  16GB | 160GB+ |



# Installation Guide

### Preparing the server

```python
sudo apt update && sudo apt upgrade -y
sudo apt-get update && sudo apt-get install -y jq moreutils make gcc && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && curl -sSf https://get.ignite.com/cli | sh
source $HOME/.cargo/env

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
```
git clone https://github.com/yetanotherco/aligned_layer_tendermint/
bash setup_node.sh $MONIKER
chmod +x $HOME/go/bin/alignedlayerd
```


## Create/recover wallet
```
alignedlayerd keys add <walletname>
alignedlayerd keys add <walletname> --recover
```

## Set up the minimum gas price and Peers/Seeds/Filter peers/MaxPeers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001stake\"/" $HOME/.alignedlayer/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.alignedlayer/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.alignedlayer/config/config.toml
peers="9f7c7a0acd6aa8e2d6b77ddad506fb1c6b9edc5f@37.27.20.41:26656,dc2011a64fc5f888a3e575f84ecb680194307b56@148.251.235.130:20656,a1a98d9caf27c3363fab07a8e57ee0927d8c7eec@128.140.3.188:26656,1beca410dba8907a61552554b242b4200788201c@91.107.239.79:26656,f9000461b5f535f0c13a543898cc7ac1cd10f945@88.99.174.203:26656, 32fbefec592ac2ff9ecb3cad69bafaaad01e771a@148.251.235.130:20656,81138177a67195791bbe782fe1ed49f25e582bac@91.107.239.79:26656,c5d0498e345725365c1016795eecff4a67e4c4c9@88.99.174.203:26656,14af04afc663427604e8dd53f4023f7963a255cb@116.203.81.174:26656,9c89e77d51561c8b23957eee85a81ccc99fa7d6b@128.140.3.188:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.alignedlayer/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.alignedlayer/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.alignedlayer/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.alignedlayer/config/config.toml
```

### Pruning (optional)
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.alignedlayer/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.alignedlayer/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.alignedlayer/config/app.toml
```


### Indexer (optional) 
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.alignedlayer/config/config.toml
```

## Download addrbook
```
wget -O $HOME/.alignedlayer/config/addrbook.json "https://files.blacknodes.net/alignedlayer/addrbook.json"
```
## Use Our Snapshot
```
wget https://files.blacknodes.net/alignedlayer/alignedlayer.tar --no-check-certificate
tar -xvf alignedlayer.tar -C ~/.alignedlayer/data/
```

# Create a service file
```
sudo tee /etc/systemd/system/alignedlayerd.service > /dev/null <<EOF
[Unit]
Description=Alignedlayer
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.alignedlayer
ExecStart=$(which alignedlayerd) start --home $HOME/.alignedlayer
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Start
```
sudo systemctl daemon-reload
sudo systemctl enable alignedlayerd
sudo systemctl restart alignedlayerd && sudo journalctl -u alignedlayerd -f
```

### Create validator
```
alignedlayerd tx staking create-validator \
--amount 1000000stake \
--from <walletname> \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(alignedlayerd tendermint show-validator) \
--moniker "my_name" \
--identity "" \
--details "Blacknodes tutorial" \
--chain-id alignedlayer-evm-testnet-1 \
--gas auto --gas-adjustment 1.4 --gas-prices 9stake \
-y
```

## Delete node
```bash
sudo systemctl stop alignedlayerd
sudo systemctl disable alignedlayerd
sudo rm -rf /etc/systemd/system/alignedlayerd.service
sudo rm $(which alignedlayerd)
sudo rm -rf $HOME/.alignedlayer
```
#
### Sync Info
```python
alignedlayerd status 2>&1 | jq .SyncInfo
```
### Node Info
```python
alignedlayerd status 2>&1 | jq .NodeInfo
```
### Check node logs
```python
sudo journalctl -u alignedlayerd -f -o cat
```
### Check Balance
```python
alignedlayerd query bank balances $WALLET
```

