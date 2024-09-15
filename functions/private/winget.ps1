# Custom Winget Management Menu in PowerShell

# Define paths for the JSON file and folder
$kimDogFolder = [System.IO.Path]::Combine($env:TEMP, "KimDog Studios")
$tempJsonFilePath = [System.IO.Path]::Combine($kimDogFolder, "apps.json")
$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Function to create the KimDog Studios folder
function Create-KimDogFolder {
    if (-not (Test-Path $kimDogFolder)) {
        New-Item -Path $kimDogFolder -ItemType Directory | Out-Null
    }
}

# Function to download JSON file
function Download-JsonFile {
    try {
        Create-KimDogFolder
        Write-Host "Downloading JSON file from $jsonFileUrl..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $jsonFileUrl -OutFile $tempJsonFilePath
        Write-Host "Download complete." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download JSON file: $_" -ForegroundColor Red
        exit
    }
}

# Function to clean up KimDog Studios folder
function Cleanup-KimDogFolder {
    if (Test-Path $kimDogFolder) {
        Remove-Item -Path $kimDogFolder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "KimDog Studios folder and its contents have been cleaned up." -ForegroundColor Green
    }
}

# Register cleanup function to run on script exit (for both normal and unexpected exit)
Register-EngineEvent PowerShell.Exiting -Action {
    Cleanup-KimDogFolder
}

# Function to read and parse JSON file
function Get-MenuOptions {
    try {
        if (Test-Path $tempJsonFilePath) {
            $jsonContent = Get-Content -Path $tempJsonFilePath -Raw | ConvertFrom-Json
            return $jsonContent.categories
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

# Function to show the categories as a sub-menu
function Show-CategoryMenu {
    $MenuWidth = 30
    $categories = Get-MenuOptions

    Write-Host (Align-Header "Category Menu" $MenuWidth) -ForegroundColor Yellow
    $counter = 1
    foreach ($category in $categories) {
        Write-Host "$counter. $($category.name) [$($category.apps.Count)]" -ForegroundColor Cyan
        $counter++
    }
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to show the apps within a selected category
function Show-AppsInCategory {
    param (
        [int]$categoryId
    )

    $categories = Get-MenuOptions
    $selectedCategory = $categories[$categoryId - 1]

    if ($selectedCategory) {
        Clear-Host
        $MenuWidth = 30
        Write-Host (Align-Header $selectedCategory.name $MenuWidth) -ForegroundColor Yellow
        
        $counter = 1
        foreach ($app in $selectedCategory.apps) {
            Write-Host "$counter. $($app.name)" -ForegroundColor Green
            Write-Host "   Description: $($app.description)" -ForegroundColor Gray
            Write-Host "   Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host "" # Add extra line for readability
            $counter++
        }
        Write-Host "0. Back to Category Menu" -ForegroundColor Red
        Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
        Write-Host "`n"  # Reduced gap
    } else {
        Write-Host "Invalid category selection." -ForegroundColor Red
    }
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
function Handle-AppSelection {
    param (
        [int]$appId,
        [int]$categoryId
    )

    $categories = Get-MenuOptions
    $selectedCategory = $categories[$categoryId - 1]
    $selectedApp = $selectedCategory.apps[$appId - 1]

    if ($selectedApp) {
        Clear-Host
        Write-Host "You have chosen to Install: $($selectedApp.name)" -ForegroundColor Green
        Write-Host "Description: $($selectedApp.description)" -ForegroundColor Green
        Write-Host "Winget ID: $($selectedApp.wingetId)" -ForegroundColor Cyan
        
        # Call Install-Application function with the selected Winget ID
        Install-Application -wingetId $selectedApp.wingetId
        
    } else {
        Write-Host "Invalid app selection, please try again." -ForegroundColor Red
    }
}

# Main execution
Download-JsonFile

# Main loop
while ($true) {
    Show-Header
    Show-CategoryMenu
    $categorySelection = Read-Host "Please enter your Category: "

    # Validate the category selection
    if ($categorySelection -match '^\d+$') {
        $categorySelection = [int]$categorySelection

        if ($categorySelection -eq 0) {
            Write-Host "Exiting..." -ForegroundColor Red
            break
        } elseif ($categorySelection -le (Get-MenuOptions).Count -and $categorySelection -gt 0) {
            # Show the selected category apps
            while ($true) {
                Show-AppsInCategory -categoryId $categorySelection
                $appSelection = Read-Host "Please enter the App to Install (or 0 to go back): "

                if ($appSelection -match '^\d+$') {
                    $appSelection = [int]$appSelection

                    if ($appSelection -eq 0) {
                        break
                    } else {
                        Handle-AppSelection -appId $appSelection -categoryId $categorySelection
                    }
                } else {
                    Write-Host "Invalid input, please enter a number." -ForegroundColor Red
                }

                # Wait for user input to continue
                Write-Host "`nPress Enter to continue..." -ForegroundColor Yellow
                Read-Host
            }
        } else {
            Write-Host "Invalid category selection, please try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }

    # Wait for user input to continue
    Write-Host "`nPress Enter to continue..." -ForegroundColor Yellow
    Read-Host
}

# Cleanup on script exit
Cleanup-KimDogFolder
