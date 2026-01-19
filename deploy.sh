#!/bin/bash

# Deploy script for mypistats
# Pushes the stats page to the Raspberry Pi

SERVER="framboise"
USER="nick"
REMOTE_DIR="/home/nick/mypistats"
AUTOSTART_DIR="/home/nick/.config/autostart"

echo "Deploying to $SERVER..."

# Create remote directories if they don't exist
ssh "$USER@$SERVER" "mkdir -p $REMOTE_DIR $AUTOSTART_DIR"

# Copy files
scp index.html "$USER@$SERVER:$REMOTE_DIR/"

if [ $? -ne 0 ]; then
    echo "Deploy failed!"
    exit 1
fi

# Create autostart entry for kiosk mode on boot
ssh "$USER@$SERVER" "cat > $AUTOSTART_DIR/mypistats.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=MyPiStats
Exec=env DISPLAY=:0 chromium --kiosk --start-fullscreen --noerrdialogs --disable-infobars --no-first-run --check-for-update-interval=31536000 --disable-session-crashed-bubble --disable-gpu-vsync --disable-software-rasterizer $REMOTE_DIR/index.html
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF"

echo "Deploy successful!"
echo "Files deployed to $USER@$SERVER:$REMOTE_DIR"
echo "Autostart configured - will launch on reboot"
echo ""
echo "To view now, run on the Pi (via SSH):"
echo "  DISPLAY=:0 chromium --kiosk --start-fullscreen --disable-gpu-vsync $REMOTE_DIR/index.html"
