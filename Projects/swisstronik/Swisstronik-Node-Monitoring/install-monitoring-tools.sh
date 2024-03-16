#!/bin/bash

# Install Prometheus
echo "Downloading Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v2.33.1/prometheus-2.33.1.linux-amd64.tar.gz

echo "Extracting Prometheus..."
tar xvfz prometheus-2.33.1.linux-amd64.tar.gz -C /opt

echo "Moving Prometheus to the final destination..."
mv /opt/prometheus-* /opt/prometheus

echo "Creating prometheus user..."
useradd --no-create-home --shell /bin/false prometheus

echo "Setting permissions for Prometheus..."
chown -R prometheus:prometheus /opt/prometheus

echo "Creating Prometheus systemd service..."
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \\
    --config.file=/opt/prometheus/prometheus.yml \\
    --storage.tsdb.path=/opt/prometheus/data \\
    --web.listen-address=:8091

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd, starting and enabling Prometheus..."
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

# Install Grafana
echo "Downloading Grafana..."
wget https://dl.grafana.com/oss/release/grafana_9.5.0_amd64.deb

echo "Installing Grafana..."
dpkg -i grafana_9.5.0_amd64.deb

echo "Starting and enabling Grafana..."
systemctl start grafana-server
systemctl enable grafana-server

echo "Grafana and Prometheus installation completed."
