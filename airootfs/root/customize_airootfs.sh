#!/bin/bash

cd /root
git clone https://github.com/HoloISO-Reborn/holoiso-installer
cp -R /root/holoiso-installer/* /
cd -
chmod +x -R /usr/bin /etc/lib /etc/X11 /home/holoiso/Desktop
systemctl enable sddm
pacman -Rdd plasma-welcome --noconfirm
pip install customtkinter --break
plymouth-set-default-theme -R steamos