# Config Files

Configuration I use for my environment

## Preview

<img src="i3-preview.png" width="300"> <img src="rofi-preview.png" width="300">

## Install Dependency

Install application

```bash
sudo apt update && sudo apt upgrade
sudo apt install alacritty nitrogen rofi i3lock-fancy xfce4-screenshooter thunar nm-applet
```
Install font, follow this instruction
[Nerd Font Installer](https://github.com/officialrajdeepsingh/nerd-fonts-installer)

## Clone this repo

```bash
git clone https://github.com/risyady/dotfiles-wm.git
cd dotfiles-wm
```

## copy the folder or just make symlink

```bash
mkdir -p ~/.config/i3
mkdir -p ~/.config/rofi
ln -s ./i3/config ~/.config/i3
ln -s ./rofi/* ~/.config/rofi
```
