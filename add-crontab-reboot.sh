#!/bin/bash

set -e

if [ $EUID -ne 0 ]; then
  echo "Please run as sudo"
  exit 1
fi

script_dir="/usr/local/share/grub-theme-cycle"

if [[ -d $script_dir ]]; then
  rm -rf $script_dir
fi

mkdir "$script_dir"
\cp "grub-theme-cycle.sh" "$script_dir/"
chown root:root "$script_dir/grub-theme-cycle.sh"
chmod 755 "$script_dir/grub-theme-cycle.sh"
cron_command="@reboot $script_dir/grub-theme-cycle.sh"

if [[ -z $(sudo crontab -l | grep "$cron_command") ]]; then
  (sudo crontab -l; echo "$cron_command") | sudo crontab -

  if [ $? -eq 0 ]; then
    echo "Cron job added successfully."
  else
    echo "Failed to add cron job."
  fi
else
  echo "Cronjob already exists"
fi
