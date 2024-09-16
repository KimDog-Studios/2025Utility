# Function to check if winget is installed
function Check-Winget {
    $wingetCommand = "winget"
    
    try {
        # Check if winget command is available
        $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue
        return $wingetPath -ne $null
    } catch {
        Write-Host "Error checking winget installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check if Chocolatey is installed
function Check-Chocolatey {
    $chocoCommand = "choco"
    
    try {
        # Check if Chocolatey command is available
        $chocoPath = Get-Command $chocoCommand -ErrorAction SilentlyContinue
        return $chocoPath -ne $null
    } catch {
        Write-Host "Error checking Chocolatey installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to install Chocolatey
function Install-Chocolatey {
    if (-not (Check-Chocolatey)) {
        Write-Host "Chocolatey is not installed. Installing Chocolatey..." -ForegroundColor Yellow
        try {
            # Download and execute Chocolatey installation script
            $chocoInstallUrl = "https://chocolatey.org/install.ps1"
            Invoke-WebRequest -Uri $chocoInstallUrl -UseBasicP -OutFile "$env:TEMP\install-choco.ps1"
            & "$env:TEMP\install-choco.ps1"
            Remove-Item "$env:TEMP\install-choco.ps1" -Force
            Write-Host "Chocolatey installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install Chocolatey: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
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
    Write-Host "`n"
}

# Function to show a message if winget is installed
function Show-WingetMessage {
    if (Check-Winget) {
        Write-Host "[INFO] WinGet is Installed." -ForegroundColor Green
    } else {
        Write-Host "[INFO] WinGet is not installed." -ForegroundColor Yellow
    }
}

# Function to show the main menu
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Windows Manager" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to fetch and execute the winget menu script
function Run-WingetMenu {
    $wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/winget.ps1"
    
    try {
        Write-Host "Fetching winget menu script from $wingetMenuUrl..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $wingetMenuUrl -ErrorAction Stop
        Write-Host "Fetched winget menu script successfully." -ForegroundColor Green
        
        Write-Host "Executing winget menu script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute winget menu script: $_" -ForegroundColor Red
    }
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

# Install Chocolatey if not present
Install-Chocolatey

# Main loop
while ($true) {
    Show-MainHeader
    Show-WingetMessage
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; exit }
        default { Show-InvalidOption }
    }

    if ($selection -eq "3") {
        exit
    }
}
