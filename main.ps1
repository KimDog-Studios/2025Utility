# Function to check if the script is running as an administrator
function Check-AdminPrivileges {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}

# Function to restart the script with elevated privileges
function Restart-WithAdminPrivileges {
    param (
        [string]$Selection
    )
    Write-Host "Restarting script with administrative privileges..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -ArgumentList $Selection" -Verb RunAs
    exit  # Exit the current non-elevated process
}

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
    Write-Host "2. Application Manager (Admin Required)" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to fetch and execute the Windows Manager script from GitHub
function Run-WindowsManager {
    try {
        $scriptContent = Invoke-RestMethod -Uri $windowsManagerUrl
        Write-Host "Executing Windows Manager script..." -ForegroundColor Green
        
        # Execute the fetched script content
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute Windows Manager script: $_" -ForegroundColor Red
    }
}

# Function to fetch and execute the winget menu script from GitHub
function Run-WingetMenu {
    try {
        $scriptContent = Invoke-RestMethod -Uri $wingetMenuUrl
        Write-Host "Executing winget menu script..." -ForegroundColor Green
        
        # Execute the fetched script content
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

# Function for Option 2 (requires admin)
function Option2 {
    # Check if running with admin privileges; if not, restart with admin
    if (-not (Check-AdminPrivileges)) {
        Restart-WithAdminPrivileges -Selection "2"
    }

    Clear-Host
    Write-Host "You selected Option 2: Application Manager (Admin Required)" -ForegroundColor Green
    Run-WingetMenu
}

# Function for invalid option
function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main loop
while ($true) {
    # If there is an argument passed (e.g., after restarting as admin)
    if ($args.Length -gt 0) {
        switch ($args[0]) {
            "1" { Option1; exit }
            "2" { Option2; exit }
            "3" { Write-Host "Exiting..." -ForegroundColor Red; exit }
        }
    }

    Show-MainHeader
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
