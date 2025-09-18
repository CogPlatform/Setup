#!/bin/bash
export PLATFORM=$(uname)
export ARCH=$(uname -m)
export SPATH="$HOME/Code/Setup"
uname -a | grep -iq "microsoft" && MOD="WSL"
uname -a | grep -iq "aarch64|armv7" && MOD="RPi"
PLATFORM=$(uname -s)$MOD

sudo apt install git
sudo apt install curl

printf "\n\n--->>> Bootstrap terminal %s setup, current directory is %s\n\n" "$SHELL" "$SPATH"
printf '\e[36m'
printf "Using %s...\n" "$PLATFORM"
printf '\e[0m'

# Create some folders
mkdir -p "$HOME/Code"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.config/tmuxp"
sudo chown -R "$USER":"$USER" /usr/local/bin

# this section disables the touch screen at start
# replace with name of the touch panel device
# you can find the name by running `xinput list` in a terminal
# and looking for the device that corresponds to your touch panel
# CHANGE name TO YOUR TOUCH PANEL NAME
name="ILITEK-TP"
sd '^(ExecStart=\/usr\/local\/bin\/toggleInput [^ ]+ ).*$' '$1"'$name'"' "$SPATH/config/toggleInput.service"
sudo ln -svf "$SPATH/config/toggleInput" /usr/local/bin/toggleInput &&
	sudo chmod +x /usr/local/bin/toggleInput &&
	sudo ln -svf "$SPATH/config/toggleInput.service" "$HOME/.config/systemd/user" &&
	systemctl --user daemon-reload &&
	systemctl --user enable toggleInput.service &&
	systemctl --user start toggleInput.service

# Install X-CMD
[[ ! -d $HOME/.x-cmd.root ]] && eval "$(curl https://get.x-cmd.com)"

# Install Pixi
[[ ! -d $HOME/.pixi/bin ]] && eval curl -fsSL https://pixi.sh/install.sh | bash

# Install Netbird
# Use the setup key from our password manager to replace XXX
[[ ! -f $(which netbird) ]] && curl -fsSL https://pkgs.netbird.io/install.sh | sh
printf "Enter a KEY to register netbird (blank to ignore): "
read -r ans
if [[ -n $ans ]]; then
	netbird up --setup-key $ans
fi

# [Optional] Install MATLAB with MPM
printf "Shall we use MPM to get MATLAB? [y / n]:  "
read -r ans
if [[ $ans == 'y' ]]; then
	version="R2025a"
	products='MATLAB Curve_Fitting_Toolbox Instrument_Control_Toolbox MATLAB_Report_Generator Optimization_Toolbox Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox'
	curl -L -o /usr/local/bin/mpm https://www.mathworks.com/mpm/glnxa64/mpm
	chmod +x /usr/local/bin/mpm
	sudo mkdir -p /usr/local/MATLAB &&
	sudo chown "$USER":"$USER" /usr/local/MATLAB &&
	sudo chmod 777 /usr/local/MATLAB &&
	/usr/local/bin/mpm install --release=$version --products=$products
fi

# APT + snap + flatpak packages
if [ "$PLATFORM" = "Linux" ]; then
	sudo apt --fix-broken install
	sudo apt update && sudo apt -y upgrade
	sudo apt -my install apt-transport-https ca-certificates software-properties-common
	sudo apt -my install build-essential zsh git gparted vim curl file mc
	sudo apt -my install gawk mesa-utils exfatprogs
	sudo apt -my install freeglut3-dev 
	sudo apt -my install libglut-dev
	sudo apt -my install openssh-server
	sudo apt -my install i3 rofi nitrogen
	sudo apt -my install p7zip-full p7zip-rar figlet jq htop 
	sudo apt -my install libunrar5 libdc1394-25 libraw1394-11
	sudo apt -my install gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly
	sudo apt -my install synaptic zathura zathura-pdf-poppler zathura-ps
	sudo apt -my install snapd python3-pip
	sudo apt -my install openjdk-17-jre
	sudo apt -my install flatpak

	sudo snap install --classic code

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub com.obsproject.Studio
	
