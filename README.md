# Alert detection

Simple alert script and service for clamav.

## Instalation

Open terminal and move to this project directory, then as `root` execute the following:
```BASH
mkdir -p /opt/simple_clamav_notifier
cp simple_clamav_notifier.sh /opt/simple_clamav_notifier/simple_clamav_notifier.sh
chmod +744 /opt/simple_clamav_notifier/simple_clamav_notifier.sh
cp detected.sh /opt/simple_clamav_notifier/detected.sh
chmod +744 /opt/simple_clamav_notifier/detected.sh
cp simple_clamav_notifier.service /etc/systemd/system/simple_clamav_notifier.service
chmod +664 /etc/systemd/system/simple_clamav_notifier.service
# Reload systemctl configuration
systemctl daemon-reload
```
Now start and enable the service so it is executed on boot:
```BASH
systemctl start simple_clamav_notifier.service
systemctl enable simple_clamav_notifier.service
```
**_Optional:_** Enable quarentine by changing the following on `simple_clamav_notifier.sh` script to your needs:
```BASH
# Enable quarentine feature
quarentine_enabled=1
# Quarentine directory to store found virus files
quarentine_dir="/quarentine"
# Log file path
log_file="/var/log/clamav/simple_clamav_notifier.log"
# Detected script path
detected_file="/opt/simple_clamav_notifier/detected.sh"
```

**Note:** This script was created using notification script created by `bibikitrinke` (https://bugzilla.clamav.net/show_bug.cgi?id=12152#c7) as a base, and using `detected.sh` example file from [https://wiki.archlinux.org/index.php/ClamAV#OnAccessScan](https://wiki.archlinux.org/index.php/ClamAV#OnAccessScan).
