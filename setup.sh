#!/usr/bin/sh

sudo apt install xorg build-essential libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev libharfbuzz-dev dunst zsh fzf htop curl network-manager golang ueberzug xwallpaper psmisc fonts-linuxlibertine fonts-font-awesome bc arandr dosfstools libnotify-bin sxiv xwallpaper man-db ntfs-3g maim unclutter unzip xcape xclip xdotool fzf bc pulsemixer ncal wireplumber pipewire-media-session- wmctrl xcompmgr fonts-noto

sudo rmmod pcspkr

# Enable tap to click
sudo printf 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
	# Enable left mouse button by tapping
	Option "Tapping" "on"
EndSection' >/etc/X11/xorg.conf.d/40-libinput.conf

systemctl --user --now enable wireplumber.service
