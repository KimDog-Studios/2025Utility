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
    Write-Host "1. Activate and Add Ultimate Power Plan" -ForegroundColor Cyan
    Write-Host "2. Change Display Settings to Performance" -ForegroundColor Cyan
    Write-Host "3. Change Theme to Dark Mode" -ForegroundColor Cyan
    Write-Host "4. Exit" -ForegroundColor Red
    Write-Host "`n"
}

# Function to run the script from GitHub
function Run-GitHubScript {
    param (
        [string]$url
    )

    try {
        $scriptContent = Invoke-RestMethod -Uri $url
        Write-Host "Executing script from $url..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute script from $url: $_" -ForegroundColor Red
    }
}

# Function to handle menu selection
function Handle-MenuSelection {
    param (
        [int]$selection
    )

    switch ($selection) {
        1 {
            Write-Host "Running Script 1..." -ForegroundColor Green
            # URL of the script to activate and add Ultimate Power Plan
            $ultimatePowerPlanUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/activateUltimatePowerPlan.ps1"
            Run-GitHubScript -url $ultimatePowerPlanUrl
        }
        2 {
            Write-Host "Running Script 2..." -ForegroundColor Green
            # Placeholder for Script 2
            # .\Path\To\Script2.ps1
        }
        3 {
            Write-Host "Running Script 3..." -ForegroundColor Green
            # Placeholder for Script 3
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
