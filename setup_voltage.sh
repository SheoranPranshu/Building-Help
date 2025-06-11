#!/bin/bash

# --- Color Codes for Better Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Starting Device Tree Adaptation Script ---${NC}"

# --- Save original directory ---
original_dir="$PWD"
echo "Current directory saved: $original_dir"
echo

# --- Remove vendor/voltage-priv directory if present ---
echo -e "${YELLOW}Step 1: Cleaning up old directories...${NC}"
if [ -d "vendor/voltage-priv" ]; then
    echo "Found 'vendor/voltage-priv'. Removing it..."
    rm -rf vendor/voltage-priv
    echo -e "${GREEN}  > Done.${NC}"
else
    echo "'vendor/voltage-priv' directory not found. Skipping removal."
fi
echo

# --- Navigate to the target directory ---
TARGET_DIR="device/xiaomi/sm8250-common"
echo -e "${YELLOW}Step 2: Navigating to the target device directory...${NC}"
echo "Attempting to change directory to '$TARGET_DIR'..."
if cd "$TARGET_DIR"; then
    echo -e "${GREEN}  > Successfully navigated to '$PWD'.${NC}"
else
    echo -e "${RED}Error: Target directory '$TARGET_DIR' not found. Aborting.${NC}"
    exit 1
fi
echo

# --- Replace vendor/lineage and device/lineage strings ---
CONFIG_FILE="BoardConfigCommon.mk"
echo -e "${YELLOW}Step 3: Patching '$CONFIG_FILE' for VoltageOS...${NC}"
echo "Replacing 'vendor/lineage' with 'vendor/voltage'..."
sed -i 's|vendor/lineage|vendor/voltage|g' "$CONFIG_FILE"
echo "Replacing 'device/lineage' with 'device/voltage'..."
sed -i 's|device/lineage|device/voltage|g' "$CONFIG_FILE"
echo -e "${GREEN}  > All replacements in '$CONFIG_FILE' are complete.${NC}"
echo

# --- Rename dependencies file ---
OLD_DEPS="lineage.dependencies"
NEW_DEPS="voltage.dependencies"
echo -e "${YELLOW}Step 4: Renaming dependencies file...${NC}"
if [ -f "$OLD_DEPS" ]; then
    echo "Found '$OLD_DEPS'. Renaming it to '$NEW_DEPS'..."
    mv "$OLD_DEPS" "$NEW_DEPS"
    echo -e "${GREEN}  > File renamed successfully.${NC}"
else
    echo "'$OLD_DEPS' not found. Skipping rename."
    # Check if the new file already exists
    if [ -f "$NEW_DEPS" ]; then
        echo "Note: '$NEW_DEPS' already exists."
    fi
fi
echo

# --- Return to original directory ---
echo -e "${YELLOW}Step 5: Returning to the original directory...${NC}"
cd "$original_dir"
echo -e "${GREEN}  > Done. Now back in '$PWD'.${NC}"
echo

echo -e "${GREEN}--- Script finished successfully! ---${NC}"
