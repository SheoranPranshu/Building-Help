#!/bin/sh

# Exit immediately if any command fails
set -e

# Navigate to build/soong directory
cd build/soong

# Add remote and cherry-pick commits
git remote add l https://github.com/AxionAOSP/android_build_soong.git
git fetch l lineage-22.2
git cherry-pick 1218ccfca0ffeefbe089f73af58cdcbbee53e89a
git cherry-pick 1409570931f88bfe23f0d48e0cbb2329d87ddfd1
git cherry-pick f5c4c61cfd2e495e504f432c419bcccdaf26df88

# Return to original directory
cd ../..
