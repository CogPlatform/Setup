# Setup

Scripts to set up a minimal system with required tools

Clone this repo, cd to this folder, then run `bootstrap.sh` to install the required tools and set up the environment.

This installs x-cmd, pixi and pixi installs python and other command line tools.

Critical tools:

1. `awscli` is used to upload data to data server for Alyx
2. `Python` with a specific version is need by MATLAB to use awscli. <https://mathworks.com/support/requirements/python-compatibility.html>
3. `Java` is used for jzmq, and needs to be a specific version for MATLAB. <https://mathworks.com/support/requirements/openjdk.html>

# TODO

We need to package cogmoteGO as a Conda package so we can install it with Pixi.

For MATLAB, we need a Python version that supports the used matlab version
