## Core

curl -LO https://raw.githubusercontent.com/ducnguyen96/dotfiles/master/justfile
just core

## Add user

Login as root

```sh
useradd -m d
passwd d
```

```sh
usermod -aG wheel d
nano /etc/sudoers
```

## Bootstrap

Login as user

```sh
git clone git@github.com:ducnguyen96/dotfiles
cd dotfiles
git submodule update --init --recursive
just bootstrap
just utils
```
