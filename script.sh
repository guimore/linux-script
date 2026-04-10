#!/bin/bash
THRESHOLD=80
EMAIL="sysadmin@claro.com.ar"

df -hP | grep -vE '^Filesystem|tmpfs|cdrom' | while read line; do
  USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
  MOUNTPOINT=$(echo $line | awk '{print $6}')
  
  if [ $USAGE -ge $THRESHOLD ]; then
    echo "Warning: High disk usage on $MOUNTPOINT ($USAGE%)" | mail -s "Disk Alert: $HOSTNAME" $EMAIL
  fi
done

##############################################
instalar parche de seguridad importantes
#############
#!/bin/bash
LOGFILE="/var/log/sys-updates.log"
EMAIL="sysadmin@claro.com.ar"

echo "iniciando los updates on $(date)" >> $LOGFILE
apt update && apt upgrade -y >> $LOGFILE 2>&1
apt autoremove -y >> $LOGFILE 2>&1

tail -20 $LOGFILE | mail -s "System Update Report: $HOSTNAME" $EMAIL

##############################################
#!/bin/bash
SERVICES=("apache2" "mysql")
EMAIL="sysadmin@claro.com.ar"

for SERVICE in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet $SERVICE; then
    systemctl start $SERVICE
    echo "$SERVICE ha sido reiniciado ene l server: $HOSTNAME" | mail -s "Service Restart Alert" $EMAIL
  fi
done


##############################################
#!/bin/bash
BACKUP_DIR="/backup"
SOURCE_DIRS="/etc /var/www /home"
DATE=$(date +%F)
BACKUP_FILE="$BACKUP_DIR/backup-$DATE.tar.gz"
EMAIL="syadmin@claro.com.ar"

tar -czf $BACKUP_FILE $SOURCE_DIRS

if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $BACKUP_FILE" | mail -s "Backup Success - $HOSTNAME" $EMAIL
else
  echo "Backup FAILED!" | mail -s "Backup Failed - $HOSTNAME" $EMAIL
fi

##############################################
#!/bin/bash
LOGFILE="/var/log/auth.log"
LAST_RUN_FILE="/tmp/last_run_time"
EMAIL="sysadmin@claro.com.ar"

if [ ! -f $LAST_RUN_FILE ]; then
  date --date='5 minutes ago' +%s > $LAST_RUN_FILE
fi

LAST_RUN=$(cat $LAST_RUN_FILE)
NOW=$(date +%s)

awk -v last=$LAST_RUN -v now=$NOW '
  $0 ~ /session opened for user/ {
    cmd = "date -d \""$1" "$2" "$3"\" +%s"
    cmd | getline t
    close(cmd)
    if (t >= last && t <= now) { print $0 } } ' $LOGFILE | mail -s "Login Alert - $HOSTNAME" $EMAIL echo $NOW > $LAST_RUN_FILE

##############################################
#!/bin/bash
SERVICES=("apache2" "mysql")
EMAIL="sysadmin@claro.com.ar"

for SERVICE in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet $SERVICE; then
    systemctl start $SERVICE
    echo "$SERVICE was down and has been restarted on $HOSTNAME" | mail -s "Service Restart Alert" $EMAIL
  fi
done

##############################################

##############################################
