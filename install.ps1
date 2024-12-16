# Function to get GitHub release based on channel and variant
function Get-ZedRelease {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet('Stable', 'Preview', 'Nightly')]
        [string]$Channel,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('vulkan', 'opengl')]
        [string]$Variant
    )

    $headers = @{
        'Accept' = 'application/vnd.github.v3+json'
    }

    $release = $null
    $page = 1

    while (-not $release) {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/xarunoba/zed-windows/releases?page=$page" -Headers $headers

        if ($response.Count -eq 0) {
            break
        }

        switch ($Channel) {
            'Stable' {
                $release = $response | Where-Object { -not $_.prerelease } | Sort-Object -Property created_at -Descending | Select-Object -First 1
            }
            'Preview' {
                $release = $response | Where-Object { $_.prerelease -and $_.tag_name -like '*-pre*' } | Sort-Object -Property created_at -Descending | Select-Object -First 1
            }
            'Nightly' {
                $release = $response | Where-Object { $_.prerelease -and $_.tag_name -like '*-nightly*' } | Sort-Object -Property created_at -Descending | Select-Object -First 1
            }
        }

        $page++
    }

    if (-not $release) {
        throw "Could not find appropriate Zed release for channel: $Channel"
    }

    # Find the correct asset based on channel pattern and variant
    $pattern = switch ($Channel) {
        'Stable' { "^zed-$Variant-v[\d\.]+\.zip$" }
        'Preview' { "^zed-preview-$Variant-v[\d\.]+-pre\.zip$" }
        'Nightly' { "^zed-nightly-$Variant-\d{4}\.\d{2}\.\d{2}\.zip$" }
    }

    $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
    if (-not $asset) {
        throw "Could not find appropriate Zed release for channel: $Channel ($Variant)"
    }

    # Get the checksum file as well
    $checksumAsset = $release.assets | Where-Object { $_.name -eq "$($asset.name).sha256" } | Select-Object -First 1
    if (-not $checksumAsset) {
        throw "Could not find checksum file for release"
    }

    return @{
        Release = $release
        Asset = $asset
        ChecksumAsset = $checksumAsset
    }
}

# Function to verify file checksum
function Verify-Checksum {
    param (
        [string]$FilePath,
        [string]$ChecksumFilePath
    )
    
    # Read the checksum file - format from sha256sum is "<hash>  <filename>"
    $checksumContent = Get-Content $ChecksumFilePath
    $expectedHash = ($checksumContent -split '\s+')[0].Trim().ToLower()
    
    $actualHash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
    
    if ($actualHash -ne $expectedHash) {
        Write-Host "Checksum verification failed!"
        Write-Host "Expected: $expectedHash"
        Write-Host "Actual  : $actualHash"
        return $false
    }
    return $true
}

# Function to get current installed version
function Get-InstalledVersion {
    param (
        [string]$InstallDir
    )
    
    # Retrieve installation metadata
    $metadata = Get-InstallationMetadata -InstallDir $InstallDir
    if ($metadata) {
        return $metadata.Version  # Return version from metadata
    }
    
    return $null  # Return null if no metadata found
}

# Function to save installation metadata
function Save-InstallationMetadata {
    param (
        [string]$Channel,
        [string]$Version,
        [string]$Variant,
        [string]$InstallDir
    )
    
    $metadata = @{
        channel = $Channel
        version = $Version
        variant = $Variant
        installedDate = (Get-Date).ToString("o")
    }
    
    $metadataPath = Join-Path $InstallDir "zed-install-meta.json"
    $metadata | ConvertTo-Json | Set-Content $metadataPath -Encoding UTF8
}

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

# Check for existing installation and metadata
$currentVersion = Get-InstalledVersion -InstallDir $installDir
$metadata = Get-InstallationMetadata -InstallDir $installDir

if ($currentVersion) {
    Write-Host "Current Zed installation found (version: $currentVersion)"
    if ($metadata) {
        Write-Host "Channel: $($metadata.Channel)"
        Write-Host "Graphics backend: $($metadata.Variant)"
        Write-Host "Installed on: $($metadata.InstalledDate)"
        
        Write-Host "`nWould you like to:"
        Write-Host "1. Check for updates in current channel ($($metadata.Channel))"
        Write-Host "2. Switch channels/options"
        Write-Host "3. Exit"
        
        do {
            $choice = Read-Host "Enter selection (1-3)"
            switch ($choice) {
                '1' { 
                    $channel = $metadata.Channel
                    $variant = $metadata.Variant
                    $checkUpdates = $true
                }
                '2' { 
                    $checkUpdates = $true
                    $metadata = $null  # Will trigger new channel/variant selection
                }
                '3' {
                    Write-Host "Exit requested."

                    # Add pause before exit
                    Write-Host "`nPress any key to exit..."
                    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                    exit 0
                }
                default { Write-Host "Invalid selection. Please enter 1, 2, or 3." }
            }
        } while (-not $choice -or $choice -notin '1','2','3')
    } else {
        Write-Host "No channel information found for existing installation."
        $updateChoice = Read-Host "Would you like to check for updates? (Y/N)"
        if ($updateChoice -notlike 'Y*') {
            Write-Host "Installation cancelled."

            # Add pause before exit
            Write-Host "`nPress any key to exit..."
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            exit 0
        }
        $checkUpdates = $true
    }
}

