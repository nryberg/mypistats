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
scp index.html server.py "$USER@$SERVER:$REMOTE_DIR/"

if [ $? -ne 0 ]; then
    echo "Deploy failed!"
    exit 1
fi

# Make server executable
ssh "$USER@$SERVER" "chmod +x $REMOTE_DIR/server.py"

# Create systemd service for the stats server
ssh "$USER@$SERVER" "sudo tee /etc/systemd/system/mypistats.service > /dev/null << 'EOF'
[Unit]
Description=MyPiStats Web Server
After=network.target

[Service]
Type=simple
User=nick
WorkingDirectory=/home/nick/mypistats
ExecStart=/usr/bin/python3 /home/nick/mypistats/server.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF"

# Enable and restart the service
ssh "$USER@$SERVER" "sudo systemctl daemon-reload && sudo systemctl enable mypistats && sudo systemctl restart mypistats"

# Create autostart entry for kiosk mode on boot
ssh "$USER@$SERVER" "cat > $AUTOSTART_DIR/mypistats.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=MyPiStats
Exec=sh -c 'sleep 5 && env DISPLAY=:0 chromium --kiosk --start-fullscreen --noerrdialogs --disable-infobars --no-first-run --check-for-update-interval=31536000 --disable-session-crashed-bubble --disable-gpu-vsync --disable-software-rasterizer http://localhost:8181'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF"

echo ""
echo "Deploy successful!"
echo "Files deployed to $USER@$SERVER:$REMOTE_DIR"
echo "Server running on port 8181"
echo "Autostart configured - will launch on reboot"
echo ""
echo "To view now, run on the Pi (via SSH):"
echo "  DISPLAY=:0 chromium --kiosk --start-fullscreen --disable-gpu-vsync http://localhost:8181"
