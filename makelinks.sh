#!/bin/bash
# this script ensures scripts, symlinks and folders are 
# all correct

controller=false
while getopts "c" opt; do
	case $opt in
		c) controller=true ;;
		*) echo "Usage: $0 [-s]" >&2; exit 1 ;;
	esac
done

export SPATH="$HOME/Code/Setup"

# Create some folders if not already existing
mkdir -p "$HOME/Code"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.config/tmuxp"
mkdir -p "$HOME/.ssh"
[[ $controller == true ]] && sudo mkdir -p /etc/ansible
sudo chown -R "$USER":"$USER" /usr/local/bin # place our tools like mediamtx here
sudo chown -R "$USER":"$USER" /usr/local/etc # mediamtx config goes here

# link some cagelab stuff
ln -sfv "$SPATH/config/toggleInput" "/usr/local/bin"
ln -sfv "$SPATH/config/mediamtx.yml" "/usr/local/etc"
ln -svf "$HOME/Code/CageLab/software/scripts/"* "$HOME/bin"
ln -sfv "$HOME/Code/CageLab/software/services/"*.service "$HOME/.config/systemd/user"
# Link theConductor service for newer MATLAB if present
[[ -d "/usr/local/MATLAB/R2025a" ]] && ln -sfv "$HOME/Code/CageLab/software/services/theConductor2025a.dservice" "$HOME/.config/systemd/user/theConductor.service"
[[ -d "/usr/local/MATLAB/R2025b" ]] && ln -sfv "$HOME/Code/CageLab/software/services/theConductor2025b.dservice" "$HOME/.config/systemd/user/theConductor.service"
[[ ! -f "$HOME/.ssh/config" ]] && ln -svf "$HOME/Code/Setup/config/sshconfig" "$HOME/.ssh/config"
ln -sfv "$SPATH/config/.rsync-excludes" "$HOME/.config"

# Link .zshrc
if [[ $controller == false ]]; then
	echo "Linking zsh configuration files..."
	[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.config/.zshrc"$(date -Iseconds)".bak
	ln -svf "$SPATH/config/zshrc" "$HOME/.zshrc"
	ln -svf "$SPATH/config/zsh-"* "$HOME/.config"
	ln -svf "$SPATH/config/aliases" "$HOME/.config"
fi

# ansible config
if [[ $controller == true ]]; then
	echo "Linking ansible controller files..."
	sudo ln -svf "$SPATH/ansible/"* "/etc/ansible"
fi

# few others
ln -svf "$SPATH/config/i3config" "$HOME/.config/i3/config"
ln -svf "$SPATH/config/Xresources" "$HOME/.Xresources"
[[ ! -f "$HOME/.tmux.conf" ]] && ln -svf "$SPATH/config/.tmux.conf" "$HOME"
ln -svf "$SPATH/config/cagelab-monitor.yaml" "$HOME/.config/tmuxp"
[[ ! -f "$HOME/.config/starship.toml" ]] && ln -svf "$SPATH/config/starship.toml" "$HOME/.config/starship.toml"
sudo cp "$SPATH/config/10-libuvc.rules" "/etc/udev/rules.d/"

# Link pixi-global.toml
[[ ! -f "$HOME/.pixi/manifests/pixi-global.toml" ]] && mkdir -p $HOME/.pixi/manifests && ln -svf $SPATH/config/pixi-global.toml $HOME/.pixi/manifests/
