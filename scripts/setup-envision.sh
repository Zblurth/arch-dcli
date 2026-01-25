#!/bin/bash
# Installs Envision AppImage from latest GitLab CI Artifacts
# Managed by dcli - apps/vr module

APP_DIR="$HOME/Applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
DESKTOP_DIR="$HOME/.local/share/applications"
TEMP_DIR="/tmp/envision_install"

# GitLab Direct Artifact URL (Latest from main branch)
ARTIFACT_URL="https://gitlab.com/gabmus/envision/-/jobs/artifacts/main/download?job=appimage"
# The project uses RDNN: org.gabmus.envision
ICON_URL="https://gitlab.com/gabmus/envision/-/raw/main/data/icons/org.gabmus.envision.svg"

# Ensure directories exist
mkdir -p "$APP_DIR" "$ICON_DIR" "$DESKTOP_DIR" "$TEMP_DIR"

echo "--> Fetching latest Envision build from GitLab CI..."

# Download and extract
if wget -q --show-progress -O "$TEMP_DIR/artifacts.zip" "$ARTIFACT_URL"; then
    unzip -q -o "$TEMP_DIR/artifacts.zip" -d "$TEMP_DIR"
    
    # Find the AppImage in the extracted files
    APPIMAGE_PATH=$(find "$TEMP_DIR" -name "*.AppImage" | head -n 1)
    
    if [ -f "$APPIMAGE_PATH" ]; then
        FILENAME=$(basename "$APPIMAGE_PATH")
        mv "$APPIMAGE_PATH" "$APP_DIR/$FILENAME"
        chmod +x "$APP_DIR/$FILENAME"
        
        # Symlink for stability
        ln -sf "$APP_DIR/$FILENAME" "$APP_DIR/envision.AppImage"
        echo "✓ Successfully installed $FILENAME"
    else
        echo "error: Could not find AppImage in artifacts."
        exit 1
    fi
else
    echo "error: Failed to download artifacts from GitLab."
    exit 1
fi

# Download Icon
echo "--> Fetching icon..."
if wget -q -O "$ICON_DIR/org.gabmus.envision.svg" "$ICON_URL"; then
    echo "✓ Icon downloaded."
else
    echo "    Warning: Could not fetch icon from $ICON_URL"
    # Fallback: create a dummy if it fails so the desktop file doesn't break
    touch "$ICON_DIR/org.gabmus.envision.svg"
fi

# Create Desktop Entry
echo "--> Updating Desktop Entry..."
cat > "$DESKTOP_DIR/org.gabmus.envision.desktop" <<EOF
[Desktop Entry]
Name=Envision
Comment=WiVRn/Monado Configuration Tool
Exec=$APP_DIR/envision.AppImage
Icon=org.gabmus.envision
Terminal=false
Type=Application
Categories=Utility;Settings;
Keywords=VR;Monado;WiVRn;
StartupWMClass=envision
EOF

# Cleanup
rm -rf "$TEMP_DIR"

# Refresh database
if command -v update-desktop-database >/dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

echo "✓ Envision setup complete."
