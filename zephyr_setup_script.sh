#!/bin/bash

# This script sets up Zephyr on Ubuntu 20.04 LTS and later

# Update and upgrade system packages
sudo apt update
sudo apt upgrade -y

# Download and run Kitware archive setup script
wget https://apt.kitware.com/kitware-archive.sh
sudo bash kitware-archive.sh

# Install necessary packages
sudo apt install --no-install-recommends -y git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

# Verify installations
cmake --version
python3 --version
dtc --version

# Setup Python virtual environment
sudo apt install -y python3-venv
python3 -m venv ~/zephyrproject/.venv
source ~/zephyrproject/.venv/bin/activate
deactivate

# Install West and initialize Zephyr project
pip install west
west init ~/zephyrproject
cd ~/zephyrproject
west update

# Export Zephyr environment
west zephyr-export

# Install Python dependencies for Zephyr
pip install -r ~/zephyrproject/zephyr/scripts/requirements.txt

# Download and setup Zephyr SDK
cd ~
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/zephyr-sdk-0.16.8_linux-x86_64.tar.xz
wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/sha256.sum | shasum --check --ignore-missing
tar xvf zephyr-sdk-0.16.8_linux-x86_64.tar.xz
cd zephyr-sdk-0.16.8
./setup.sh

# Configure udev rules for OpenOCD
sudo cp ~/zephyr-sdk-0.16.8/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload

# Build a sample Zephyr application
cd ~/zephyrproject/zephyr
west build -p always -b rpi_4b samples/basic/blinky

