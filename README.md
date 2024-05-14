# Grub2 Custom Theme Cycle
A bash script to automatically cycle throught grub2 themes on NobaraOS

## Usage
1. Download the themes([for example](https://github.com/SiriusAhu/Persona_5_Royal_Grub_Themes)) you want and save them to `/boot/grub2/themes`. The themes must have a theme.txt directly inside it.
2. Clone the repo using `git clone` and `cd` into it
3. If you only want to run this script once, do so with `sudo bash grub-theme-cycle.sh`, otherwise run `sudo bash add-crontab-reboot.sh` to run the script in every reboot

> [!NOTE]
> A log can be found at /var/log 
