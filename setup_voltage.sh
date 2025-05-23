#!/bin/bash

# Save original directory
original_dir="$PWD"

# Remove vendor/voltage-priv directory if present
echo "Removing vendor/voltage-priv directory if present..."
rm -rf vendor/voltage-priv

# Navigate to the target directory
cd device/xiaomi/sm8250-common || { echo "Error: Target directory not found"; exit 1; }

# Replace vendor/lineage and device/lineage strings
sed -i 's|vendor/lineage|vendor/voltage|g' BoardConfigCommon.mk
sed -i 's|device/lineage|device/voltage|g' BoardConfigCommon.mk

# Rename dependencies file
mv lineage.dependencies voltage.dependencies 2>/dev/null || echo "Warning: File rename failed - check filename/path"

# Return to original directory
cd "$original_dir"
