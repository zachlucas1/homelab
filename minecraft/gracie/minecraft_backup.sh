#!/bin/bash

# Set date and filename
FILENAME="gracie_minecraft_backup.zip"
BACKUP_DIR="/home/opc"

#cd to minecraft directory
cd $BACKUP_DIR

#stop minecraft server
sudo systemctl stop minecraft.service

#wait 15 seconds
sleep 15

#compress files into .zip
zip -r "$FILENAME" *

#backup file
rclone copy $FILENAME gracie-b2:gracie-minecraft-backup

#remove backup file
rm $FILENAME

#stop minecraft server
sudo systemctl start minecraft.service