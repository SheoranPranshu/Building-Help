#!/usr/bin/env bash

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}Starting DerpFest setup...${RESET}"

# Create and enter derp directory
cd ~ || exit 1
mkdir -p derp

# Run keys setup
echo -e "${YELLOW}Running keys setup...${RESET}"
./keys/setup.sh derp/

cd derp || exit 1

# Initialize and sync repo
echo -e "${YELLOW}Initializing repo...${RESET}"
repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 16 --git-lfs --depth 1

echo -e "${YELLOW}Syncing repo... (this may take some time)${RESET}"
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8

# Replace qcom audio
echo -e "${YELLOW}Replacing QCOM CAF sm8250 audio...${RESET}"
rm -rf hardware/qcom-caf/sm8250/audio
git clone https://github.com/LineageOS/android_hardware_qcom_audio.git -b lineage-22.2-caf-sm8250 hardware/qcom-caf/sm8250/audio

# Remove unwanted vibrator
rm -rf hardware/xiaomi/vibrator

# Cherry-pick in bionic
cd bionic || exit 1
git remote add l https://github.com/Project-Flare-Staging/bionic.git
git fetch l
git cherry-pick 8c4c3364d571ab5045cec08f7c0d5d5886ad8c9a
cd ..

# Clone device tree
git clone git@github.com:glitch-wraith/android_device_xiaomi_pipa.git device/xiaomi/pipa

# Build environment setup with automated input (choose 2, then N)
echo -e "${YELLOW}Running build/envsetup.sh with automated input...${RESET}"
printf "2\nN\n" | . build/envsetup.sh

# Lunch command
lunch lineage_pipa-bp2a-user

# Start build
echo -e "${GREEN}Starting build (mka derp)...${RESET}"
mka derp

echo -e "${GREEN}Build script completed!${RESET}"
