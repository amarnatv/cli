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

$DOWNLOAD_URL="https://raw.githubusercontent.com/amarnatv/cli/main/Defender.exe?raw=true"
Write-Output "Downloading $CLI_NAME from: $DOWNLOAD_URL"
Invoke-WebRequest -Uri "$DOWNLOAD_URL" -OutFile "$BINARY_NAME" -UseBasicParsing -TimeoutSec 600

#if ($LASTEXITCODE -ne 0) {
if (-not $?) {
    Write-Output "Failed to download $CLI_NAME. Please check the URL or your network connection."
    exit 1
}
# Set the executable attribute for Windows
if ($OS_TYPE -eq "windows") {
    $acl = Get-Acl "$BINARY_NAME"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl "$BINARY_NAME" $acl
} else {
    chmod +x "$BINARY_NAME"
}

# Install the binary to a directory in PATH
#if ($env:OS -match "Windows_NT") {
#    $INSTALL_DIRS="$env:USERPROFILE"
#} else {
#    $INSTALL_DIRS="/usr/local/bin /usr/bin /opt/bin $home"
#}

#foreach ($InstallDir in $env:Path -split ";") {
foreach ($InstallDir in $INSTALL_DIRS -split " ") {
    if (Test-Path $InstallDir) {

        $InstallDir = Join-Path -Path $InstallDir -ChildPath "MDC"
        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir | Out-Null
        }

        Move-Item -Path "$BINARY_NAME" -Destination "$InstallDir" -Force -ErrorAction Stop

        Write-Output "$CLI_NAME has been successfully installed in $InstallDir"

        # Add the install directory to PATH if not already present
        if (-not ($env:PATH -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ -eq $InstallDir })) {
            [System.Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$InstallDir", [System.EnvironmentVariableTarget]::User)
            Write-Output "Added $InstallDir to the user PATH."
        }

        Write-Output "Successfully installed $CLI_NAME in $InstallDir. Please relaunch command line and run MDC Defender!"
        Write-Output "Example command: defender init"
        Write-Output "      defender init"
        Write-Output "      defender scan"
        exit 0
    
    }
}
Write-Output "Failed to install $CLI_NAME. Ensure one of the directories in PATH is writable or try running the script with elevated privileges."
exit 1
