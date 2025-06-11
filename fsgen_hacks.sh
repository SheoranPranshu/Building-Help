#!/bin/bash

# --- Color Codes for Better Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Starting Soong Patching Script ---${NC}"

# Exit immediately if any command fails. This is crucial for preventing
# a partially patched state if a cherry-pick has a conflict.
set -e

# --- Save current directory to return to it later ---
original_dir="$PWD"

# --- Define key variables for easy modification ---
TARGET_DIR="build/soong"
REMOTE_NAME="axion_soong" # A more descriptive remote name
REMOTE_URL="https://github.com/AxionAOSP/android_build_soong.git"
REMOTE_BRANCH="lineage-22.2"

# --- Navigate to the build/soong directory ---
echo -e "\n${YELLOW}Step 1: Navigating to the Soong directory...${NC}"
echo "Changing directory to '$TARGET_DIR'."
cd "$TARGET_DIR"
echo -e "${GREEN}  > Successfully in '$PWD'.${NC}"

# --- Add git remote, checking if it already exists ---
echo -e "\n${YELLOW}Step 2: Setting up git remote...${NC}"
# This check prevents an error if the script is run more than once.
if git remote | grep -q "^${REMOTE_NAME}$"; then
    echo "Remote '$REMOTE_NAME' already exists. Ensuring URL is correct."
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
else
    echo "Adding new remote '$REMOTE_NAME' from '$REMOTE_URL'."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi
echo -e "${GREEN}  > Remote setup complete.${NC}"

# --- Fetch the required branch from the remote ---
echo -e "\n${YELLOW}Step 3: Fetching updates from the remote...${NC}"
echo "Fetching branch '$REMOTE_BRANCH' from remote '$REMOTE_NAME'..."
git fetch "$REMOTE_NAME" "$REMOTE_BRANCH"
echo -e "${GREEN}  > Fetch complete.${NC}"

# --- Cherry-pick the necessary commits ---
echo -e "\n${YELLOW}Step 4: Cherry-picking required commits...${NC}"
# Storing commits in an array makes them easier to manage
COMMITS_TO_PICK=(
    "1218ccfca0ffeefbe089f73af58cdcbbee53e89a"
    "1409570931f88bfe23f0d48e0cbb2329d87ddfd1"
    "f5c4c61cfd2e495e504f432c419bcccdaf26df88"
)

# Loop through the array and cherry-pick each commit
for commit in "${COMMITS_TO_PICK[@]}"; do
    echo -e "  -> Applying commit ${CYAN}${commit:0:12}${NC}..."
    git cherry-pick "$commit"
done

echo -e "${GREEN}  > All commits have been cherry-picked successfully.${NC}"

# --- Return to the original directory ---
echo -e "\n${YELLOW}Step 5: Returning to the starting directory...${NC}"
cd "$original_dir"
echo -e "${GREEN}  > Done. Now back in '$PWD'.${NC}"

echo -e "\n${GREEN}--- Soong patching script finished successfully! ---${NC}"
