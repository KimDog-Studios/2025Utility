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
        Write-Host "   Option: $($option.id)" -ForegroundColor Cyan
        Write-Host "   Name: $($option.name)" -ForegroundColor Green
        Write-Host "   Description: $($option.description)" -ForegroundColor Gray
        Write-Host "   Winget ID: $($option.wingetId)" -ForegroundColor Cyan
        Write-Host "" # Add extra line for readability
    }
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to install an application using winget
function Install-Application {
    param (
        [string]$wingetId
    )

    if (-not $wingetId) {
        Write-Host "No Winget ID provided. Exiting..." -ForegroundColor Red
        return
    }

    Write-Host "Starting installation of $wingetId..." -ForegroundColor Yellow

    try {
        $cmdCommand = "winget install --id $wingetId --silent"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdCommand" -NoNewWindow -Wait
        Write-Host "Installation process for $wingetId has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start installation for ${wingetId}: $_" -ForegroundColor Red
    }
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
        Write-Host "You have chosen to Install: $($selectedOption.name)" -ForegroundColor Green
        Write-Host "Description: $($selectedOption.description)" -ForegroundColor Green
        Write-Host "Winget ID: $($selectedOption.wingetId)" -ForegroundColor Cyan
        
        # Call Install-Application function with the selected Winget ID
        Install-Application -wingetId $selectedOption.wingetId
        
    } else {
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
    }
}

# Main loop
while ($true) {
    Show-Header
    Show-Menu
    $selection = Read-Host "Please enter your Option: "

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
