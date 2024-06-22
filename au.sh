#!/bin/bash

# Определить букву диска
disk=$(lsblk -po "model,name" | grep -e HARD | cut -d'/' -f3)

# Разметка диска (GPT/MBR)
echo -en 'label:gpt\n,1024M,U\n,23552M,L\n' | sfdisk /dev/$disk
echo -en 'label:mbr\n,1024M,L\n,23552M,L\n' | sfdisk /dev/$disk

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
arch-chroot /mnt

# Часовой пояс
ln -sf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
hwclock --systohc

# Локализация
sed -i -e "/#en_US.UTF-8/s/#//" /etc/locale.gen
sed -i -e "/#ru_RU.UTF-8/s/#//" /etc/locale.gen
locale-gen
echo LANG=ru_RU.UTF-8 > /etc/locale.conf
echo FONT=Cyr_a8x16 > /etc/vconsole.conf
echo KEYMAP=ruwin_alt_sh-UTF-8 >> /etc/vconsole

# Настройка сети
echo MS-7D17 > /etc/hostname
systemctl enable dhcpcd.service

mkinitcpio -P


