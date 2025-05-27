#!/bin/bash 


echo "==============================================="
echo "      🛡️  Secure Linux CLI Dashboard"
echo "==============================================="


# Uptime and Load
echo -e "\nUptime and Load:"
uptime

# Logged in Users 
echo -e "\nLogged in Users:"
who

# Last SSH Logins
echo -e "\nRecent SSH Logins:"
last -a | grep "ssh" | head -5 


# Failed Logins
echo -e "\nFailed SSH Login Attempts:"
grep "Failed password" /var/log/auth.log | tail -5


# UFW Firewall Status
echo -e "\nUFW Firewall status:"
ufw status verbose


# Fail2Ban Status
echo -e "\nFail2Ban Status"
fail2ban-client status sshd 2>/dev/null || echo "Fail2Ban not activeor sshd jail missing." 


# Disk Usage
echo -e "\n Disk Usage:"
df -h / 


# Memory Usage 
echo -e "\nMemory Usage:"
free -h

# CPU Info
echo -e "\nCPU Load (top 5 processes):"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6



echo "==============================================="
echo "   ✅ All metrics collected. Stay secure."
echo "==============================================="

