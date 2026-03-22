#!/bin/bash

# 1. Particionamiento (GPT)
# vda1: 512MiB (EFI), vda2: Resto (Root)
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/vda
  g # nueva tabla GPT
  n # nueva partición (EFI)
  1 # número 1
    # default start
  +512M
  t # tipo
  1 # EFI System
  n # nueva partición (Root)
  2 # número 2
    # default start
    # default end (resto del disco)
  w # escribir cambios
EOF

# 2. Formateo
mkfs.fat -F 32 /dev/vda1
mkfs.ext4 /dev/vda2

# 3. Montaje
mount /dev/vda2 /mnt
mount --mkdir /dev/vda1 /mnt/boot

# 4. Instalación de base
pacstrap -K /mnt base linux linux-firmware nano networkmanager grub efibootmgr

# 5. Generar FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

# 6. Configuración dentro del sistema (Chroot)
arch-chroot /mnt /bin/bash << EOF
ln -sf /usr/share/zoneinfo/America/Caracas /etc/localtime
hwclock --systohc
echo "arch-qemu" > /etc/hostname
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configurar GRUB para UEFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Habilitar red y poner password a root (password: 1234)
systemctl enable NetworkManager
echo "root:1234" | chpasswd
EOF

echo "¡Instalación completada! Escribe 'reboot' y quita la ISO del comando de QEMU."
