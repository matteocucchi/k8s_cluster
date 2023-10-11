#!/bin/bash
set -e

echo "[task 1] creazione token per addare worker"
kubeadm token create --print-join-command

echo "[task 2] flannel"
kubectl apply -f https://raw.githubusercontent.com/matteocucchi/config-files/main/kube-flannel.yml

echo "[task 3] Export ~/.kube/config for OpenLens"
cat $HOME/.kube/config
