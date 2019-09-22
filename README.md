# Alert detection

Simple alert script and service for clamav.

## Instalation

Open terminal and move to this project directory, then as `root` execute the following:
```BASH
mkdir -p /opt/simple_clamav_notifier
cp simple_clamav_notifier.sh /opt/simple_clamav_notifier/simple_clamav_notifier.sh
chmod +744 /opt/simple_clamav_notifier/simple_clamav_notifier.sh
cp alert_detection.service /etc/systemd/system/simple_clamav_notifier.service
chmod +664 /etc/systemd/system/simple_clamav_notifier.service
# Reload systemctl configuration
systemctl daemon-reload
```
Now start and enable the service so it is executed on boot:
```
systemctl start simple_clamav_notifier.service
systemctl enable simple_clamav_notifier.service
```
**_Optional:_** Enable quarentine by uncommenting this code segment on script and change the quarentine target directory
```
# Uncommend to send to quarantine
if [ -n "virus_file" ]; then
  mv virus_file /path/to/quarantine/
  echo "Found and quarantined virus file: virus_file" >> /var/log/clamav/clamd.log
fi
```

**Note:** This script was created using notification script created by `bibikitrinke` (https://bugzilla.clamav.net/show_bug.cgi?id=12152#c7) as a base.
