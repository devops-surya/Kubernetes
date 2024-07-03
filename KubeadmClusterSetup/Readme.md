* This folder consists of Kubeadm Cluster Setup documentation 
* Cluster.sh is the bash file which you can use for doing below taskss :
  1. Install pre-requesites and implement on all the master & Worker nodes
  2. Install containerd on all Master & Worker nodes. Setup sytemd cgroupdrivers as well along with CNI plugin install.
  3. Install kubeadm, , Kubelet, Kubectl on all the Master & Worker nodes
* Copy the cluster.sh script to your servers and use the script with below command:
```
sudo /bin/bash cluster.sh
```
