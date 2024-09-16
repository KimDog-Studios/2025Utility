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

# Function to fetch and execute the wingetManager script
function Run-WingetManager {
    $wingetManagerUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/wingetManager.ps1"
    try {
        $scriptContent = Invoke-RestMethod -Uri $wingetManagerUrl
        Write-Host "Executing wingetManager script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute wingetManager script: $_" -ForegroundColor Red
    }
}

# Function to fetch and execute the winget menu script
function Run-WingetMenu {
    $wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/winget.ps1"
    try {
        $scriptContent = Invoke-RestMethod -Uri $wingetMenuUrl
        Write-Host "Executing winget menu script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute winget menu script: $_" -ForegroundColor Red
    }
}

# Function to fetch and execute the Windows Manager script
function Run-WindowsManager {
    $windowsManagerUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/windowsManager.ps1"
    try {
        $scriptContent = Invoke-RestMethod -Uri $windowsManagerUrl
        Write-Host "Executing Windows Manager script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute Windows Manager script: $_" -ForegroundColor Red
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

# Run wingetManager script at the start
Run-WingetManager

# Main loop
while ($true) {
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
