#!/bin/bash

# Stop the K3s service
sudo systemctl stop k3s 2>/dev/null

# Uninstall K3s using the built-in script
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
  sudo /usr/local/bin/k3s-uninstall.sh
else
  echo "K3s uninstall script not found. Skipping."
fi

# Remove data directories
sudo rm -rf /var/lib/rancher/k3s
sudo rm -rf /etc/rancher/k3s

# Remove binaries
sudo rm /usr/local/bin/k3s 2>/dev/null
sudo rm /usr/local/bin/kubectl 2>/dev/null
sudo rm /usr/local/bin/crictl 2>/dev/null
sudo rm /usr/local/bin/ctr 2>/dev/null

# Remove systemd service files
sudo rm /etc/systemd/system/k3s.service 2>/dev/null
sudo rm /etc/systemd/system/multi-user.target.wants/k3s.service 2>/dev/null
sudo systemctl daemon-reload

# Remove other potential k3s related files
sudo rm -rf /etc/systemd/system/k3s-* 2>/dev/null
sudo rm -rf /etc/cni/net.d/*k3s* 2>/dev/null
sudo rm -rf /etc/containerd
sudo rm -rf /opt/cni/

# Remove k3s user and group
id -u k3s &>/dev/null && sudo userdel k3s
id -g k3s &>/dev/null && sudo groupdel k3s

# Remove network interfaces (use with extreme caution!)
K3S_INTERFACES=$(ip link show | grep -o 'cni0\|flannel\.1\|kube-ipvs0')
if [[ ! -z "$K3S_INTERFACES" ]]; then
    echo "Removing K3s network interfaces: $K3S_INTERFACES"
    for IFACE in $K3S_INTERFACES; do
        sudo ip link del "$IFACE" 2>/dev/null
    done
else
    echo "No K3s network interfaces found."
fi

#Remove iptables rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Remove kubelet configuration if it exists (for compatibility with other distributions)
sudo rm -rf /var/lib/kubelet

# Remove any kube config from the current users home directory
rm -rf ~/.kube

# Optionally reboot (uncomment if desired)
#sudo reboot

echo "K3s removal process completed."