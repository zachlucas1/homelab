#!/bin/bash
# quick-backup.sh
# does a quick backup every 15 minutes of the minecraft_hardcore server world directory
# */15 * * * *

set -e

CONTAINER_NAME="minecraft-hardcore-fabric"
BACKUP_DIR="/home/zachlucas/games/backups/minecraft/quick_backups"
TIMESTAMP=$(date +"%m-%d-%Y_%H-%M")
WORLD_PATH="/home/zachlucas/games/minecraft_hardcore/world"
LOG_FILE="minecraft-backup.log"
USAGE_THRESHOLD=90  # %

# Check disk usage
USAGE=$(df "$BACKUP_DIR" | awk 'NR==2 {gsub("%", ""); print $5}')
if [ "$USAGE" -ge "$USAGE_THRESHOLD" ]; then
    echo "[$(date)] Skipping backup — disk usage is at ${USAGE}% (threshold is ${USAGE_THRESHOLD}%)" | tee -a "$LOG_FILE"

    #exits if disk usage is too high
    exit 1
fi

echo "--15 MINUTE BACKUP--"

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

# Delete backups older than 4 hours (240 minutes)
echo "Deleting 4 hour old backups if they exist"
find "$BACKUP_DIR" -type f -name "$CONTAINER_NAME-*.tar.gz" -mmin +240 -exec rm -f {} \;
