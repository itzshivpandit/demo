#!/bin/bash

# ==============================
# Log Cleanup Script (Ubuntu)
# Deletes logs related to:
# git, ssh, ping, login details
# ==============================

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

echo "Stopping rsyslog temporarily..."
systemctl stop rsyslog

echo "Cleaning SSH and login logs..."

# SSH & authentication logs
> /var/log/auth.log
> /var/log/auth.log.1 2>/dev/null

# Login records
> /var/log/wtmp
> /var/log/btmp
> /var/log/lastlog

echo "Cleaning syslog (git, ssh, ping entries)..."

# Remove git, ssh, ping entries from syslog
if [ -f /var/log/syslog ]; then
    sed -i '/git/d;/ssh/d;/ping/d' /var/log/syslog
fi

if [ -f /var/log/syslog.1 ]; then
    sed -i '/git/d;/ssh/d;/ping/d' /var/log/syslog.1
fi

echo "Cleaning journal logs (if systemd journal is used)..."

# Clear systemd journal logs
journalctl --rotate
journalctl --vacuum-time=1s

echo "Cleaning bash history..."

# Clear current user's bash history
history -c
> ~/.bash_history

echo "Restarting rsyslog..."
systemctl start rsyslog

echo "Log cleanup completed."
