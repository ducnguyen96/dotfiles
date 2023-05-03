default:
	just --list

core:
	pacman -Sy networkmanager sof-firmware --noconfirm
	
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
	systemctl disable NetworkManager-wait-online.service

	pacman -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg

mirrors:
	yay -Sy reflector rsync --noconfirm
	sudo reflector --protocol https --country vietnam,singapore,thailand,japan,australia --latest 100 --download-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist

shell:	
	# shell
	yay -Sy zsh starship exa fzf ttf-meslo-nerd-font-powerlevel10k --noconfirm
	echo 1 | chsh -s $(which zsh)

	# zsh framework - zap
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh | sed '/source "\$ZSHRC"/d') --branch release-v1
	rm -rf $HOME/.zshrc

utils:
	yay -Sy openssh fcitx5-bamboo fcitx5-configtool fcitx5-gtk imagemagick rofi feh acpi i3lock scrot ranger dragon-drop --noconfirm
	rm -rf yay

	# audio
	yay -Sy pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pulsemixer --noconfirm
	systemctl --user enable --now pipewire.socket
	systemctl --user enable --now pipewire-pulse.socket
	systemctl --user enable --now wireplumber.service

laptop:
	yay -Sy bluez bluez-utils --noconfirm
	sudo systemctl enable bluetooth.service

bootstrap:
	# aur
	sudo pacman -S --needed --noconfirm git stow base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

	# wm + compositor + term
	yay -Sy xorg-server xorg-xinit xorg-xrandr xclip awesome picom-ibhagwan-git alacritty --noconfirm

	stow */
	ln -sf $HOME/.config/shell/profile $HOME/.zprofile
	ln -sf $HOME/.config/x11/xprofile $HOME/.xprofile
	just shell
	rm  -rf $HOME/.bash*

node-dev:
	yay -Sy fnm-bin --noconfirm

python-dev:
	yay -Sy tk pyenv zip terraform --noconfirm
	pyenv install 3.8.7
	pyenv global 3.8.7

aws:
	yay -Sy aws-cli-v2 authy --noconfirm
	pip install awsume
