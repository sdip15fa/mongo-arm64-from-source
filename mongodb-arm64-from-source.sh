#!/usr/bin/env sh

echo """deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse

deb [arch=amd64] http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb [arch=amd64] http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb [arch=amd64] http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse""" > sources.list

sudo mv sources.list /etc/apt/sources.list

ls /etc/apt
cat /etc/apt/sources.list

sudo dpkg --add-architecture arm64
sudo apt-get update -y
# !sudo apt-get upgrade
sudo apt-get install openssl gcc-10-aarch64-linux-gnu g++-10-aarch64-linux-gnu libssl-dev liblzma-dev libcurl4-openssl-dev -y
# !sudo apt-get remove libcurl4-openssl-dev
sudo apt-get install  libcurl4:arm64 openssl:arm64 libssl-dev:arm64 liblzma-dev:arm64 libcurl4-openssl-dev:arm64 -y
# !sudo apt-get --fix-broken install
# !sudo apt-get --fix-broken install

git clone -b v6.2 https://github.com/mongodb/mongo.git

cd mongo

# Consider using a virtualenv for this
python3 -m pip install --user -r etc/pip/compile-requirements.txt

sed -i "s/env.ConfError(\"Failed to detect a supported target architecture\")/pass/g" mongo/SConstruct
sed -i "s/env.ConfError(\"Could not detect processor specified in TARGET_ARCH variable\")/pass/g"  mongo/SConstruct
sed -i "s/env['TARGET_ARCH'] = detected_processor/env['TARGET_ARCH'] = 'aarch64'/g" mongo/SConstruct

python3 buildscripts/scons.py --ssl=off  CC=/usr/bin/aarch64-linux-gnu-gcc-10 CXX=/usr/bin/aarch64-linux-gnu-g++-10 TARGET_ARCH="aarch64" DESTDIR="bin" CCFLAGS="-march=armv8-a+crc -mtune=cortex-a72" install-servers -j8 --force-jobs

