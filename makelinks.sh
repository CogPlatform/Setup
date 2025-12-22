#!/bin/bash
# this script ensures cagelab scripts, symlinks and folders are 
# all correct

# Ensure the script continues on errors and handles empty globs
set +e
shopt -s nullglob

controller=false
server=false
while getopts "cs" opt; do
	case $opt in
		c) controller=true ;;
		s) server=true ;;
		*) echo "Usage: $0 [-c] [-s]" >&2; exit 1 ;;
	esac
done

export SPATH="$HOME/Code/Setup"

# Create some folders if not already existing
mkdir -p "$HOME/Code"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.config/tmuxp"
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.ssh"
[[ $controller == true ]] && mkdir -p "$HOME/.ansible" && sudo mkdir -p /etc/ansible && sudo chown -R "$USER":"$USER" /etc/ansible || true
sudo mkdir -p /usr/local/bin /usr/local/etc
sudo chown -R "$USER":"$USER" /usr/local/bin || true
sudo chown -R "$USER":"$USER" /usr/local/etc || true

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

# Link .zshrc only for non-controllers
if [[ $controller == false ]]; then
	echo "Linking zsh configuration files..."
	[[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.config/.zshrc$(date -Iseconds).bak"
	ln -svf "$SPATH/config/zshrc" "$HOME/.zshrc"
	ln -svf "$SPATH/config/zsh-"* "$HOME/.config"
	ln -svf "$SPATH/config/aliases" "$HOME/.config"
fi

# ansible config only for controllers
if [[ $controller == true ]]; then
	echo "Linking ansible controller files..."
	sudo ln -svf "$SPATH/ansible/inventory/hosts" "/etc/ansible/hosts"
	sudo ln -svf "$SPATH/ansible/playbooks" "/etc/ansible/playbooks"
	sudo ln -svf "$SPATH/ansible/roles" "/etc/ansible/roles" 
fi

# Link pixi-global.toml
if [[ ! -f "$HOME/.pixi/manifests/pixi-global.toml" ]]; then
	mkdir -p "$HOME/.pixi/manifests"
	ln -svf "$SPATH/config/pixi-global.toml" "$HOME/.pixi/manifests/"
fi

# few others
sudo cp "$SPATH/config/10-libuvc.rules" "/etc/udev/rules.d/"
ln -svf "$SPATH/config/i3config" "$HOME/.config/i3/config"
ln -svf "$SPATH/config/Xresources" "$HOME/.Xresources"
ln -svf "$SPATH/config/cagelab-monitor.yaml" "$HOME/.config/tmuxp"
if [[ ! -f "$HOME/.tmux.conf" ]]; then
	ln -svf "$SPATH/config/tmux.conf" "$HOME/.tmux.conf"
fi
if [[ ! -f "$HOME/.config/starship.toml" ]]; then
	ln -svf "$SPATH/config/starship.toml" "$HOME/.config/starship.toml"
fi

# Ensure user ownership for everything created in home
chown -R "$USER":"$USER" "$HOME/bin" "$HOME/.local" "$HOME/.config" "$HOME/.ssh" "$HOME/.pixi" 2>/dev/null

# Final message and exit
echo "All done!" && exit 0
