#!/bin/bash

# --- Configuration ---
# The makefile you want to update.
# Common names are BoardConfigVendor.mk, device-vendor.mk, etc.
MAKEFILE_IN="Android.mk"

# The name of the function call in your makefile.
# This is usually 'add-radio-file-sha1-checked' or 'add-vendor-file-sha1-checked'.
CHECKED_CALL="add-radio-file-sha1-checked"
# ---------------------

# --- Script Logic ---
if [ ! -f "$MAKEFILE_IN" ]; then
    echo "ERROR: Makefile '$MAKEFILE_IN' not found!"
    echo "Please edit the script to set the correct MAKEFILE_IN."
    exit 1
fi

MAKEFILE_OUT="${MAKEFILE_IN}.new"
VENDOR_DIR=$(dirname "$MAKEFILE_IN")
cd "$VENDOR_DIR" || exit

echo "Processing '$MAKEFILE_IN'..."
echo "Output will be written to '$MAKEFILE_OUT'"
> "$MAKEFILE_OUT" # Create or clear the output file

# Read the input makefile line by line
while IFS= read -r line; do
    # Check if the line contains the function call we're looking for
    if [[ "$line" == *"$CHECKED_CALL"* ]]; then
        # Extract the file path (it's the second argument, between the first and second comma)
        filepath=$(echo "$line" | cut -d',' -f2 | xargs) # xargs trims whitespace

        if [ -f "$filepath" ]; then
            # Calculate the new SHA1 hash of the file
            new_hash=$(sha1sum "$filepath" | awk '{print $1}')

            # Use 'sed' with a regular expression to replace the old hash
            # This regex finds a comma, optional whitespace, 40 hex characters, and a closing parenthesis
            new_line=$(echo "$line" | sed -E "s/,[ ]*[0-9a-f]{40}\)/,$new_hash\)/")

            echo "  Updated: $filepath"
            echo "$new_line" >> "$MAKEFILE_OUT"
        else
            # If the file doesn't exist, print a warning and copy the original line
            echo "  WARNING: File not found: '$filepath'. Line kept as-is." >&2
            echo "$line" >> "$MAKEFILE_OUT"
        fi
    else
        # If it's not a line we need to process, just copy it to the new file
        echo "$line" >> "$MAKEFILE_OUT"
    fi
done < "$MAKEFILE_IN"

echo "---"
echo "Done! A new makefile has been created: '$MAKEFILE_OUT'"
echo "Please review it for correctness and then replace the old one:"
echo "mv '$MAKEFILE_OUT' '$MAKEFILE_IN'"
