default:
	just --list

core:
	pacman -Sy networkmanager--noconfirm
	
	# time
	ln -sf /usr/share/zoneInfo/Asia/Ho_Chi_Minh /etc/localtime
	hwclock --systohc

	# locale
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	
	# host
	echo machine > /etc/hostname
	passwd

	# systemd
	systemctl enable NetworkManager

grub:
	pacman -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg

mirrors:
	sudo reflector
	sudo reflector --latest 10 --sort rate --country singapore,china --save /etc/pacman.d/mirrorlist

aur:
	sudo pacman -S --needed --noconfirm git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

wm:
	# window manager
	yay -S xorg-server xorg-xinit awesome --noconfirm

	# compositor
	yay -S picom-ibhagwan-git --noconfirm

term:
	# terminal
	yay -S alacritty --noconfirm

shell:
	# shell
	yay -S zsh --noconfirm
	echo 1 | chsh -s $(which zsh)

	# zsh framework - zap
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh | sed '/source "\$ZSHRC"/d') --branch release-v1

apps:
	yay -S fcitx5-bamboo fcitx5-configtool fcitx5-gtk --noconfirm
	yay -S firefox imagemagick rofi feh nm-connection-editor xfce4-power-manager i3lock scrot ranger --noconfirm

config:
	just aur
	just wm
	just term
	stow */
	ln -sf $HOME/.config/shell/profile $HOME/.zprofile
	ln -sf $HOME/.config/x11/xprofile $HOME/.xprofile
	just shell
