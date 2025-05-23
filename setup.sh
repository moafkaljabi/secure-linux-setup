#!/bin/bash


# Secure Linux Server Script.
# Run as root or with sudo.
# Tested on Ubuntu and Raspberry OS


LOG_DIR="./logs"
LOGFILE="$LOG_DIR/setup.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOGFILE") 2>&1
set -e


echo "Starting secure server setup..."
echo "Logging to $LOGFILE"


# 1. Create new user 
read -p "Enter new admin username: " NEW_USER
adduser "$NEW_USER"
usermod -aG sudo "$NEW_USER"
echo "User $NEW_USER created and added to sudo group."



# 2. Setup SSH key authentication
SSH_DIR="/home/$NEW_USER/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

read -p "Paste your public SSH key: " SSH_KEY
echo "$SSH_KEY" > "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$NEW_USER:$NEW_USER" "$SSH_DIR"
echo "SSH key authentication set up success."



# 3. Harden SSH configuration 
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak"


sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
systemctl reload sshd 
echo "SSH Hardened (Password login disabled, root login disabled)."



# 4. Install and configure UFW
apt update 
apt install -y ufw
ufw allow OpenSSH
ufw allow http 
ufw allow https 
ufw --force enable 
echo "Firewall enabled with basic rules (SSH, HTTP, HTTPS)."



# 5. Install and configure Fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban 
echo "Fail2ban installed and running"



# 6. Setup automatic updates using cron
CRON_JOB="/etc/cron.d/weekly-update"
echo "0 3 * * 0 root apt update && apt upgrade -y" > "$CRON_JOB"
chmod 644 "$CRON_JOB"
echo "Weekly update cron job added."

echo "Setup completed successfully."
echo "All steps logged to $LOGFILE"
