#!/bin/bash
set -e

echo -e "\e[32m[task 1]\e[0m modifica file host"
echo 172.16.16.100 kmaster kmaster.example.com | sudo tee -a /etc/hosts
echo 172.16.16.101 kworker1 kworker1.example.com | sudo tee -a /etc/hosts
echo 172.16.16.102 kworker2 kworker2.example.com | sudo tee -a /etc/hosts

echo -e "\e[32m[task 2]\e[0m disabilitare selinux"
sudo setenforce 0
sudo sed -i 's/SELINUX=permissive\|SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo -e "\e[32m[task 3]\e[0m disabilitare firewalld"
sudo systemctl disable firewalld --now
sudo systemctl stop firewalld

echo -e "\e[32m[task 4]\e[0m disabilitare swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo -e "\e[32m[task 5]\e[0m networking kubernetes"
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
EOF
sudo sysctl --system

echo -e "\e[32m[task 6]\e[0m Setup proxy and repos for yum"
cat <<EOF | sudo tee -a /etc/yum.conf
proxy=http://proxymis.mbdom.mbgroup.ad:8080/
proxy_username=a273182
proxy_password=ErRoMaAl1997!4
EOF
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo -e "\e[32m[task 7]\e[0m Docker installation"
sudo yum check-update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl start docker
sudo systemctl enable docker --now
sudo chmod 666 /var/run/docker.sock

echo -e "\e[32m[task 8]\e[0m kubernetes installation"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl kubeadm kubelet
sudo systemctl enable --now kubelet

echo -e "\e[32m[task 9]\e[0m delete config file containerd"
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd

echo -e "\e[32m[task 10]\e[0m install Helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
