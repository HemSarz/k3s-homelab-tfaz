#!/bin/bash

# Stop the K3s service
sudo systemctl stop k3s

# Uninstall K3s using the built-in script
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
  sudo /usr/local/bin/k3s-uninstall.sh
else
  echo "K3s uninstall script not found. Skipping."
fi

# Remove data directories
sudo rm -rf /var/lib/rancher/k3s
sudo rm -rf /etc/rancher/k3s

# Remove binaries (double-check after uninstall)
sudo rm /usr/local/bin/k3s 2>/dev/null # Suppress "No such file or directory" errors
sudo rm /usr/local/bin/kubectl 2>/dev/null
sudo rm /usr/local/bin/crictl 2>/dev/null
sudo rm /usr/local/bin/ctr 2>/dev/null

# Remove systemd service file
sudo rm /etc/systemd/system/k3s.service 2>/dev/null
sudo rm /etc/systemd/system/multi-user.target.wants/k3s.service 2>/dev/null
sudo systemctl daemon-reload

# Attempt to remove any remaining K3s related directories in /etc
sudo rm -rf /etc/systemd/system/k3s-* 2>/dev/null
sudo rm -rf /etc/cni/net.d/*k3s* 2>/dev/null

#Remove containerd configuration
sudo rm -rf /etc/containerd

#Remove cni plugins
sudo rm -rf /opt/cni/

# Optionally remove the k3s user and group (if you created them specifically for k3s)
id -u k3s &>/dev/null && sudo userdel k3s
id -g k3s &>/dev/null && sudo groupdel k3s

# Clean up any leftover network interfaces (use with caution!)
ip link show | grep k3s | awk '{print $2}' | xargs -I {} sudo ip link del {}

# Optionally reboot (uncomment if desired)
# sudo reboot

echo "K3s removal complete."