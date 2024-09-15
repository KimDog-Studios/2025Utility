# Custom Winget Management Menu in PowerShell

# Define paths for the JSON file
$tempJsonFilePath = [System.IO.Path]::Combine($env:TEMP, "apps.json")
$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Function to download JSON file
function Download-JsonFile {
    try {
        Write-Host "Downloading JSON file from $jsonFileUrl..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $jsonFileUrl -OutFile $tempJsonFilePath
        Write-Host "Download complete." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download JSON file: $_" -ForegroundColor Red
        exit
    }
}

# Function to clean up temporary files
function Cleanup-TempFiles {
    if (Test-Path $tempJsonFilePath) {
        Remove-Item -Path $tempJsonFilePath -ErrorAction SilentlyContinue
        Write-Host "Temporary files have been cleaned up." -ForegroundColor Green
    }
}

# Register cleanup function to run on script exit
trap {
    Cleanup-TempFiles
    exit
}

# Function to read and parse JSON file
function Get-MenuOptions {
    try {
        if (Test-Path $tempJsonFilePath) {
            $jsonContent = Get-Content -Path $tempJsonFilePath -Raw | ConvertFrom-Json
            return $jsonContent.options
        } else {
            Write-Host "JSON file not found at $tempJsonFilePath" -ForegroundColor Red
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

# Main execution
Download-JsonFile

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

# Cleanup on script exit
Cleanup-TempFiles
