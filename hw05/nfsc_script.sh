#!/bin/bash
sudo yum install nfs-utils -y
sudo systemctl start rpcbind
sudo systemctl enable rpcbind
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo mkdir /mnt/share_storage
sudo mount -o rw,nosuid,noexec,soft,intr,proto=udp,vers=3 192.168.50.10:/mnt/share_storage /mnt/share_storage
echo "192.168.50.10:/mnt/share_storage/ /mnt/share_storage/ nfs rw,noauto,nosuid,noexec,soft,intr,proto=udp,vers=3 0 0" >> /etc/fstab
