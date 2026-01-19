#!/bin/bash

# Deploy script for mypistats
# Pushes the stats page to the Raspberry Pi

SERVER="framboise"
USER="pi"
REMOTE_DIR="/home/pi/mypistats"

echo "Deploying to $SERVER..."

# Create remote directory if it doesn't exist
ssh "$USER@$SERVER" "mkdir -p $REMOTE_DIR"

# Copy files
scp index.html "$USER@$SERVER:$REMOTE_DIR/"

if [ $? -eq 0 ]; then
    echo "Deploy successful!"
    echo "Files deployed to $USER@$SERVER:$REMOTE_DIR"
    echo ""
    echo "To view, run on the Pi:"
    echo "  chromium-browser --kiosk $REMOTE_DIR/index.html"
else
    echo "Deploy failed!"
    exit 1
fi
