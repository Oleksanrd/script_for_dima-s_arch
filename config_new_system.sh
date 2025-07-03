#!/bin/bash

set -e

echo "Configuration new system..."
#цей кусок нада запускати на новій оболонці
systemctl enable NetworkManager
systemctl enable sddm

echo "Addin user..."
read -rp "Say your name." USER
useradd -m "$USER"
passwd "$USER"
echo "adding password for root"
passwd root

usermod -aG wheel "$USER"

echo "Configure locale..."
echo "en_US.UTF-8" | tee -a /etc/locale.gen
echo "uk.UA.UTF-8" | tee -a /etc/locale.gen
locale-gen

echo "Installing grub..."
echo "_______DISKS______"
fdisk -l
echo "_______DISKS______"
read -rp "Enter your disk: " DISK
grub-install "$DISK"
grub-mkconfig -o /boot/grub/grub.cfg
echo "FINIIIIIIISH, suck your ****
Now, exit to this shell and reboot the system :)"
