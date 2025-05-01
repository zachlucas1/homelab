#!/bin/bash
# quick-backup.sh
# does a quick backup every 15 minutes of the minecraft_harcore server world directory
# */15 * * * *

set -e

CONTAINER_NAME="minecraft-hardcore"
BACKUP_DIR="/home/zachlucas/games/backups/minecraft/quick_backups"
TIMESTAMP=$(date +"%d-%m-%Y_%H-%M")
WORLD_PATH="/home/zachlucas/games/minecraft_hardcore/world"

echo "--15 MINUTE BACKUP--"

# Pause saving
docker exec "$CONTAINER_NAME" rcon-cli save-off
docker exec "$CONTAINER_NAME" rcon-cli save-all flush
sleep 3

# Create backup
mkdir -p "$BACKUP_DIR"
tar czf "$BACKUP_DIR/minecraft-hardcore-$TIMESTAMP.tar.gz" -C "$WORLD_PATH" .

# Resume saving
docker exec "$CONTAINER_NAME" rcon-cli save-on

echo "World backup complete: world-$TIMESTAMP.tar.gz"

# Delete backups older than 4 hours (240 minutes)
echo "Deleting 4 hour old backups if they exist"
find "$BACKUP_DIR" -type f -name "world-*.tar.gz" -mmin +240 -exec rm -f {} \;
