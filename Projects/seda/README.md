[Blacknodes VALIDATOR]
=

<h1 align="center">Seda TESTNET guide</h1>






=
[EXPLORER]
(https://explorer.blacknodes.net/Seda-Testnet) \
=

- **Minimum hardware requirements**:

| Node Type |CPU | RAM  | Storage  | 
|-----------|----|------|----------|
| Testnet   |   4|  32GB | 1TB SSD |



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
git clone https://github.com/sedaprotocol/seda-chain sedatestnet
cd sedatestnet
git checkout v0.0.7
make install
sedad init $MONIKER --chain-id=seda-1-testnet
```


## Create/recover wallet
```
sedad keys add <walletname>
sedad keys add <walletname> --recover
```

## Set up the minimum gas price and Peers/Seeds/Filter peers/MaxPeers
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001aseda\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.sedad/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.sedad/config/config.toml
peers="7c5422dec97aafabb2e1163b0ba50a11ca199635@seda-testnet.blacknodes.net:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sedad/config/config.toml
seeds="82a5a3900d99d2e9e57343e900576e770cd78d5f@109.199.127.16:25856,0b622f1de6d8af71403e22a86220ec6a55ce2e41@80.79.6.202:56656,8c26be673af6909fc420cbea7790c0725967c2e4@142.132.154.53:25856,717cca5588c7a1c2ce0a4a5f2e04de91679f06ff@195.14.6.2:26656,cb75c263cff51a14a4f10694046bb81414d10064@18.171.36.35:26656,b6a3ec749d60475328ec13fd72e5515da6139a00@65.21.196.187:18656,c9c0a287696e7fd066d8d156d5693ea7e7416221@185.84.224.125:25856,2980a689845a09bc6a03a9fd48810bd20fc3c767@49.12.168.108:2000,598ed4621919c9a341403235a035e5a3a6208a03@185.182.194.239:26656,510060581212de0892703dd1c2f894baefb13a32@65.21.88.86:26656,8cfdbb242658a42a108b64bbdff73216df9a8e7d@51.195.61.9:25856,6f17331cc623c92fb2fd6b0d678326c3a3dc0a50@65.108.39.147:25856,0660466dfd31d874116cd66ca24f284e9e2b4e62@65.21.32.200:44656,50d00c212df119eb19ab976b40cf3cd149ad50ab@185.183.35.185:26656,a6a6f924bf8a88e2d2d6ace0031e6844951712a9@93.189.30.113:26656,945710d8ab3b3c5e4f9474254213bccf09551878@91.223.3.190:56176,e6df92e2b1d7a1834be434a600ab3e40bf6be5dc@135.181.246.250:3420,7c5422dec97aafabb2e1163b0ba50a11ca199635@65.21.28.22:26656,9fea602250622eaf3c3bcde89db561deb7fa54b3@104.244.208.246:25856,c13a5b542acb9af74c866f512eb0b6c88add8134@176.9.0.179:26656,ff5eed4fd8dd12d10c4bb4a17058f167aa02b41e@185.163.117.100:26656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:17356"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sedad/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.sedad/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.sedad/config/config.toml
```

### Pruning (optional)
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.sedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.sedad/config/app.toml
```


### Indexer (optional) 
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sedad/config/config.toml
```
## Download Genesis
```python
wget https://github.com/blacknodes/Node-Services/blob/main/Projects/seda/genesis.json -O $HOME/.sedad/config/genesis.json
```

## Download addrbook
```
wget -O $HOME/.sedad/config/addrbook.json "https://files.blacknodes.net/seda/addrbook.json"
```
## Use Our Snapshot
```
wget https://files.blacknodes.net/seda/seda-1-testnet.tar
tar -xvf seda.tar -C ~/.sedad/data/
```

# Create a service file
```
sudo tee /etc/systemd/system/sedad.service > /dev/null <<EOF
[Unit]
Description=Seda
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.sedad
ExecStart=$(which sedad) start --home $HOME/.sedad
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
sudo systemctl enable sedad
sudo systemctl restart sedad && sudo journalctl -u sedad -f
```

### Create validator
Check your pubkey with
```
echo $(sedad tendermint show-validator)
```
Create a validator.json file and fill in the create-validator tx parameters:
```
{
 "pubkey": <paste your pubkey>,
 "amount": "900000000000000000000aseda", 
 "moniker": "<your desired moniker>",
 "identity": "your keybase id",
 "website": "your website",
 "security": "your contact",
 "details": "BlackNodes Tutorial",
 "commission-rate": "0.1",
 "commission-max-rate": "0.2",
 "commission-max-change-rate": "0.01",
 "min-self-delegation": "1" 
}
```

Run this command to create validator
```
sedad tx staking create-validator validator.json --from <your wallet name> --chain-id seda-1-testnet --gas auto --gas-adjustment 1.5 --gas-prices 10000000000aseda
```

## Delete node
```bash
sudo systemctl stop sedad
sudo systemctl disable sedad
sudo rm -rf /etc/systemd/system/sedad.service
sudo rm $(which sedad)
sudo rm -rf $HOME/.sedad
```
#
### Sync Info
```python
sedad status 2>&1 | jq .SyncInfo
```
### Node Info
```python
sedad status 2>&1 | jq .NodeInfo
```
### Check node logs
```python
sudo journalctl -u sedad -f -o cat
```
### Check Balance
```python
sedad query bank balances $WALLET
```


