#!/usr/bin/env bash

# Script to update patched upstream file to new version
# Usage: ./patch-upstream.sh <file_path> <from_version> <to_version>
# Example: ./patch-upstream.sh src/vs/workbench/api/worker/extensionHostWorker.ts v1.2.3 v1.3.0

set -e  # Exit on any error

# Check arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <file_path> <from_version> <to_version>"
    echo "Example: $0 src/vs/workbench/api/worker/extensionHostWorker.ts v1.2.3 v1.3.0"
    exit 1
fi

FILE_PATH="$1"
FROM_VERSION="$2"
TO_VERSION="$3"
GITHUB_REPO="microsoft/vscode"

# Extract base filename and extension from file path
BASE_FILENAME=$(basename "$FILE_PATH")
BASE_FILENAME_NO_EXT="${BASE_FILENAME%.*}"
FILE_EXT="${BASE_FILENAME##*.}"

# File names
CURRENT_PATCHED="${BASE_FILENAME_NO_EXT}.${FILE_EXT}"
OLD_UPSTREAM="${BASE_FILENAME_NO_EXT}.${FROM_VERSION}.${FILE_EXT}"  # Existing baseline for from_version
NEW_UPSTREAM="${BASE_FILENAME_NO_EXT}.${TO_VERSION}.${FILE_EXT}"    # New version we'll download
MERGED_RESULT="${BASE_FILENAME_NO_EXT}.${TO_VERSION}.${FILE_EXT}.patched"

# Check if required files exist
if [ ! -f "$CURRENT_PATCHED" ]; then
    echo "Error: $CURRENT_PATCHED not found"
    exit 1
fi

if [ ! -f "$OLD_UPSTREAM" ]; then
    echo "Error: $OLD_UPSTREAM not found (baseline for $FROM_VERSION)"
    echo "Expected file: $OLD_UPSTREAM"
    exit 1
fi

echo "File: $FILE_PATH"
echo "Base filename: $BASE_FILENAME_NO_EXT"
echo "Extension: $FILE_EXT"
echo ""

echo "Downloading $TO_VERSION from GitHub..."
DOWNLOAD_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/refs/tags/${TO_VERSION#v}/${FILE_PATH}"
echo "URL: $DOWNLOAD_URL"

# Download the new version
if curl -f -L "$DOWNLOAD_URL" -o "$NEW_UPSTREAM"; then
    echo "Successfully downloaded $NEW_UPSTREAM"
else
    echo "Error: Failed to download from $DOWNLOAD_URL"
    echo "Check that the repo, version, and file path are correct"
    exit 1
fi

echo "Performing 3-way merge..."
echo "  Current patched: $CURRENT_PATCHED"
echo "  Original base:   $OLD_UPSTREAM"  
echo "  New upstream:    $NEW_UPSTREAM"
echo "  Result:          $MERGED_RESULT"

# Perform the 3-way merge
if git merge-file -p "$CURRENT_PATCHED" "$OLD_UPSTREAM" "$NEW_UPSTREAM" > "$MERGED_RESULT"; then
    echo "✓ Clean merge completed successfully!"
    echo "Review $MERGED_RESULT and rename to $CURRENT_PATCHED when ready"
else
    echo "⚠ Merge completed with conflicts!"
    echo "Check $MERGED_RESULT for conflict markers (<<<<<<< ======= >>>>>>>)"
    echo "Resolve conflicts manually, then rename to $CURRENT_PATCHED when ready"
fi

echo ""
echo "Next steps:"
echo "1. Review $MERGED_RESULT"
echo "2. If satisfied, run:"
echo "   mv $MERGED_RESULT $CURRENT_PATCHED"
echo