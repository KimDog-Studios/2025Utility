# Custom Main Menu in PowerShell

# URL of the winget menu script
$wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/winget.ps1"
$tempFolderPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "KimDog Studios")
$wingetMenuPath = [System.IO.Path]::Combine($tempFolderPath, "winget.ps1")

# Ensure the temp folder exists
if (-not (Test-Path $tempFolderPath)) {
    New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
}

# Function to check if winget is installed
function Check-Winget {
    $wingetCommand = "winget"
    
    try {
        # Check if winget command is available
        $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue
        if ($wingetPath) {
            Write-Host "winget is already installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "winget is not installed." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error checking winget installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to get the latest winget release URL
function Get-Latest-Winget-Release-Url {
    $githubApiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    
    try {
        $response = Invoke-RestMethod -Uri $githubApiUrl -Headers @{ "User-Agent" = "PowerShell" }
        $latestRelease = $response.assets | Where-Object { $_.name -like "*AppInstaller*.msixbundle" }
        if ($latestRelease) {
            $downloadUrl = $latestRelease.browser_download_url
            Write-Host "Latest winget release URL: $downloadUrl" -ForegroundColor Cyan
            return $downloadUrl
        } else {
            Write-Host "No suitable release found." -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "Failed to fetch latest release URL: $_" -ForegroundColor Red
        return $null
    }
}

# Function to install winget
function Install-Winget {
    $downloadUrl = Get-Latest-Winget-Release-Url
    if (-not $downloadUrl) {
        Write-Host "Cannot proceed with installation. Exiting..." -ForegroundColor Red
        return
    }
    
    Write-Host "Downloading winget from $downloadUrl..." -ForegroundColor Yellow

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
        Write-Host "Download complete. Installing..." -ForegroundColor Green

        Start-Process -FilePath $tempFile -ArgumentList "/quiet" -Wait
        Write-Host "winget installation process has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download or install winget: $_" -ForegroundColor Red
    } finally {
        # Clean up temporary file
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

# Function to align header text
function Align-Header {
    param (
        [string]$Text,
        [int]$Width = 30
    )

    $TextLength = $Text.Length
    $Padding = $Width - $TextLength
    $LeftPadding = [math]::Floor($Padding / 2)
    $RightPadding = [math]::Ceiling($Padding / 2)
    
    $AlignedText = ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
    $AlignedText
}

# Function to show the header
function Show-MainHeader {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Windows Utility" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to show the main menu
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Windows Manager" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to download and run the winget menu script
function Run-WingetMenu {
    try {
        Write-Host "Downloading winget menu script from $wingetMenuUrl..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $wingetMenuUrl -OutFile $wingetMenuPath
        Write-Host "Download complete. Running winget menu..." -ForegroundColor Green

        Start-Process powershell -ArgumentList "-File `"$wingetMenuPath`"" -NoNewWindow -Wait
    } catch {
        Write-Host "Failed to download or run winget menu script: $_" -ForegroundColor Red
    } finally {
        # Clean up temporary folder and file
        if (Test-Path $wingetMenuPath) {
            Remove-Item -Path $wingetMenuPath -ErrorAction SilentlyContinue
        }
        if (Test-Path $tempFolderPath) {
            Remove-Item -Path $tempFolderPath -Recurse -ErrorAction SilentlyContinue
        }
    }
}

# Function for Option 1
function Option1 {
    Clear-Host
    Write-Host "You selected Option 1: Windows Manager" -ForegroundColor Green
    # Add your Option 1 code here
}

# Function for Option 2
function Option2 {
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green
    Run-WingetMenu
}

# Function for invalid option
function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main loop
while ($true) {
    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidOption }
    }
}
