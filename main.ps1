# Custom Main Menu in PowerShell

# Import the winget management script
$wingetScriptPath = ".\functions\private\winget_manager.ps1"
if (Test-Path $wingetScriptPath) {
    . $wingetScriptPath
} else {
    Write-Host "Winget management script not found at $wingetScriptPath" -ForegroundColor Red
    exit
}

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

function Show-Header {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Windows Utility" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

function Show-Menu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Copy KimDog's On Screen Display Settings" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

function Option1 {
    Clear-Host
    Write-Host "You selected Option 1." -ForegroundColor Green
    # Add your Option 1 code here
    Start-Sleep -Seconds 2
}

function Option2 {
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green
    
    # Call functions from winget-management.ps1
    if (-not (Check-Winget)) {
        Install-Winget
    }
    Start-Sleep -Seconds 2
}

function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
    Start-Sleep -Seconds 2
}

# Main loop
while ($true) {
    Show-Header
    Show-Menu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidOption }
    }
}
