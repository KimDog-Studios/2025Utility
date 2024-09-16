# This script is designed to be run directly from GitHub
# It will download itself and the required scripts, then execute locally

# Create the KimDog Studios folder in temp directory
$tempDir = Join-Path $env:TEMP "KimDog Studios"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Write-Host "Created temporary directory: $tempDir" -ForegroundColor Green
} else {
    Write-Host "Using existing temporary directory: $tempDir" -ForegroundColor Green
}

# URLs of the scripts
$mainScriptUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/main.ps1"
$wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/winget.ps1"
$windowsManagerUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/windowsManager.ps1"
$appJsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Function to download a script
function Download-Script {
    param (
        [string]$Url,
        [string]$FileName
    )
    $filePath = Join-Path $tempDir $FileName
    try {
        Write-Host "Downloading $FileName from $Url..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Url -OutFile $filePath -ErrorAction Stop
        Write-Host "Downloaded $FileName successfully to $filePath" -ForegroundColor Green
        return $filePath
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to download $FileName`: $errorMessage" -ForegroundColor Red
        return $null
    }
}

# Download scripts
Write-Host "Attempting to download scripts..." -ForegroundColor Cyan
$mainScriptPath = Download-Script -Url $mainScriptUrl -FileName "main.ps1"
$wingetMenuPath = Download-Script -Url $wingetMenuUrl -FileName "winget.ps1"
$windowsManagerPath = Download-Script -Url $windowsManagerUrl -FileName "windowsManager.ps1"
$appJsonPath = Download-Script -Url $appJsonUrl -FileName "apps.json"

if (-not $mainScriptPath -or -not $wingetMenuPath -or -not $windowsManagerPath -or -not $appJsonPath) {
    Write-Host "Failed to download one or more scripts. Please check your internet connection and try again." -ForegroundColor Red
    exit
}

# Restart using the downloaded main script
Write-Host "Restarting with the downloaded main script..." -ForegroundColor Cyan
& $mainScriptPath
exit

# The code below this point will only run when the script is restarted

# Modify the winget.ps1 script to use the local apps.json file
$wingetContent = Get-Content $wingetMenuPath -Raw
$wingetContent = $wingetContent -replace '\$jsonFilePath\s*=\s*[^\r\n]+', "`$jsonFilePath = `"$appJsonPath`"" 
$wingetContent | Set-Content $wingetMenuPath

# Function to check if a command is available
function Test-Command {
    param ([string]$Command)
    
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            Write-Host "$Command is already installed." -ForegroundColor Green
            return $true
        }
    } catch {}
    
    Write-Host "$Command is not installed." -ForegroundColor Red
    return $false
}

# Function to install winget
function Install-Winget {
    $downloadUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.8.1911/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $tempFile = Join-Path $tempDir "winget_installer.msixbundle"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
        Write-Host "Installing winget..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -ArgumentList "/quiet" -Wait
    } catch {
        Write-Host "Failed to download or install winget: $_" -ForegroundColor Red
    } finally {
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

# Function to install Chocolatey
function Install-Chocolatey {
    $chocoInstallScriptUrl = "https://chocolatey.org/install.ps1"
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($chocoInstallScriptUrl))
    } catch {
        Write-Host "Failed to install Chocolatey: $_" -ForegroundColor Red
    }
}

function Show-MainHeader {
    Clear-Host
    $headerText = "KimDog's Windows Utility | Last Updated: 2024-09-15"
    $boxWidth = $headerText.Length + 4
    $border = "+$("-" * ($boxWidth - 2))+"
    $emptyLine = "|$(" " * ($boxWidth - 2))|"
    
    Write-Host "$border`n$emptyLine`n| $headerText |`n$emptyLine`n$border" -ForegroundColor Cyan
    Write-Host
}

function Show-MainMenu {
    $menuItems = @(
        "Windows Manager",
        "Application Manager",
        "Exit"
    )
    
    $menuWidth = ($menuItems | Measure-Object -Property Length -Maximum).Maximum + 4
    $header = "Main Menu".PadLeft(($menuWidth + "Main Menu".Length) / 2).PadRight($menuWidth)
    
    Write-Host ("=" * $menuWidth) -ForegroundColor Yellow
    Write-Host $header -ForegroundColor Yellow
    Write-Host ("=" * $menuWidth) -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        $color = if ($i -eq $menuItems.Count - 1) { "Red" } else { "Green" }
        Write-Host "$($i + 1). $($menuItems[$i])" -ForegroundColor $color
    }
    
    Write-Host ("=" * $menuWidth) -ForegroundColor Yellow
    Write-Host
}

# Main loop
while ($true) {
    if (-not (Test-Command "winget")) { Install-Winget }
    if (-not (Test-Command "choco")) { Install-Chocolatey }

    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" {
            if (Test-Path $windowsManagerPath) {
                Write-Host "Executing Windows Manager script from $windowsManagerPath..." -ForegroundColor Green
                & $windowsManagerPath
            } else {
                Write-Host "Windows Manager script is not available at $windowsManagerPath." -ForegroundColor Red
            }
            pause
        }
        "2" {
            if (Test-Path $wingetMenuPath) {
                Write-Host "Executing Application Manager script from $wingetMenuPath..." -ForegroundColor Green
                & $wingetMenuPath
            } else {
                Write-Host "Application Manager script is not available at $wingetMenuPath." -ForegroundColor Red
            }
            pause
        }
        "3" { 
            Write-Host "Exiting..." -ForegroundColor Red
            Write-Host "Cleaning up temporary directory: $tempDir" -ForegroundColor Yellow
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $tempDir)) {
                Write-Host "Temporary directory removed successfully." -ForegroundColor Green
            } else {
                Write-Host "Failed to remove temporary directory." -ForegroundColor Red
            }
            exit 
        }
        default { 
            Write-Host "Invalid selection, please try again." -ForegroundColor Red 
            pause
        }
    }
}

