# Function to maximize the PowerShell window
function Set-FullScreenWindow {
    $console = $Host.UI.RawUI
    $console.WindowSize = $console.MaxWindowSize
    $console.BufferSize = $console.MaxWindowSize
    $console.WindowPosition = New-Object System.Management.Automation.Host.Coordinates -ArgumentList 0,0
}

Set-FullScreenWindow

# Function to align and display header
function Align-Header {
    param (
        [string]$Text,
        [int]$Width = 30
    )

    $Padding = $Width - $Text.Length
    $LeftPadding = [math]::Floor($Padding / 2)
    $RightPadding = [math]::Ceiling($Padding / 2)

    return ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
}

function Show-Header {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "Windows Manager Menu" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to show the main menu
function Show-Menu {
    Clear-Host
    Write-Host "1. Run Script 1" -ForegroundColor Cyan
    Write-Host "2. Run Script 2" -ForegroundColor Cyan
    Write-Host "3. Run Script 3" -ForegroundColor Cyan
    Write-Host "4. Exit" -ForegroundColor Red
    Write-Host "`n"
}

# Function to handle menu selection
function Handle-MenuSelection {
    param (
        [int]$selection
    )

    switch ($selection) {
        1 {
            Write-Host "Running Script 1..." -ForegroundColor Green
            # Call Script 1
            # .\Path\To\Script1.ps1
        }
        2 {
            Write-Host "Running Script 2..." -ForegroundColor Green
            # Call Script 2
            # .\Path\To\Script2.ps1
        }
        3 {
            Write-Host "Running Script 3..." -ForegroundColor Green
            # Call Script 3
            # .\Path\To\Script3.ps1
        }
        4 {
            Write-Host "Exiting..." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Invalid selection, please try again." -ForegroundColor Red
        }
    }
}

# Main loop
while ($true) {
    Show-Header
    Show-Menu

    $selection = Read-Host "Select an option"

    if ($selection -match '^\d+$') {
        Handle-MenuSelection -selection [int]$selection
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }
}
