# Download the install-monitoring-tools.sh script
```
wget https://raw.githubusercontent.com/blacknodes/Node-Services/main/Projects/swisstronik/Swisstronik-Node-Monitoring/install-monitoring-tools.sh
```
# Give Execution Permission to the script 
```
sudo chmod +x install-monitoring-tools.sh
```

# Run the script 
```
./install-monitoring-tools.sh
```

# Add Job "Swisstronik-Node" in prometheus file 
```
sed -i '/scrape_configs:/a \
  - job_name: "Swisstronik-Node"\
    static_configs:\
      - targets: ["localhost:26660"]' /opt/prometheus/prometheus.yml
```
# Set prometheus to true in config.toml file 
![image](https://github.com/blacknodes/Node-Services/assets/85839823/78fc8d75-9841-45c5-bdc9-89852e8fcca4)

# Restart your node and prometheus server
```
sudo systemctl restart swisstronikd.service
sudo systemctl restart prometheus.service
```


# Open ports 8091 and 3000 (prometheus default port is 9090 but we are using 8091 here because 9090 is used for grpc-server) 
```
sudo ufw allow 22
sudo ufw allow 8091
sudo ufw allow 3000
sudo ufw enable
```

# Go to Grafana http://yourip:3000
## Add New DataSource Prometheus
![Screenshot 2024-03-12 010046](https://github.com/blacknodes/Node-Services/assets/85839823/c0d0a9f0-a707-4bbc-b08b-0886a996ddfc)

# Import our Dashboard using Import via panel json (Optional)
https://raw.githubusercontent.com/blacknodes/Node-Services/main/Projects/swisstronik/Swisstronik-Node-Monitoring/SwisstronikDashboardByBlackNodes.json

# Set Alert 
## Use this metric for alert 
```
increase(tendermint_consensus_validator_last_signed_height[30m])
```
## Set Threshold (is below 100) and change type from range to instant
![Screenshot 2024-03-12 013505](https://github.com/blacknodes/Node-Services/assets/85839823/ebbcddfc-634b-4ff8-994f-16ad47e882a5)

# Add Notification Channel (Here we will use telegram )
## Use https://t.me/BotFather to create your notification bot and https://t.me/userinfobot to check your telegram id
## Add new Contact point, paste your bot api token and telegram id there
![image](https://github.com/blacknodes/Node-Services/assets/85839823/a8d66cdd-c497-4ffd-814e-f030faff848b)

# Now you'll receive an alert in your telegram bot whenever your node will be inactive!
