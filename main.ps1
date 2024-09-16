# URL of the winget menu script
$wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/winget.ps1"

# URL of the Windows Manager script
$windowsManagerUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/windowsManager.ps1"

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
        $response = Invoke-RestMethod -Uri $githubApiUrl -Headers @{ "Accept" = "application/vnd.github.v3+json" }
        $latestRelease = $response.assets | Where-Object { $_.name -like "*msixbundle" -and $_.name -notlike "*License*" }
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

# Function to check if Chocolatey is installed
function Check-Chocolatey {
    $chocoCommand = "choco"
    
    try {
        # Check if choco command is available
        $chocoPath = Get-Command $chocoCommand -ErrorAction SilentlyContinue
        if ($chocoPath) {
            Write-Host "Chocolatey is already installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Chocolatey is not installed." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error checking Chocolatey installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to install Chocolatey
function Install-Chocolatey {
    $chocoInstallScriptUrl = "https://chocolatey.org/install.ps1"
    
    Write-Host "Downloading Chocolatey installation script from $chocoInstallScriptUrl..." -ForegroundColor Yellow

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        Invoke-WebRequest -Uri $chocoInstallScriptUrl -OutFile $tempFile
        Write-Host "Download complete. Installing Chocolatey..." -ForegroundColor Green

        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $tempFile" -Wait
        Write-Host "Chocolatey installation process has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download or install Chocolatey: $_" -ForegroundColor Red
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

function Show-MainHeader {
    Clear-Host

    function Draw-Box {
        param (
            [string]$Text
        )

        $boxWidth = $Text.Length + 4
        $topBottomBorder = "+" + ("-" * ($boxWidth - 2)) + "+"
        $emptyLine = "|" + (" " * ($boxWidth - 2)) + "|"

        Write-Host "$topBottomBorder" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "| $Text |" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "$topBottomBorder" -ForegroundColor Cyan
    }

    Draw-Box -Text "KimDog's Windows Utility | Last Updated: 2024-09-15"
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

# Function to fetch and execute remote scripts
function Execute-RemoteScript {
    param (
        [string]$Url,
        [string]$ScriptName
    )
    try {
        $scriptContent = Invoke-RestMethod -Uri $Url
        Write-Host "Executing $ScriptName script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute $ScriptName script: $_" -ForegroundColor Red
    }
}

# Update these functions to use Execute-RemoteScript
function Run-WindowsManager {
    Execute-RemoteScript -Url $windowsManagerUrl -ScriptName "Windows Manager"
}

function Run-WingetMenu {
    Execute-RemoteScript -Url $wingetMenuUrl -ScriptName "Winget Menu"
}

# Function for Option 1
function Option1 {
    Clear-Host
    Write-Host "You selected Option 1: Windows Manager" -ForegroundColor Green
    Run-WindowsManager
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
    # Check and install winget if necessary
    if (-not (Check-Winget)) {
        Install-Winget
    }

    # Check and install Chocolatey if necessary
    if (-not (Check-Chocolatey)) {
        Install-Chocolatey
    }

    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidOption }
    }

    if ($selection -eq "3") {
        exit
    }
}

