#!/bin/bash
# Automates updating WiVRn APK on connected Android/VR devices
# Bypasses Envision's internal downloader if it fails.

TEMP_DIR="/tmp/wivrn_update"
mkdir -p "$TEMP_DIR"

echo "--> Checking for connected devices..."
if ! adb devices | grep -q "device$"; then
    echo "Error: No ADB device connected. Connect your Pico 4 via USB."
    exit 1
fi

echo "--> Fetching latest release info from GitHub..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/WiVRn/WiVRn/releases/latest | grep "browser_download_url" | grep ".apk" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find APK download URL."
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")
echo "--> Downloading $FILENAME..."
wget -q --show-progress -O "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"

echo "--> Installing to device..."
adb install -r "$TEMP_DIR/$FILENAME"

echo "✓ WiVRn updated successfully."
rm -rf "$TEMP_DIR"
