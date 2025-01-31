#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

readonly NFS_SHARE="/srv/nfs/kubedata"

echo "[TASK 1] apt update"
sudo apt-get update -qq >/dev/null

if [[ $HOSTNAME == "cplane" ]]; then
  echo "[TASK 2] install nfs server"
  sudo -E apt-get install -y -qq nfs-kernel-server >/dev/null
  echo "[TASK 3] creating nfs exports"
  sudo mkdir -p $NFS_SHARE
  sudo chown nobody:nogroup $NFS_SHARE
  echo "$NFS_SHARE *(rw,sync,no_subtree_check)" | sudo tee /etc/exports >/dev/null
  sudo systemctl restart nfs-kernel-server
else
  echo "[TASK 2] install nfs common"
  sudo -E apt-get install -y -qq nfs-common >/dev/null
fi
