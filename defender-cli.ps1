# Requires -Version 5.1
Set-StrictMode -Version Latest

# This script downloads the appropriate binary for MyCLI based on the operating system and architecture, and installs it in a directory in PATH.

$CLI_NAME="defender"
$CLI_VERSION="latest"
$OS_TYPE=""
$ARCH_TYPE=""
$BINARY_NAME="$CLI_NAME"

if ($args.Count -eq 1) {
    $CLI_VERSION = $args[0]
    Write-Host "Preparing to download version $CLI_VERSION of $CLI_NAME..."
} else {
    Write-Host "Preparing to download the latest version of $CLI_NAME..."
}

# Detect operating system
if ($env:OS -match "Windows_NT") {
    $OS_TYPE = "windows"
    $ARCH_TYPE = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "amd64" } else { "386" }
    $BINARY_NAME = "${BINARY_NAME}.exe"
    $INSTALL_DIRS="$env:ProgramFiles $env:ProgramFiles(x86) $home"
} elseif ($env:OS -match "Linux") {
    $OS_TYPE = "linux"
    $ARCH_TYPE = if ($env:PROCESSOR_ARCHITECTURE -eq "x86_64") { "amd64" } else { "386" }
    $INSTALL_DIRS="/usr/local/bin /usr/bin /opt/bin $home"
    #} elseif ($env:OS -match "Darwin") {
#    $OS_TYPE = "mac"
#    $ARCH_TYPE = if ($env:PROCESSOR_ARCHITECTURE -eq "arm64") { "arm64" } else { "amd64" }
} else {
    Write-Host "Unsupported operating system: $env:OS"
    exit 1
}

# Detect architecture if not already set
if (-not $ARCH_TYPE) {
    switch ($(uname -m)) {
        "x86_64" {
            $ARCH_TYPE = "amd64"
        }
        "amd64" {
            $ARCH_TYPE = "amd64"
        }
        "i386" {
            $ARCH_TYPE = "386"
        }
        "i686" {
            $ARCH_TYPE = "386"
        }
        "armv7l" {
            $ARCH_TYPE = "arm"
        }
        "arm" {
            $ARCH_TYPE = "arm"
        }
        "aarch64" {
            $ARCH_TYPE = "arm64"
        }
        default {
            Write-Host "Unsupported architecture: $(uname -m)"
            exit 1
        }
    }
}

#$DOWNLOAD_URL="https://raw.githubusercontent.com/amarnatv/cli/main/Defender.exe?raw=true"
$DOWNLOAD_URL="https://raw.githubusercontent.com/amarnatv/cli/main/README.md?raw=true"
Write-Output "Downloading $CLI_NAME from: $DOWNLOAD_URL"
#Invoke-WebRequest -Uri "$DOWNLOAD_URL" -OutFile "$BINARY_NAME" -UseBasicParsing -TimeoutSec 600