# Present channel selection if no metadata or switching channels
if (-not $channel) {
    Write-Host "`nSelect Zed release channel:"
    Write-Host "1. Stable (latest release, default)"
    Write-Host "2. Preview (pre-release)"
    Write-Host "3. Nightly (nightly build)"

    do {
        $selection = Read-Host "Enter selection (1-3, default: 1)"
        switch ($selection) {
            '2' { $channel = 'Preview' }
            '3' { $channel = 'Nightly' }
            '1' { $channel = 'Stable' }
            '' { $channel = 'Stable' }  # Default to Stable if Enter is pressed
            default { Write-Host "Invalid selection. Please enter 1, 2, or 3." }
        }
    } while (-not $channel)
}

# Present variant selection if no metadata or switching options
if (-not $variant) {
    Write-Host "`nSelect graphics backend:"
    Write-Host "1. Vulkan (default, recommended)"
    Write-Host "2. OpenGL (alternative)"

    do {
        $variantSelection = Read-Host "Enter selection (1-2, default: 1)"
        switch ($variantSelection) {
            '2' { $variant = 'opengl' }
            '1' { $variant = 'vulkan' }
            '' { $variant = 'vulkan' }  # Default to Vulkan if Enter is pressed
            default { Write-Host "Invalid selection. Please enter 1 or 2." }
        }
    } while (-not $variant)
}

try {
     # Get release info
    Write-Host "`nFetching release information..."
    $releaseInfo = Get-ZedRelease -Channel $channel -Variant $variant
    $release = $releaseInfo.Release
    $asset = $releaseInfo.Asset
    $checksumAsset = $releaseInfo.ChecksumAsset

    # Compare versions if already installed
    if ($currentVersion) {
        $newVersion = $release.tag_name
        Write-Host "`nCurrent version: $currentVersion"
        Write-Host "Available version: $newVersion"
        
        if ($newVersion -eq $metadata.Version) {
            Write-Host "You have the latest version for the $channel channel."
            $proceedWithUpdate = Read-Host "Would you like to reinstall anyway? (Y/N)"
        } else {
            $proceedWithUpdate = Read-Host "Proceed with update? (Y/N)"
        }
        
        if ($proceedWithUpdate -notlike 'Y*') {
            Write-Host "Update cancelled."

            # Add pause before exit
            Write-Host "`nPress any key to exit..."
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            exit 0
        }

        # Check if Zed is running
        $zedProcess = Get-Process -Name "zed" -ErrorAction SilentlyContinue
        if ($zedProcess) {
            Write-Host "Zed is currently running. Please close it before updating."
            $closeChoice = Read-Host "Would you like to close Zed now? (Y/N)"
            if ($closeChoice -like 'Y*') {
                $zedProcess | Stop-Process -Force
                Start-Sleep -Seconds 2  # Wait for process to close
            } else {
                Write-Host "Update cancelled. Please close Zed and run the installer again."

                # Add pause before exit
                Write-Host "`nPress any key to exit..."
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                exit 0
            }
        }
    }

    # Create installation directory
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    # Download files
    $tempZip = Join-Path $env:TEMP $asset.name
    $tempChecksum = Join-Path $env:TEMP "$($asset.name).sha256"

    Write-Host "`nDownloading Zed ($variant)..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip
    Write-Host "Downloading checksum..."
    Invoke-WebRequest -Uri $checksumAsset.browser_download_url -OutFile $tempChecksum

    # Verify checksum
    Write-Host "Verifying file integrity..."
    if (-not (Verify-Checksum -FilePath $tempZip -ChecksumFilePath $tempChecksum)) {
        throw "Checksum verification failed! The downloaded file may be corrupted."
    }

    Write-Host "Extracting files..."
    Expand-Archive -Path $tempZip -DestinationPath $installDir -Force

    # Cleanup
    Remove-Item $tempZip
    Remove-Item $tempChecksum

    # Create Start Menu shortcut (only if it doesn't exist)
    $startMenuPath = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'
    $shortcutPath = Join-Path $startMenuPath 'Zed.lnk'
    if (-not (Test-Path $shortcutPath)) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.Save()
    }

    # Add to PATH (only if not already there)
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$installDir", 'User')
        Write-Host "Added Zed to PATH environment variable"
    }

     # Save installation metadata
    Save-InstallationMetadata -Channel $channel -Version $release.tag_name -Variant $variant -InstallDir $installDir

    if ($currentVersion) {
        Write-Host "`nZed has been updated successfully!"
    } else {
        Write-Host "`nZed has been installed successfully!"
    }

    Write-Host "Installation directory: $installDir"
    Write-Host "Start Menu shortcut: $shortcutPath"
    Write-Host "Channel: $channel"
    Write-Host "Version: $($release.tag_name)"
    Write-Host "Graphics backend: $variant"
    Write-Host "`nPlease restart your terminal for PATH changes to take effect."
}
catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Installation failed. Please try again or report this issue."
    $script:installationFailed = $true
}

# Add pause before exit
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Exit with appropriate code
if ($script:installationFailed) {
    exit 1
} else {
    exit 0
}
