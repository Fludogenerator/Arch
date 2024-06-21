#!/bin/bash

# Определить букву диска
disk=$(lsblk -po "model,name" | grep -e HARD | cut -d'/' -f3)

# Разметка диска (GPT/MBR)
echo -ne 'label:gpt\nsize=1024M,type=U\nsize=23552M,type=L\n' | sfdisk /dev/$disk
echo -ne 'label:mbr\nsize=1024M,type=L,bootable\nsize=23552M,type=L\n' | sfdisk /dev/$disk













# Обновление зеркал
reflector --country ru --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
