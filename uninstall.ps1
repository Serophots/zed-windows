# Function to get installation metadata
function Get-InstallationMetadata {
    param (
        [string]$InstallDir
    )

    $metadataPath = Join-Path $InstallDir "zed-install-meta.json"
    if (Test-Path $metadataPath) {
        $metadata = Get-Content $metadataPath -Encoding UTF8 | ConvertFrom-Json
        return @{
            Channel = $metadata.channel
            Version = $metadata.version
            Variant = $metadata.variant
            InstalledDate = [DateTime]::Parse($metadata.installedDate)
        }
    }
    return $null
}

# Installation directory
$installDir = Join-Path $env:LOCALAPPDATA 'Zed'
$exePath = Join-Path $installDir 'zed.exe'
$configDir = Join-Path $env:APPDATA 'Zed'

# Check if Zed is installed
if (-not (Test-Path $installDir)) {
    Write-Host "Zed does not appear to be installed in the default location ($installDir)."

    # Add pause before exit
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 0
}

# Get installation metadata
$metadata = Get-InstallationMetadata -InstallDir $installDir
if ($metadata) {
    Write-Host "Found Zed installation:"
    Write-Host "Version: $($metadata.Version)"
    Write-Host "Channel: $($metadata.Channel)"
    Write-Host "Graphics backend: $($metadata.Variant)"
    Write-Host "Installed on: $($metadata.InstalledDate)"
}

# Explain uninstallation options
Write-Host "`nUninstallation options:"
Write-Host "1. Complete uninstall (removes everything including configurations)"
Write-Host "2. Partial uninstall (preserves user configurations)"

do {
    $choice = Read-Host "Enter your choice (1-2)"
    switch ($choice) {
        '1' {
            $preserveConfig = $false
            Write-Host "Selected: Complete uninstall"
        }
        '2' {
            $preserveConfig = $true
            Write-Host "Selected: Partial uninstall (configurations will be preserved)"
        }
        default { Write-Host "Invalid selection. Please enter 1 or 2." }
    }
} while ($choice -notin '1','2')

# Confirm uninstallation
if ($preserveConfig) {
    Write-Host "`nThis will uninstall Zed but preserve your configurations in: $configDir"
} else {
    Write-Host "`nThis will completely uninstall Zed and remove all associated files, including configurations."
}

$confirm = Read-Host "Do you want to proceed? (Y/N)"
if ($confirm -notlike 'Y*') {
    Write-Host "Uninstallation cancelled."

    # Add pause before exit
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 0
}

try {
    # Check if Zed is running
    $zedProcess = Get-Process -Name "zed" -ErrorAction SilentlyContinue
    if ($zedProcess) {
        Write-Host "Zed is currently running. Please close it before uninstalling."
        $closeChoice = Read-Host "Would you like to close Zed now? (Y/N)"
        if ($closeChoice -like 'Y*') {
            $zedProcess | Stop-Process -Force
            Start-Sleep -Seconds 2  # Wait for process to close
        } else {
            Write-Host "Uninstallation cancelled. Please close Zed and run the uninstaller again."

            # Add pause before exit
            Write-Host "`nPress any key to exit..."
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            exit 0
        }
    }

    # Remove Start Menu shortcut
    $startMenuPath = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'
    $shortcutPath = Join-Path $startMenuPath 'Zed.lnk'
    if (Test-Path $shortcutPath) {
        Write-Host "Removing Start Menu shortcut..."
        Remove-Item $shortcutPath -Force
    }

    # Remove from PATH
    Write-Host "Removing Zed from PATH environment variable..."
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $newPath = ($userPath -split ';' | Where-Object { $_ -ne $installDir }) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

    if ($preserveConfig) {
        # Remove only specific files/directories while preserving configs
        Write-Host "Removing Zed executable and related files..."
        Get-ChildItem -Path $installDir | ForEach-Object {
            # Skip the config directory if it exists in the install directory
            if ($_.FullName -ne $configDir) {
                Remove-Item $_.FullName -Recurse -Force
            }
        }
        Write-Host "User configurations preserved in: $configDir"
    } else {
        # Remove everything
        Write-Host "Removing all Zed files and configurations..."
        Remove-Item $installDir -Recurse -Force
        if (Test-Path $configDir) {
            Remove-Item $configDir -Recurse -Force
        }
    }

    Write-Host "`nZed has been successfully uninstalled!"
    if ($preserveConfig) {
        Write-Host "Your configurations have been preserved and can be reused with a future installation."
    }
    Write-Host "Please restart your terminal for PATH changes to take effect."
}
catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Uninstallation failed. Please try again or remove the files manually."
    $script:uninstallationFailed = $true
}

# Add pause before exit
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Exit with appropriate code
if ($script:uninstallationFailed) {
    exit 1
} else {
    exit 0
}
