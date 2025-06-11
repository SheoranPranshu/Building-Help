#!/bin/bash

# --- Color Codes for Better Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Makefile SHA1 Hash Updater Script ---${NC}"

# --- Configuration ---
# The makefile you want to update.
# Common names are BoardConfigVendor.mk, proprietary-files.txt, etc.
MAKEFILE_IN="Android.mk"

# The name of the function call in your makefile.
# e.g., 'add-radio-file-sha1-checked' or 'add-vendor-file-sha1-checked'.
CHECKED_CALL="add-radio-file-sha1-checked"
# ---------------------

# --- Step 1: Validate Configuration and Environment ---
echo -e "\n${YELLOW}Step 1: Validating environment...${NC}"
if [ ! -f "$MAKEFILE_IN" ]; then
    echo -e "${RED}Error: Makefile '$MAKEFILE_IN' not found!${NC}"
    echo "Please check the filename or edit the script to set the correct MAKEFILE_IN."
    exit 1
fi
echo -e "${GREEN}  > Makefile '$MAKEFILE_IN' found.${NC}"

# Check if sha1sum command is available
if ! command -v sha1sum &> /dev/null; then
    echo -e "${RED}Error: 'sha1sum' command not found. Please install it (usually in 'coreutils').${NC}"
    exit 1
fi
echo -e "${GREEN}  > 'sha1sum' command is available.${NC}"

# --- Step 2: Process the Makefile ---
MAKEFILE_OUT="${MAKEFILE_IN}.new"
VENDOR_DIR=$(dirname "$MAKEFILE_IN")
cd "$VENDOR_DIR" || exit

echo -e "\n${YELLOW}Step 2: Processing '$MAKEFILE_IN' and calculating new hashes...${NC}"
echo "Temporary output will be written to '$MAKEFILE_OUT'"

# Initialize counters for the summary
updated_count=0
warning_count=0

# Create or clear the output file before the loop
> "$MAKEFILE_OUT"

# Read the input makefile line by line
while IFS= read -r line; do
    # Check if the line contains the function call we're looking for
    if [[ "$line" == *"$CHECKED_CALL"* ]]; then
        # Extract the file path (it's the second argument, between the first and second comma)
        filepath=$(echo "$line" | cut -d',' -f2 | xargs) # xargs trims whitespace

        if [ -f "$filepath" ]; then
            # Calculate the new SHA1 hash of the file
            new_hash=$(sha1sum "$filepath" | awk '{print $1}')
            
            # Use 'sed' to replace only the old hash
            new_line=$(echo "$line" | sed -E "s/,[ ]*[0-9a-f]{40}\)/,$new_hash\)/")

            if [[ "$line" != "$new_line" ]]; then
                echo -e "  ${GREEN}[UPDATED]${NC}  $filepath"
                ((updated_count++))
            fi
            echo "$new_line" >> "$MAKEFILE_OUT"
        else
            # If the file doesn't exist, print a warning and copy the original line
            echo -e "  ${YELLOW}[WARNING]${NC}  File not found: '$filepath'. Line copied without changes." >&2
            ((warning_count++))
            echo "$line" >> "$MAKEFILE_OUT"
        fi
    else
        # If it's not a line we need to process, just copy it to the new file
        echo "$line" >> "$MAKEFILE_OUT"
    fi
done < "$MAKEFILE_IN"

# --- Step 3: Review and Finalize ---
echo -e "\n${YELLOW}Step 3: Review and Finalize Changes...${NC}"

# Print a summary of what was done
echo "Processing complete. Summary:"
echo -e "  - ${GREEN}Hashes Updated: $updated_count${NC}"
echo -e "  - ${YELLOW}Warnings (File Not Found): $warning_count${NC}"

if [ "$updated_count" -eq 0 ]; then
    echo -e "\n${GREEN}No hashes needed updating. The original file is already correct.${NC}"
    rm "$MAKEFILE_OUT"
    exit 0
fi

echo -e "\nDisplaying differences (Original vs. New):"
echo "------------------------------------------"
# Use diff with color to make changes obvious
diff -u --color=always "$MAKEFILE_IN" "$MAKEFILE_OUT" || true
echo "------------------------------------------"

# Ask the user for confirmation before replacing the file
read -p "Do you want to apply these changes and replace '$MAKEFILE_IN'? (y/N) " -n 1 -r
echo # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\nReplacing original file..."
    mv "$MAKEFILE_OUT" "$MAKEFILE_IN"
    echo -e "${GREEN}  > Done. '$MAKEFILE_IN' has been updated.${NC}"
else
    echo -e "\nChanges not applied. The new file is saved as ${CYAN}'$MAKEFILE_OUT'${NC} for manual review."
fi

echo -e "\n${GREEN}--- Script finished ---${NC}"
