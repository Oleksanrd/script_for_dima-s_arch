#!/bin/sh
set -e

echo "abiba"

#particing_disk
echo "Particig disk..."

echo "_____All_disks_____"
fdisk --list
echo "___________________"

read -rp "Input name the disk (example, /dev/sda): " DISK

if [ ! -b "$DISK" ]; then
    echo "ERROR: $DISK doesn't exsist or it's not a block device"
    exit 1
fi

echo "Clearing the table of partitions..."
wipefs -a "$DISK"

echo "Creating new GPT table and 3 partitions..."
fdisk "$DISK" <<EOF
g
n
1
2048
4095
t
4

n
2
4097
8390655
t
2
19

n
3
8390656

t
3
20
w
EOF

sleep 2

echo "!!! ATTENTION !!! ALL DATA $DISK WILL BE DELETED"
read -rp "DO FORMAT $DISK? [yes/NO]: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Formating canceled."
fi

#formating_disk
echo "Formating disk..."
mkswap "${DISK}2"
swapon -a
mkfs.ext4 "${DISK}3"

echo "Finish!"
lsblk "$DISK"


#configuring_region

echo "Configure region..."
timedatectl set-timezone Europe/Kyiv

#configuring_mirrors

echo "Adding new mirrors..."
echo "## Ukraine
Server = http://distrohub.kyiv.ua/archlinux/$repo/os/$arch
Server = https://distrohub.kyiv.ua/archlinux/$repo/os/$arch
Server = http://repo.hyron.dev/archlinux/$repo/os/$arch
Server = https://repo.hyron.dev/archlinux/$repo/os/$arch
Server = http://mirror.hostiko.network/archlinux/$repo/os/$arch
Server = https://mirror.hostiko.network/archlinux/$repo/os/$arch
Server = http://archlinux.ip-connect.vn.ua/$repo/os/$arch
Server = https://archlinux.ip-connect.vn.ua/$repo/os/$arch
Server = http://mirror.mirohost.net/archlinux/$repo/os/$arch
Server = https://mirror.mirohost.net/archlinux/$repo/os/$arch
Server = http://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
Server = http://mirrors.reitarovskyi.tech/archlinux/$repo/os/$arch
Server = https://mirrors.reitarovskyi.tech/archlinux/$repo/os/$arch" | tee -a /etc/pacman.d/mirrorlist

echo "Adding more parallel downloads..."
sed -i 's/ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf

echo "Mounting system..."
mount "${DISK}3" /mnt
swapon "${DISK}2"

#Installing_base_packages"
echo "Installing base packages..."
pacstrap /mnt base linux linux-firmware linux-headers bash-completion grub nano unzip zip wget vim networkmanager sddm xorg plasma kde-applications openssh

echo "Generating list of launching devices..."
genfstab /mnt
genfstab /mnt >> /mnt/etc/fstab

mkdir -p /mnt/root/script

arch-chroot /mnt <<EOF

echo "Configuration new system..."
systemctl enable NetworkManager
systemctl enable sddm

echo "Addin user..."
read -rp "Say your name." USER
useradd -m "$USER"
passwd "$USER"
echo "adding password for root"
passwd root

usermod -aG sudo "$USER"

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
echo "FINIIIIIIISH, suck your **** now, exit to this shell and reboot the system :)"
exit

EOF
echo "Congrat!!!"
reboot
