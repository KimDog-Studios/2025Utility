# Custom Winget Management Menu in PowerShell

# Path to the JSON file
$jsonFilePath = ".\config\apps.json"

# Function to read and parse JSON file
function Get-MenuOptions {
    try {
        if (Test-Path $jsonFilePath) {
            $jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
            return $jsonContent.options
        } else {
            Write-Host "JSON file not found at $jsonFilePath" -ForegroundColor Red
            return @()
        }
    } catch {
        Write-Host "Failed to read or parse JSON file: $_" -ForegroundColor Red
        return @()
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
function Show-Header {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Winget Menu" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to show the menu based on JSON content
function Show-Menu {
    $MenuWidth = 30
    $options = Get-MenuOptions

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    foreach ($option in $options) {
        Write-Host "$($option.id). $($option.name)" -ForegroundColor Green
        Write-Host "   Description: $($option.description)" -ForegroundColor Gray
        if ($option.wingetId) {
            Write-Host "   Winget ID: $($option.wingetId)" -ForegroundColor Cyan
        }
        Write-Host "" # Add extra line for readability
    }
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function for Option selection
function Handle-Option {
    param (
        [int]$optionId
    )

    $options = Get-MenuOptions
    $selectedOption = $options | Where-Object { $_.id -eq $optionId }

    if ($selectedOption) {
        Clear-Host
        Write-Host "You selected: $($selectedOption.name)" -ForegroundColor Green
        Write-Host "Description: $($selectedOption.description)" -ForegroundColor Green
        
        if ($selectedOption.wingetId) {
            Write-Host "Winget ID: $($selectedOption.wingetId)" -ForegroundColor Cyan
        } else {
            Write-Host "No Winget ID found for the selected option." -ForegroundColor Red
        }
        
    } else {
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
    }
}

# Main loop
while ($true) {
    Show-Header
    Show-Menu
    $selection = Read-Host "Please enter your choice"

    # Validate the selection
    if ($selection -match '^\d+$') {
        $selection = [int]$selection

        if ($selection -eq 0) {
            Write-Host "Exiting..." -ForegroundColor Red
            break
        } else {
            Handle-Option -optionId $selection
        }
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }

    # Wait for user input to continue
    Write-Host "`nPress Enter to continue..." -ForegroundColor Yellow
    Read-Host
}
