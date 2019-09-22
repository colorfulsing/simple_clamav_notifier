#!/bin/sh
found=
last_line=
last_line_timeout=0
timeout_runtime="2 seconds"

tail -fn0 /var/log/clamav/clamd.log | \
while read line ; do
  # Clear last line anti-duplicate after timeout runtime
  if [[ $(date -u +%s) -ge $last_line_timeout ]]; then
    last_line=
  fi

  # Check for detected viruses
  found="$(echo "$line" | grep -oP "ScanOnAccess: \K(.*)(?=:(.*) FOUND)")"
  if [ $? = 0 ]; then
    # Avoid too soon duplicate detections
    new_line="$(echo "$line" | grep -oP "ScanOnAccess: \K(.*)(?:(.*) FOUND)")"
    if [ "$last_line" != "$new_line" ]; then
      # Save last detection to avoid duplicates and set anti-duplicate timeout
      last_line="$new_line"
      last_line_timeout=$(date -ud "$timeout_runtime" +%s)
      
      # Alert detection
      virus_file="$(echo "$line" | grep -oP "ScanOnAccess: \K(.*)(?=:(.*) FOUND)")"
      virus_name="$(echo "$line" | grep -oP "ScanOnAccess: .*?: \K(.*)(?= FOUND)")"
      env CLAM_VIRUSEVENT_VIRUSNAME="$virus_name" CLAM_VIRUSEVENT_FILENAME="$virus_file" /etc/clamav/detected.sh
      
      # Uncommend to send to quarantine
      #if [ -n "virus_file" ]; then
      #  mv virus_file /path/to/quarantine/
      #  echo "Found and quarantined virus file: virus_file" >> /var/log/clamav/clamd.log
      #fi
    fi
  fi
done
