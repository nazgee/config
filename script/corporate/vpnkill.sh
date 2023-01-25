sudo -A killall ZSTray
sudo -A systemctl stop zsaservice
sudo -A systemctl stop zstunnel
sudo -A killall ZSTray
ps aux | ack zs
