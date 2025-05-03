#!/bin/bash
# full_backup.sh
# does a full backup every day of the minecraft_hardcore server directory
# 0 4 * * *   (daily at 4:00 AM)

set -e

CONTAINER_NAME="minecraft-hardcore-fabric"
BACKUP_DIR="/home/zachlucas/games/backups/minecraft/full_backups"
TEMP_COPY="/tmp/minecraft_hardcore_backup"
TIMESTAMP=$(date +"%m-%d-%Y")
WORLD_PATH="/home/zachlucas/games/minecraft_hardcore"

echo "--DAILY BACKUP--"

# Pause saving
docker exec "$CONTAINER_NAME" rcon-cli save-off
docker exec "$CONTAINER_NAME" rcon-cli save-all flush
sleep 3

# Prepare backup
rm -rf "$TEMP_COPY"
cp -r "$WORLD_PATH" "$TEMP_COPY"

# Resume saving ASAP
docker exec "$CONTAINER_NAME" rcon-cli save-on

# Create archive
mkdir -p "$BACKUP_DIR"
tar czf "$BACKUP_DIR/$CONTAINER_NAME-$TIMESTAMP.tar.gz" -C "$TEMP_COPY" .

# Cleanup temp copy
rm -rf "$TEMP_COPY"

# Delete backups older than 7 days
echo "Deleting backups older than 7 days if they exist"
find "$BACKUP_DIR" -type f -name "$CONTAINER_NAME-*.tar.gz" -mtime +7 -exec rm -f {} \;

# Sync to Backblaze
echo "Copying to backblaze"
rclone copy "$BACKUP_DIR/$CONTAINER_NAME-$TIMESTAMP.tar.gz" backblaze:paninilab-gameserver-backup
