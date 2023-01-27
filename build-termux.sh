#!/usr/bin/env bash

set -e

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1"
		read -r y || : && break
	done
	[ "$y" = y ]
}

pr "Setting up environment..."
yes "" | pkg update -y && pkg install -y git wget openssl jq openjdk-17 zip

pr "Cloning revanced-magisk-module repository..."
if [ -d revanced-magisk-module ]; then
	if ask "Directory revanced-magisk-module already exists. Do you want to clone the repo again? [y/n]"; then
		rm -rf revanced-magisk-module
		git clone https://github.com/j-hc/revanced-magisk-module --recurse --depth 1
		sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' revanced-magisk-module/config.toml
	fi
else
	git clone https://github.com/j-hc/revanced-magisk-module --recurse --depth 1
	sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' revanced-magisk-module/config.toml
fi
cd revanced-magisk-module

if ask "Do you want to open the config.toml for customizations? [y/n]"; then
	nano config.toml
else
	pr "No app is selected for patching."
fi
if ! ask "Setup is done. Do you want to start building? [y/n]"; then
	exit 0
fi

./build.sh