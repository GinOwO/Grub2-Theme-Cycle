#!/bin/bash

# Construct the logfile name with datetime
logfile="/var/log/grub_theme_cycle_logfile.log"
echo "------------------------------------------" > "$logfile"
log() {
  current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")
  echo "$current_datetime: $1" >> "$logfile"
}

# Function to log errors and exit
log_error() {
  local exit_code="${2:-1}"
  
  sessions=$(who | awk '{print $1}' | sort -u)
  for user in $sessions; do
    sudo -u $user DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $user)/bus notify-send "Some error occured while changing the grub theme." "Check $logfile for more details"
  done

  log "Error: $1"
  if [[ $exit_code -eq 1 ]] && [[ $EUID -eq 0 ]]; then
    log "Restoring from /tmp/grub to /etc/default/grub"
    \cp /tmp/grub /etc/default/grub
    log "Restored"
  fi
  dump="grub_console_line: $grub_console_line    current_theme_line: $current_theme_line    folders: $folders    new_theme: $new_theme"
  log "DUMP Start"
  log "$dump"
  log "DUMP End"
  log "Exit with code $exit_code"
  exit $exit_code
}

# Set up trap to call log_error function on error
trap 'log_error "$BASH_COMMAND" 1' ERR

log "Job started"

# Check sudo access
if [ $EUID -ne 0 ]; then
  log_error "No root access. Run with sudo" 2
fi

folder_paths=("/boot/grub2" "/boot/grub2/themes")

for folder_path in "${folder_paths[@]}"; do
  if [[ ! -d "$folder_path" ]]; then
    log_error "$folder_path does not exist." 3
  fi
done

log "Making backup of /etc/default/grub to /tmp/grub"
cp /etc/default/grub /tmp/grub

folders=($(find /boot/grub2/themes -maxdepth 1 -type d -not -name "current" -not -name "themes"))

if [ ${#folders[@]} -eq 0 ]; then
  log_error "Add some themes first" 4
fi

new_theme=${folders[$RANDOM % ${#folders[@]}]}

if [[ ! -f "$new_theme/theme.txt" ]]; then
  log_error "$new_theme does not have a theme.txt directly inside it" 5
fi

grub_path="/etc/default/grub"
grub_dir="/boot/grub2"
grub_theme_dir="$grub_dir/themes/current"
grub_theme="GRUB_THEME=\"$grub_theme_dir/theme.txt\""

current_theme=$(grep -n "GRUB_THEME" "$grub_path" || echo "")
current_theme_line=$(echo $current_theme | cut -d: -f1)
current_theme=$(echo $current_theme | cut -d: -f2-)

if [[ -z "$current_theme" ]]; then
  log "No theme found in $grub_path"
  echo "$grub_theme" >> $grub_path
  log "$grub_theme added to $grub_path"
elif [[ "$current_theme" != "$grub_theme" ]]; then
  log "Different theme path found, replacing"
  sed -i "${current_theme_line}s|.*|$grub_theme|" "$grub_path"
  log "Replaced $current_theme to $grub_theme"
else
  log "Existing $grub_theme found in /etc/default/grub"
fi

grub_console_line=$(grep -n "GRUB_TERMINAL_OUTPUT" "$grub_path" || echo "")
grub_console_line=$(echo "$grub_console_line" | cut -d: -f1)
if [[ ! -z $grub_console_line ]]; then
  log "GRUB_CONSOLE found, removing"
  sed -i "${grub_console_line}s|.*||; /^$/d" "$grub_path"
  log "Removed"
fi

log "Choosing $random_folder"

if [[ -d $grub_theme_dir ]]; then
  log "Existing $grub_theme_dir folder found, replacing"
  rm -rf "$grub_theme_dir"
else
  log "Creating $grub_theme_dir"
fi

\cp -r "$new_theme" "$grub_theme_dir"
log "Done moving $new_theme"

log "Running grub2-mkconfig"
grub2-mkconfig -o /boot/grub2/grub.cfg 2>&1 | while IFS= read -r line; do
    log "$line"
done
\cp /boot/grub2/grub.cfg /boot/efi/EFI/fedora/grub.cfg -f
log "Finished running"

log "Job Completed"

echo "------------------------------------------" >> "$logfile"
