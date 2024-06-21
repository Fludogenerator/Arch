#!/bin/bash

# Определить букву диска
disk=$(lsblk -po "model,name" | grep -e HARD | cut -d'/' -f3)

# Разметка диска (GPT/MBR)
echo -en 'label:gpt\nsize=1024M,type=U\nsize=23552M,type=L\n' | sfdisk /dev/$disk
echo -en 'label:mbr\nsize=1024M,type=L,bootable\nsize=23552M,type=L\n' | sfdisk /dev/$disk

# Форматирование разделов
mkfs.fat -F 32 /dev/"$disk"1
mkfs.ext2 /dev/"$disk"1
mkfs.ext4 /dev/"$disk"2

# Монтирование разделов
mount /dev/"$disk"2 /mnt
mount --mkdir /dev/"$disk"1 /mnt/efi
mount --mkdir /dev/"$disk"1 /mnt/boot

# Обновление зеркал
reflector --country ru --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

# Установка основных пакетов
pacstrap -K /mnt base dhcpcd efibootmgr grub intel-ucode linux linux-firmware nano pacman sudo vi xf86-video-nouveau

# Генерация Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Переход к корневому каталогу
Arch-chroot /mnt

# Часовой пояс
ln -sf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
hwclock --systohc
