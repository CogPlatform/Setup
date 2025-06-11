#!/bin/bash
export PLATFORM=$(uname)
export ARCH=$(uname -m)
export SPATH=$(pwd)
uname -a | grep -iq "microsoft" && MOD="WSL"
uname -a | grep -iq "aarch64|armv7" && MOD="RPi"
PLATFORM=$(uname -s)$MOD

printf "\n\n--->>> Bootstrap terminal %s setup, current directory is %s\n\n" "$SHELL" "$SPATH"
printf '\e[36m'
printf "Using %s...\n" "$PLATFORM"
printf '\e[0m'

# Create some folders
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.config/systemd/user"

# this section disables the touch screen at start
# replace with name of the touch panel device
# you can find the name by running `xinput list` in a terminal
# and looking for the device that corresponds to your touch panel
name="ILITEK-TP" # CHANGE THIS TO YOUR TOUCH PANEL NAME
sd '^(ExecStart=\/usr\/local\/bin\/toggleInput [^ ]+ ).*$' '$1 "'$name'"' ./config/toggleInput.service
sudo ln -svf $SPATH/config/toggleInput /usr/local/bin/toggleInput
sudo chmod +x /usr/local/bin/toggleInput
sudo ln -svf $SPATH/config/toggleInput.service $HOME/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable toggleInput.service
systemctl --user start toggleInput.service

# Install X-CMD
[[ ! -d $HOME/.x-cmd.root ]] && eval "$(curl https://get.x-cmd.com)"

# Install Pixi
[[ ! -d $HOME/.pixi/bin ]] && eval curl -fsSL https://pixi.sh/install.sh | bash

# Install eget and get cogmoteGO and mediamtx
curl https://zyedidia.github.io/eget.sh | sh
eget Ccccraz/cogmoteGO --to=/usr/local/bin
eget bluenviron/mediamtx --to=/usr/local/bin
ln -svf /usr/local/bin/mediamtx $HOME/.local/bin
eget LizardByte/Sunshine --to=./
#sudo dpkg -i ./sunshine-ubuntu-24.04-amd64.deb

# Install Zerotier
curl -s https://install.zerotier.com | sudo bash
sudo systemctl enable zerotier-one.service
sudo zerotier-cli info

# Install NoMachine
curl -o $HOME/nomachine.deb -L https://download.nomachine.com/download/8.16/Linux/nomachine_8.16.1_1_amd64.deb
sudo dpkg -i $HOME/nomachine.deb

# Link pixi-global.toml
mkdir -p $HOME/.pixi/manifests
ln -svf $SPATH/config/pixi-global.toml $HOME/.pixi/manifests/
pixi global sync

# [Optional] Install MATLAB with MPM
printf "Shall we use MPM to get MATLAB? [y / n]:  "
read -r ans
if [[ $ans == 'y' ]]; then
	curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/glnxa64/mpm
	version="R2024a"
	products='MATLAB Curve_Fitting_Toolbox Instrument_Control_Toolbox MATLAB_Report_Generator Optimization_Toolbox Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox'
	mkdir -p "$HOME/matlab$version"
	mpath="$HOME/matlab$version"z
	$HOME/bin/mpm install --no-gpu --no-jre --release=$version --destination=$HOME/matlab$version --products=$products
fi

# APT + snap + flatpak packages
if [ "$PLATFORM" = "Linux" ]; then
	sudo apt -my install build-essential zsh git gparted vim curl file mc
	sudo apt -my install gawk mesa-utils exfatprogs
	sudo apt -my install freeglut3-dev 
	sudo apt -my install libglut-dev
	sudo apt -my install openssh-server
	sudo apt -my install p7zip-full p7zip-rar figlet jq htop 
	sudo apt -my install libunrar5 libdc1394-25 libraw1394-11
	sudo apt -my install gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly
	sudo apt -my install synaptic zathura
	sudo apt -my install snapd python3-pip
	sudo apt -my install openjdk-17-jre
	sudo apt -my install flatpak

	sudo snap install core arduino rpi-imager obs-studio
	sudo snap install --classic code

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub com.obsproject.Studio
	
fi

# Clone core repos
mkdir -p $HOME/Code
cd $HOME/Code
git clone --recurse-submodules https://gitee.com/CogPlatform/Psychtoolbox.git
git clone --recurse-submodules https://gitee.com/CogPlatform/opticka.git
git clone --recurse-submodules https://gitee.com/CogPlatform/CageLab.git
git clone --recurse-submodules https://gitee.com/CogPlatform/matlab-jzmq.git
git clone --recurse-submodules https://gitee.com/Ccccraz/matmoteGO.git

# PTB expects libglut.so.3 but this is not present in Ubuntu 24.04 and later.
# The following line creates a symlink to the libglut.so.3.12.0 file, which is the version available in Ubuntu 24.04 and later.
# This allows PTB to find the library it needs to function correctly.
[[ -f "/usr/lib/x86_64-linux-gnu/libglut.so.3.12.0" ]] && sudo ln -svf /usr/lib/x86_64-linux-gnu/libglut.so.3.12.0 /usr/lib/x86_64-linux-gnu/libglut.so.3

# Setup PTB and opticka path:
cd "$HOME/Code/Psychtoolbox"
$mpath/matlab -nodesktop -nosplash -r "SetupPsychToolbox; pause(1); cd ../../opticka; addOptickaToPath; pause(1); exit"

cd "$HOME"

# Link .zshrc
[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc"$(date -Iseconds)".bak
ln -svf "$SPATH/config/zshrc" "$HOME/.zshrc"
ln -svf "$SPATH/config/zsh-history-substring-search.zsh" "$HOME"
ln -svf "$SPATH/config/zsh-autosuggestions.zsh" "$HOME"
ln -svf "$SPATH/config/aliases" "$HOME/aliases"

# few others
ln -svf "$SPATH/config/.tmux.conf" "$HOME"
ln -svf "$SPATH/config/starship.toml" "$HOME/.config/starship.toml"

# switch from bash to zsh as the default shell
if [ -x "$(which zsh)" ]; then
	printf 'Switching to use ZSH, you will need to reboot...\n'
	chsh -s "$(which zsh)" && source ~/.zshrc
fi
printf '\n\n--->>> All Done...\n'
printf '\e[m'