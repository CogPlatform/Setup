#!/bin/bash
# this script ensures the symlinks and folders are 
# all correct

export SPATH="$HOME/Code/Setup"

# Create some folders if not already existing
mkdir -p "$HOME/Code"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.config/tmuxp"
sudo chown -R "$USER":"$USER" /usr/local/bin # place our tools like mediamtx here
sudo chown -R "$USER":"$USER" /usr/local/etc # mediamtx config goes here

# Link pixi-global.toml
[[ ! -f "$HOME/.pixi/manifests/pixi-global.toml" ]] && mkdir -p $HOME/.pixi/manifests && ln -svf $SPATH/config/pixi-global.toml $HOME/.pixi/manifests/
[[ -f $(which pixi) ]] && pixi global sync

# link some cagelab stuff
ln -sfv "$SPATH/config/mediamtx.yml" "/usr/local/etc"
ln -svf "$HOME/Code/CageLab/software/scripts/"* "$HOME/bin"
ln -sfv "$HOME/Code/CageLab/software/services/"*.service "$HOME/.config/systemd/user"
# Link theConductor service for newer MATLAB if present
[[ -d "/usr/local/MATLAB/R2025a" ]] && ln -sfv "$HOME/Code/CageLab/software/services/theConductor2025a.dservice" "$HOME/.config/systemd/user/theConductor.service"
[[ -d "/usr/local/MATLAB/R2025b" ]] && ln -sfv "$HOME/Code/CageLab/software/services/theConductor2025b.dservice" "$HOME/.config/systemd/user/theConductor.service"

[[ ! -f "$HOME/.ssh/config" ]] && ln -svf "$HOME/Code/Setup/config/sshconfig" "$HOME/.ssh/config"
ln -sfv "$SPATH/config/.rsync-excludes" "$HOME/.config"

# Link .zshrc
[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.config/.zshrc"$(date -Iseconds)".bak
ln -svf "$SPATH/config/zshrc" "$HOME/.zshrc"
ln -svf "$SPATH/config/zsh-"* "$HOME/.config"
ln -svf "$SPATH/config/aliases" "$HOME/.config"

# few others
[[ ! -f "$HOME/.config/starship.toml" ]] && ln -svf "$SPATH/config/.tmux.conf" "$HOME"
ln -svf "$SPATH/config/cagelab-monitor.yaml" "$HOME/.config/tmuxp"
[[ ! -f "$HOME/.config/starship.toml" ]] && ln -svf "$SPATH/config/starship.toml" "$HOME/.config/starship.toml"
sudo cp "$SPATH/config/10-libuvc.rules" "/etc/udev/rules.d/"
