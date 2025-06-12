#!/bin/bash
# daily_backup.sh
# Creates and uploads a daily backup of the Minecraft server, then deletes it locally

set -e

CONTAINER_NAME="minecraft-server"
TEMP_COPY="/tmp/minecraft_server"
WORLD_PATH="/home/opc/minecraft_server"
ARCHIVE_PATH="/tmp/$CONTAINER_NAME-latest.tar.gz"
REMOTE_PATH="gracie-b2:gracie-minecraft-backup"

echo "--DAILY BACKUP--"

# Pause saving
docker exec "$CONTAINER_NAME" rcon-cli save-off
docker exec "$CONTAINER_NAME" rcon-cli save-all flush
sleep 3

# Copy world data
rm -rf "$TEMP_COPY"
cp -r "$WORLD_PATH" "$TEMP_COPY"

# Resume saving
docker exec "$CONTAINER_NAME" rcon-cli save-on

# Create compressed archive in /tmp
tar czf "$ARCHIVE_PATH" -C "$TEMP_COPY" .

# Clean up temp copy
rm -rf "$TEMP_COPY"

# Upload to Backblaze
echo "Uploading to Backblaze..."
rclone copy "$ARCHIVE_PATH" "$REMOTE_PATH"

# Remove local archive
rm -f "$ARCHIVE_PATH"

echo "--BACKUP COMPLETE--"
