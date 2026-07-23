# Systemd Service Management

GitHub Daily Activity uses systemd for service management.

## Service File

Location: `/etc/systemd/system/github-daily-activity.service`

```ini
[Unit]
Description=GitHub Daily Activity - Boot Logger
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/github-daily-activity/boot-log.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
WorkingDirectory=/opt/github-daily-activity

[Install]
WantedBy=multi-user.target
```

## Service Commands

### Check Status

```bash
sudo systemctl status github-daily-activity
```

### Start Service

```bash
sudo systemctl start github-daily-activity
```

### Stop Service

```bash
sudo systemctl stop github-daily-activity
```

### Restart Service

```bash
sudo systemctl restart github-daily-activity
```

### Enable Service (Start on Boot)

```bash
sudo systemctl enable github-daily-activity
```

### Disable Service

```bash
sudo systemctl disable github-daily-activity
```

### View Logs

```bash
# Recent logs
journalctl -u github-daily-activity

# Follow logs in real-time
journalctl -u github-daily-activity -f

# Logs since last boot
journalctl -u github-daily-activity -b

# Logs for specific time range
journalctl -u github-daily-activity --since "2024-01-15" --until "2024-01-16"
```

## How Systemd Triggers the Service

1. System boots
2. systemd reaches `multi-user.target`
3. Service starts after `network-online.target`
4. Script runs as `Type=oneshot`
5. `RemainAfterExit=yes` keeps service "active" after script exits

## Troubleshooting

### Service Won't Start

```bash
# Check for errors
journalctl -u github-daily-activity -n 50

# Check service file
systemctl cat github-daily-activity

# Reload after changes
sudo systemctl daemon-reload
```

### Service Not Running on Boot

```bash
# Check if enabled
systemctl is-enabled github-daily-activity

# Enable if not
sudo systemctl enable github-daily-activity
```

### Check Dependencies

```bash
# List dependencies
systemctl list-dependencies github-daily-activity

# Check network target
systemctl status network-online.target
```
