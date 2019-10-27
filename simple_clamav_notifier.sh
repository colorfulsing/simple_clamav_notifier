#!/bin/sh
found=
last_line=
last_line_timeout=0
timeout_runtime="2 seconds"
# Quarentine support, enabled = 1, disabled = 0
# Default = 0
quarentine_enabled=0
quarentine_dir="/quarentine"
log_file="/var/log/clamav/simple_clamav_notifier.log"

# Create quarentine directory if don't exists
if [ "$quarentine_enabled" == "1" ] && [ ! -d "$quarentine_dir" ]; then
  mkdir -p "$quarentine_dir"
fi

echo "Simple clamav notifier has started" >> "$log_file"

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
      file_in_quarentine="$(if [ "$quarentine_enabled" == "1" ] && [[ "$virus_file" == "${quarentine_dir}/"* ]]; then echo "1"; else echo "0"; fi)"
      if [ "$quarentine_enabled" != "1" ] || [ "$file_in_quarentine" != "1" ]; then
        env CLAM_VIRUSEVENT_VIRUSNAME="$virus_name" CLAM_VIRUSEVENT_FILENAME="$virus_file" /etc/clamav/detected.sh
      fi
      
      # Uncomment to send to quarantine
      if [ "$quarentine_enabled" == "1" ] && [ -f "$virus_file" ] && [ "$file_in_quarentine" != "1" ]; then
        # Create quarentine directory if don't exists
        if [ ! -d "$quarentine_dir" ]; then
          mkdir -p "$quarentine_dir"
        fi

        # Quarentine file, remove execution rights and change user to clamav
        echo "Trying to quarentine virus file \"$virus_file\"..." >> "$log_file"
        quarentine_file="$quarentine_dir/$(date +%s%N)_${virus_file##*/}" && \
        chmod ugo-x "$virus_file" && \
        mv "$virus_file" "$quarentine_file" && \
        chown clamav:clamav "$quarentine_file" && \
        chmod o-rw "$quarentine_file" && \
        echo "Found and quarentined virus file \"$virus_file\" as \"$quarentine_file\"" >> "$log_file"

        # Check if successful
        if [ -f "$virus_file" ]; then
          echo "Failed to quarentine \"$virus_file\" virus file!!!" >> "$log_file"
        fi
      fi
    fi
  fi
done
