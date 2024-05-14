# Grub2 Custom Theme Cycle
A bash script to automatically cycle throught grub2 themes on NobaraOS and Fedora

## Usage
1. Download the themes([for example](https://github.com/SiriusAhu/Persona_5_Royal_Grub_Themes)) you want and save them to `/boot/grub2/themes`. The themes must have a theme.txt directly inside it.
2. Clone the repo and cd into it using ```bash
git clone https://github.com/GinOwO/Grub2-Theme-Cycle && cd Grub2-Theme-Cycle
```
3. If you only want to run this script once, do so with ```bash
sudo bash grub-theme-cycle.sh
```, otherwise run ```bash
sudo bash add-crontab-reboot.sh
``` to run the script at every reboot using a cronjob

> [!NOTE]
> A log can be found at /var/log 

> [!NOTE]
> This can technically work on non Fedora distributions that use GRUB2. Just change the line containing `grub2-mkconfig` to use `update-grub` instead for Debian distributions. But I cannot test this hence I will not be modifying the script with this until I can do so.
