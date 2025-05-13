#!/bin/bash

# ===== STEP 1: Install necessary dependencies =====
echo "Installing required packages..."
sudo apt update
sudo apt install -y curl gnome-screenshot wget

# ===== STEP 2: Download your script (if not already downloaded) =====
echo "Downloading login-alert.sh script..."
wget -O /home/$USER/login-alert.sh "https://github.com/dixitcoder/WebNmap/blob/main/login-alert.sh"
chmod +x /home/$USER/login-alert.sh

# ===== STEP 3: Create systemd service file =====
echo "Creating systemd service..."
SERVICE_FILE="/home/$USER/.config/systemd/user/login-alert.service"

mkdir -p ~/.config/systemd/user

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Login Alert Service

[Service]
ExecStart=/home/$USER/login-alert.sh
Restart=always
User=$USER

[Install]
WantedBy=default.target
EOF

# ===== STEP 4: Reload systemd, enable, and start service =====
echo "Reloading systemd, enabling, and starting the service..."
systemctl --user daemon-reload
systemctl --user enable login-alert.service
systemctl --user start login-alert.service

# ===== STEP 5: Show service status =====
systemctl --user status login-alert.service
