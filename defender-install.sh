#!/bin/bash

set -euo pipefail

CLI_NAME="defender"
CLI_VERSION="latest"
OS_TYPE=""
ARCH_TYPE=""
BINARY_NAME="$CLI_NAME"

if [ "$#" -eq 1 ]; then
    CLI_VERSION="$1"
    echo "Preparing to download version $CLI_VERSION of $CLI_NAME..."
else
    echo "Preparing to download the latest version of $CLI_NAME..."
fi

# Detect operating system
case "$(uname -s)" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="mac";;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE="windows";;
    *)          echo "Unsupported operating system: $(uname -s)"; exit 1;;
esac

# Detect architecture
case "$(uname -m)" in
    x86_64) ARCH_TYPE="amd64";;
    amd64)  ARCH_TYPE="amd64";;
    i386|i686) ARCH_TYPE="386";;
    armv7l|arm) ARCH_TYPE="arm";;
    aarch64) ARCH_TYPE="arm64";;
    *) echo "Unsupported architecture: $(uname -m)"; exit 1;;
esac

# Adjust binary name for Windows
if [ "$OS_TYPE" = "windows" ]; then
    BINARY_NAME="${BINARY_NAME}.exe"
fi

#DOWNLOAD_URL="https://raw.githubusercontent.com/amarnatv/cli/main/Defender.exe?raw=true"
DOWNLOAD_URL="https://github.com/amarnatv/cli/raw/refs/heads/main/Defender-linux"
echo "Downloading $CLI_NAME from: $DOWNLOAD_URL"
curl -fLo "$BINARY_NAME" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "Failed to download $CLI_NAME. Please check the URL or your network connection."
    read -p "Press Enter to exit 1"
    exit 1
fi

# Make the binary executable
if [ "$OS_TYPE" = "windows" ]; then
    chmod +x "$BINARY_NAME"
else
    chmod +x "$BINARY_NAME"
fi

# Install the binary to a directory in PATH
INSTALL_DIRS=("$HOME/.local/bin")
if [ "$OS_TYPE" = "windows" ]; then
    INSTALL_DIRS=("$HOME" "$PROGRAMFILES" "$PROGRAMFILES(X86)")
fi

for INSTALL_DIR in "${INSTALL_DIRS[@]}"; do
    if [ -d "$INSTALL_DIR" ]; then
        INSTALL_DIR="$INSTALL_DIR/MDC"
        mkdir -p "$INSTALL_DIR"
        sudo mv -f "$BINARY_NAME" "$INSTALL_DIR/"
        echo "$CLI_NAME has been successfully installed in $INSTALL_DIR"

        # Add the install directory to PATH if not already present
        if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
            export PATH="$PATH:$INSTALL_DIR"
            echo "Added $INSTALL_DIR to the PATH. Please add it to your shell configuration file for persistence."
        fi

        echo "Successfully installed $CLI_NAME in $INSTALL_DIR. Please relaunch the terminal and run MDC Defender!"
        echo "Example command: defender init"
        echo "      defender init"
        echo "      defender scan"
        read -p "Press Enter to exit 0"
        exit 0
    fi
done

echo "Failed to install $CLI_NAME. Ensure one of the directories in PATH is writable or try running the script with elevated privileges."
read -p "Press Enter to exit 1"
exit 1
