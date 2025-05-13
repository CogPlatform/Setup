#!/bin/bash
printf "\n\n--->>> Bootstrap terminal %s setup, current directory is %s\n\n" "$SHELL" "$(pwd)"
printf '\e[36m'
export PLATFORM=$(uname)
export ARCH=$(uname -m)
uname -a | grep -iq "microsoft" && MOD="WSL"
uname -a | grep -iq "aarch64|armv7" && MOD="RPi"
PLATFORM=$(uname -s)$MOD
printf "Using %s...\n" "$PLATFORM"
printf '\e[0m'

# Install XCMD
[[ ! -d $HOME/.x-cmd.root ]] && eval "$(curl https://get.x-cmd.com/x7)"

# Install Pixi
[[ ! -d $HOME/.pixi ]] && eval curl -fsSL https://pixi.sh/install.sh | bash

# Add pixi-global.toml
mkdir -p $HOME/.pixi/manifests
ln -sf ./pixi-global.toml $HOME/.pixi/manifests/pixi-global.toml
pixi global sync

# Install MATLAB
if [ "$PLATFORM" = "Linux" ]; then
	curl -L -o ~/bin/mpm https://www.mathworks.com/mpm/glnxa64/mpm
 	version="R2024a"
 	products='MATLAB Curve_Fitting_Toolbox Instrument_Control_Toolbox MATLAB_Report_Generator Optimization_Toolbox Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox'
	$E:HOME/bin/mpm install --no-gpu --no-jre --release=$version --destination=$E:HOME/matlab$version --products=$products
fi
 
# Create bin folder
mkdir -p $HOME/bin

if [ "$PLATFORM" = "Linux" ]; then
	sudo apt -my install build-essential zsh git gparted vim curl file mc
	sudo apt -my install freeglut3 gawk mesa-utils exfatprogs
	sudo apt -my install p7zip-full p7zip-rar figlet jq ansiweather htop 
	sudo apt -my install libunrar5 libdc1394-25 libraw1394-11
	sudo apt -my install synaptic zathura
	sudo apt -my install snapd python3-pip
	sudo apt -my install openjdk-17-jre
	sudo snap install core code arduino rpi-imager obs-studio
fi

# Clone repos
mkdir -p $HOME/Code
cd $HOME/Code
git clone --depth 1 https://github.com/CogPlatform/Psychtoolbox-3
git clone --recurse-submodules https://github.com/iandol/opticka.git
git clone --recurse-submodules https://github.com/CogPlatform/CageLab.git
git clone --recurse-submodules https://github.com/CogPlatform/matlab-jzmq.git
git clone --recurse-submodules https://github.com/Ccccraz/matmoteGO.git

# Setup PTB:
cd $HOME/Code/Psychtoolbox-3/Psychtoolbox
matlab -nodesktop -nosplash -r "SetupPsychToolbox; Pause(1); exit"

# Setup opticka path
cd $HOME/Code/opticka
matlab -nodesktop -nosplash -r "addOptickaToPath; Pause(1); exit"

# Copy .zshrc
[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc"$(date -Iseconds)".bak
cp "$(pwd)/zshrc" "$HOME/.zshrc"
cp "$(pwd)/aliases" "$HOME/aliases"

# switch from bash to zsh as the default shell
if [ -x "$(which zsh)" ]; then
	printf 'Switching to use ZSH, you will need to reboot...\n'
	chsh -s "$(which zsh)" && source ~/.zshrc
fi
printf '\n\n--->>> All Done...\n'
printf '\e[m'
