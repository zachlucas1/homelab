#!/bin/bash
# full_backup.sh
# does a full backup every day of the minecraft_hardcore server directory
# 0 4 * * *   (daily at 4:00 AM)

set -e

CONTAINER_NAME="minecraft-hardcore"
BACKUP_DIR="/home/zachlucas/games/backups/minecraft/full_backups"
TIMESTAMP=$(date +"%d-%m-%Y")
WORLD_PATH="/home/zachlucas/games/minecraft_hardcore"

echo "--DAILY BACKUP--"

# Pause saving
docker exec "$CONTAINER_NAME" rcon-cli save-off
docker exec "$CONTAINER_NAME" rcon-cli save-all flush
sleep 3

# Create backup
mkdir -p "$BACKUP_DIR"
tar czf "$BACKUP_DIR/$CONTAINER_NAME-$TIMESTAMP.tar.gz" -C "$WORLD_PATH" .

# Resume saving
docker exec "$CONTAINER_NAME" rcon-cli save-on

echo "World backup complete: $CONTAINER_NAME-$TIMESTAMP.tar.gz"

# Delete backups older than 7 days
echo "Deleting backups older than 7 days if they exist"
find "$BACKUP_DIR" -type f -name "$CONTAINER_NAME-*.tar.gz" -mtime +7 -exec rm -f {} \;

echo "Copying to backblaze"
rclone copy $BACKUP_DIR/$CONTAINER_NAME-$TIMESTAMP.tar.gz backblaze:paninilab-gameserver-backup
