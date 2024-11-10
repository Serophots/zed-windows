# Function to uninstall Zed
function Uninstall-Zed {
    # Define the installation directory
    $installDir = Join-Path $env:LOCALAPPDATA 'Zed'
    $exePath = Join-Path $installDir 'zed.exe'
    $metadataPath = Join-Path $installDir 'zed-install-meta.json'
    $startMenuPath = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'
    $shortcutPath = Join-Path $startMenuPath 'Zed.lnk'

    # Initialize a variable to track uninstallation success
    $uninstallationFailed = $false

    # Check for existing installation and metadata
    if (-not (Test-Path $exePath) -and -not (Test-Path $metadataPath)) {
        Write-Host "Zed is not installed."
        $uninstallationFailed = $true
    }

    # Confirm uninstallation if Zed is installed
    if (-not $uninstallationFailed) {
        $confirmation = Read-Host "Are you sure you want to uninstall Zed? (Y/N)"
        if ($confirmation -notlike 'Y*') {
            Write-Host "Uninstallation cancelled."

            # Add pause before exit
            Write-Host "`nPress any key to exit..."
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            exit 0
        }
    }

    # Remove executable, installation metadata, and Start Menu shortcut
    if (Test-Path $exePath) {
        Remove-Item -Path $exePath -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $exePath)) {
            Write-Host "Removed executable: $exePath"
        } else {
            Write-Host "Failed to remove executable: $exePath"
            $uninstallationFailed = $true
        }
    } else {
        Write-Host "Executable not found: $exePath"
        $uninstallationFailed = $true
    }

    if (Test-Path $metadataPath) {
        Remove-Item -Path $metadataPath -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $metadataPath)) {
            Write-Host "Removed metadata file: $metadataPath"
        } else {
            Write-Host "Failed to remove metadata file: $metadataPath"
            $uninstallationFailed = $true
        }
    } else {
        Write-Host "Metadata file not found: $metadataPath"
        # Do not set failure for missing metadata; it's already checked above.
    }

    if (Test-Path $shortcutPath) {
        Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $shortcutPath)) {
            Write-Host "Removed Start Menu shortcut: $shortcutPath"
        } else {
            Write-Host "Failed to remove Start Menu shortcut: $shortcutPath"
            $uninstallationFailed = $true
        }
    } else {
        Write-Host "Shortcut not found: $shortcutPath"
    }

    # Get current user PATH variable
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    # Check if the install directory is in the PATH and remove it
    if ($userPath -like "*$installDir*") {
        $newUserPath = ($userPath -split ';') | Where-Object { $_ -ne "$installDir" } -join ';'
        [Environment]::SetEnvironmentVariable('Path', "$newUserPath", 'User')
        Write-Host "Removed Zed from PATH environment variable."
    } else {
        Write-Host "Zed was not in PATH environment variable."
    }

    # Prompt user for directory removal choice
    if ((Test-Path $installDir) -and (-not $uninstallationFailed)) {
        $removeDataChoice = Read-Host "Do you want to remove the installation directory as well? (Y/N)"
        if ($removeDataChoice -like 'Y*') {
            Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $installDir)) {
                Write-Host "Removed installation directory: $installDir"
            } else {
                Write-Host "Failed to remove installation directory: $installDir"
                $uninstallationFailed = $true
            }
        } else {
            Write-Host "Installation directory retained. Only executable and metadata have been removed."
        }
    }

    # Add pause before exit with prompt for user action
    if ($uninstallationFailed) {
        Write-Host "`nUninstallation encountered some issues."
    } else {
        Write-Host "`nUninstallation completed successfully!"
    }

    # Prompt user to press any key to exit
    Write-Host "`nPress any key to exit..."
    [void][System.Console]::ReadKey($true)

    # Exit with appropriate code based on uninstallation status
    if ($uninstallationFailed) {
        exit 1  # Exit with error code 1 for failure
    } else {
        exit 0  # Exit with code 0 for success
    }
}

# Run the uninstallation function directly
Uninstall-Zed
