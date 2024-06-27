
# Setup NFS Server and Client for Kubernetes

This repository contains scripts and configuration files to set up NFS (Network File System) on a Kubernetes cluster. The setup includes provisioning an NFS server and configuring NFS clients.

## Files

- `setup_nfs.sh`: Bash script to set up NFS server or client depending on the hostname.
- `01-setup-nfs-provisioner.yaml`: Kubernetes manifest to set up the NFS provisioner.
- `02-test-claim.yaml`: Kubernetes manifest to test a PersistentVolumeClaim using the NFS provisioner.

## Prerequisites

- Ubuntu-based systems
- Kubernetes cluster with at least one master node and one worker node
- Sudo privileges

## Setup Instructions

### 1. Configure NFS Server and Clients

Run the `setup_nfs.sh` script on each node in your Kubernetes cluster. The script will check the hostname to determine whether to set up the NFS server or client.

```bash
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
```

#### Explanation

- The script updates the package list using `apt-get update`.
- It checks if the hostname of the node is `cplane`.
  - If true, it sets up the NFS server:
    - Installs `nfs-kernel-server`.
    - Creates the NFS export directory and sets the appropriate permissions.
    - Configures the NFS export.
    - Restarts the NFS server.
  - If false, it sets up the NFS client:
    - Installs `nfs-common`.

To change the hostname condition, replace `cplane` with the hostname of your master node. The script can be modified to use a different hostname check or to use `/etc/hosts` for validation.

### 2. Deploy NFS Provisioner in Kubernetes

Apply the `01-setup-nfs-provisioner.yaml` manifest to set up the NFS provisioner in your Kubernetes cluster.

```bash
kubectl apply -f 01-setup-nfs-provisioner.yaml
```

### 3. Test PersistentVolumeClaim

Apply the `02-test-claim.yaml` manifest to test the NFS provisioner by creating a PersistentVolumeClaim.

```bash
kubectl apply -f 02-test-claim.yaml
```

### 4. Verify

Check the status of the PersistentVolumeClaim to ensure it has been bound successfully.

```bash
kubectl get pvc
```

## Conclusion

This setup configures an NFS server and client for a Kubernetes cluster and deploys an NFS provisioner for dynamic volume provisioning. Follow the instructions carefully to set up and test the NFS integration in your cluster.

For further information and customization, please refer to the individual script and manifest files.
