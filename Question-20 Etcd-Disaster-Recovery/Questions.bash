#!/bin/bash
echo "-----------------------------------------------------------------------"
echo "TASK: ETCD DISASTER RECOVERY"
echo "1. Take a snapshot of etcd at https://127.0.0.1:2379"
echo "2. Save the backup to: /opt/etcd-backup.db"
echo "3. Restore the snapshot to a new data directory: /var/lib/etcd-new"
echo "4. Update the etcd static pod manifest to use the new directory."
echo "-----------------------------------------------------------------------"
