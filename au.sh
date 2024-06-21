#!/bin/bash

# Определить букву диска
disk=$(lsblk -po "model,name" | grep -e HARD | cut -d'/' -f3)

# Обновление зеркал
reflector --country ru --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
