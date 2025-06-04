# Setup

Scripts to set up a minimal system with required tools for CageLab / Opticka.

Clone this repo, cd to this folder, then run `bootstrap.sh` to install the required tools and set up the environment.

This installs zerotier, nomachine, x-cmd, pixi and pixi installs python and other command line tools. There is an option to install MATLAB using mpm, though currently it is not working due to a licence server incompatibility. We also

Critical tools:

1. [Zerotier](https://zerotier.com) is used for network access.
2. SSH and [NoMachine](https://www.nomachine.com) is used for remote access/desktop, tunneled only through Zerotier.
3. MATLAB [(see also mpm)](https://www.mathworks.com/products/mpm.html).
4. [x-cmd](https://www.x-cmd.com) for shell management, especially setting up chinese mirrors etc.
5. <https://pixi.sh> as a cross-platform package manager for other tools.
1. `awscli` is used to upload data to data server for Alyx.
1. `Python` with a specific version (V3.11 is needed for MATLAB R2024a) to use awscli. <https://mathworks.com/support/requirements/python-compatibility.html>
1. `Java` is used for matlab-jzmq, and needs to be a specific version (V17 for MATLAB 2024a). <https://mathworks.com/support/requirements/openjdk.html>

# TODO

We need to package cogmoteGO (possibly as a Conda package so we can install it with Pixi).

