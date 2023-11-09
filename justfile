default:
	just --list

dependencies:
	sudo pacman -S fzf sof-firmware nano os-prober
	sudo git clone https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab
	sudo git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
	yay -Sy fcitx5-bamboo fcitx5-configtool fcitx5-gtk obs-studio pulsemixer baobab shellcheck shfmt less --noconfirm

config:
	stow */

node-dev:
	yay -Sy fnm-bin --noconfirm

python-dev:
	yay -Sy tk pyenv zip terraform --noconfirm
	pyenv install 3.8.7
	pyenv global 3.8.7

aws:
	yay -Sy aws-cli-v2 authy --noconfirm
	pip install awsume

docker:
	sudo pacman -Sy docker docker-compose
	sudo systemctl enable docker.service
	sudo usermod -aG docker $USER
	newgrp docker

virtualization:
	sudo pacman -Sy virt-manager qemu-desktop dnsmasq iptables-nft
	sudo systemctl enable	libvirtd.service
	sudo systemctl start	libvirtd.service
