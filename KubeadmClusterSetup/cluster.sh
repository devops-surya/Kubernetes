#!/bin/bash
# This script will prform below steps:
# 1. Install pre-requesites and implement on all the master & Worker nodes
# 2. Install containerd on all Master & Worker nodes. Setup sytemd cgroupdrivers as well
# 3. Install kubeadm, , Kubelet, Kubectl on all the Master & Worker nodes


LOGFILE="/var/log/script.log"

# Function to log error and exit
function error_exit {
    echo "Error: $1"
    echo "Error: $1" >> "$LOGFILE"
    exit 1
}

# Redirect stdout and stderr to log file
exec > >(tee -a "$LOGFILE") 2>&1

# 1. Create k8s.conf file
echo "Creating k8s.conf file"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf || error_exit "Failed to create k8s.conf"
net.ipv4.ip_forward = 1
EOF

# 2. Apply sysctl settings
echo "Applying sysctl settings"
sudo sysctl --system || error_exit "Failed to apply sysctl settings"

# 3. Verify ip_forward setting
echo "Verifying net.ipv4.ip_forward setting"
sysctl net.ipv4.ip_forward || error_exit "Failed to verify net.ipv4.ip_forward setting"

# 4. Update package list
echo "Updating package list"
sudo apt-get update -y || error_exit "Failed to update package list"

# 5. Install required packages
echo "Installing ca-certificates, curl, gnupg"
sudo apt-get install ca-certificates curl gnupg -y || error_exit "Failed to install ca-certificates, curl, gnupg"

# 6. Create keyrings directory
echo "Creating keyrings directory"
sudo install -m 0755 -d /etc/apt/keyrings || error_exit "Failed to create keyrings directory"

# 7. Add Docker GPG key
echo "Adding Docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || error_exit "Failed to add Docker GPG key"
sudo chmod a+r /etc/apt/keyrings/docker.gpg || error_exit "Failed to set permissions for Docker GPG key"

# 8. Add Docker repository
echo "Adding Docker repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error_exit "Failed to add Docker repository"

# 9. Update package list again
echo "Updating package list again"
sudo apt-get update -y || error_exit "Failed to update package list"

# 10. Install containerd
echo "Installing containerd"
sudo apt-get install containerd.io -y || error_exit "Failed to install containerd"

# 11. Generate containerd config
echo "Generating containerd config"
containerd config default | sudo tee /etc/containerd/config.toml || error_exit "Failed to generate containerd config"

# 12. Update containerd config
echo "Updating containerd config"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml || error_exit "Failed to update containerd config"

# 13. Restart containerd
echo "Restarting containerd"
sudo systemctl restart containerd || error_exit "Failed to restart containerd"

# 14. Download CNI plugins
echo "Downloading CNI plugins"
sudo wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz || error_exit "Failed to download CNI plugins"

# 15. Create CNI bin directory
echo "Creating CNI bin directory"
sudo mkdir -p /opt/cni/bin || error_exit "Failed to create CNI bin directory"

# 16. Extract CNI plugins
echo "Extracting CNI plugins"
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz || error_exit "Failed to extract CNI plugins"

# 17. Update package list again
echo "Updating package list again"
sudo apt-get update -y || error_exit "Failed to update package list"

# 18. Install Kubernetes packages
echo "Installing apt-transport-https, ca-certificates, curl, gpg"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg || error_exit "Failed to install apt-transport-https, ca-certificates, curl, gpg"

# 19. Add Kubernetes GPG key
echo "Adding Kubernetes GPG key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg || error_exit "Failed to add Kubernetes GPG key"

# 20. Add Kubernetes repository
echo "Adding Kubernetes repository"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null || error_exit "Failed to add Kubernetes repository"

# 21. Update package list again
echo "Updating package list again"
sudo apt-get update -y || error_exit "Failed to update package list"

# 22. Install Kubernetes components
echo "Installing kubelet, kubeadm, kubectl"
sudo apt-get install -y kubelet kubeadm kubectl || error_exit "Failed to install kubelet, kubeadm, kubectl"

# 23. Hold Kubernetes packages
echo "Holding kubelet, kubeadm, kubectl"
sudo apt-mark hold kubelet kubeadm kubectl || error_exit "Failed to hold kubelet, kubeadm, kubectl"

# 24. Enable kubelet service
echo "Enabling kubelet service"
sudo systemctl enable --now kubelet || error_exit "Failed to enable kubelet service"

# 25. Restart and check status of kubelet
echo "Restarting kubelet and checking status"
sudo systemctl restart kubelet || error_exit "Failed to restart kubelet"
sudo systemctl status kubelet || error_exit "Failed to get kubelet status"

# 26. Restart and check status of containerd
echo "Restarting containerd and checking status"
sudo systemctl restart containerd || error_exit "Failed to restart containerd"
sudo systemctl status containerd || error_exit "Failed to get containerd status"

echo "Script completed successfully."