fi

# install or update cogmoteGO
curl -sS https://raw.githubusercontent.com/Ccccraz/cogmoteGO/main/install.sh | sh &&
	cogmoteGO service &&
	cogmoteGO service start

# Install NoMachine
[[ ! -f /usr/NX/bin/nxd ]] && 
	curl -o $HOME/nomachine.deb -L https://web9001.nomachine.com/download/9.0/Linux/nomachine_9.0.188_11_amd64.deb && 
	sudo dpkg -i $HOME/nomachine.deb

# Install eget and get mediamtx and sunshine
[[ ! -f /usr/local/bin/eget ]] && curl https://zyedidia.github.io/eget.sh | sh && chmod +x eget && mv eget /usr/local/bin/eget
[[ ! -f /usr/local/bin/mediamtx ]] && eget bluenviron/mediamtx --to=/usr/local/bin && ln -svf /usr/local/bin/mediamtx $HOME/.local/bin
[[ ! -f /usr/bin/sunshine ]] && eget LizardByte/Sunshine -a '24.04' --to=./sunshine.deb && sudo dpkg -i ./sunshine.deb
[[ ! -f /usr/bin/rotz ]] && eget volllly/rotz --to=/usr/local/bin

# Clone our core repos
mkdir -p "$HOME/Code"
cd "$HOME/Code" || exit
[[ ! -d 'Setup' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/Setup.git
[[ ! -d 'Psychtoolbox' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/Psychtoolbox.git
[[ ! -d 'opticka' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/opticka.git
[[ ! -d 'CageLab' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/CageLab.git
[[ ! -d 'matlab-jzmq' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/matlab-jzmq.git
[[ ! -d 'matmoteGO' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/matmoteGO.git
[[ ! -d 'PTBSimia' ]] && git clone --recurse-submodules https://gitee.com/CogPlatform/PTBSimia.git
cd ~ || exit

# PTB expects libglut.so.3 but this is not present in Ubuntu 24.04 and later.
# The following line creates a symlink to the libglut.so.3.12.0 file, which is the version available in Ubuntu 24.04 and later.
# This allows PTB to find the library it needs to function correctly.
[[ -f "/usr/lib/x86_64-linux-gnu/libglut.so.3.12.0" ]] && 
	sudo ln -svf /usr/lib/x86_64-linux-gnu/libglut.so.3.12.0 /usr/lib/x86_64-linux-gnu/libglut.so.3

# Setup PTB and opticka path:
#cd "$HOME/Code/Psychtoolbox" || exit
#$mpath/matlab -nodesktop -nosplash -r "SetupPsychToolbox; pause(1); cd ../../opticka; addOptickaToPath; pause(1); exit"

cd "$HOME" || exit

# Link pixi-global.toml
rm -rf $HOME/.pixi/manifests
mkdir -p $HOME/.pixi/manifests && ln -svf $SPATH/config/pixi-global.toml $HOME/.pixi/manifests/
[[ -f $(which pixi) ]] && pixi global sync

# link some cagelab scripts
ln -svf "$HOME/Code/CageLab/software/scripts/"* "$HOME/bin"

# Link .zshrc
[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc"$(date -Iseconds)".bak
ln -svf "$SPATH/config/zshrc" "$HOME/.zshrc"
ln -svf "$SPATH/config/zsh-"* "$HOME"
ln -svf "$SPATH/config/aliases" "$HOME/aliases"

# few others
ln -svf "$SPATH/config/.tmux.conf" "$HOME"
ln -svf "$SPATH/config/cagelab-monitor.yaml" "$HOME/.config/tmuxp"
ln -svf "$SPATH/config/starship.toml" "$HOME/.config/starship.toml"
sudo cp "$SPATH/config/10-libuvc.conf" "/etc/udev/rules.d/"

# switch from bash to zsh as the default shell
if [ $SHELL == "/bin/bash" ] && [ -x "$(which zsh)" ]; then
	printf 'Switching to use ZSH, you will need to reboot...\n'
	chsh -s "$(which zsh)"
fi
printf '\n\n--->>> All Done...\n'
printf '\e[m'
