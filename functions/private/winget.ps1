# Custom Winget Management Menu in PowerShell

# Function to maximize the PowerShell window
function Set-FullScreenWindow {
    $console = $Host.UI.RawUI
    $currentSize = $console.WindowSize
    $maxSize = $console.MaxWindowSize

    # Set window size to maximum
    $console.WindowSize = $maxSize
    $console.BufferSize = $maxSize

    # Set window position to the top-left corner of the screen
    $console.WindowPosition = New-Object System.Management.Automation.Host.Coordinates -ArgumentList 0,0
}

# Call the function to set the window to full screen
Set-FullScreenWindow

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

# Function to show the categories in a simple numbered list format
function Show-CategoryMenu {
    $categories = Get-MenuOptions
    $counter = 1
    foreach ($category in $categories) {
        Write-Host "[$counter] $($category.name)" -ForegroundColor Cyan
        $counter++
    }
    Write-Host "[0] Exit" -ForegroundColor Red
    Write-Host "`n"  # Reduced gap
}

# Function to show the apps within a selected category with pagination and description container
function Show-AppsInCategory {
    param (
        [int]$categoryIndex
    )

    $categories = Get-MenuOptions
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options
        $totalApps = $apps.Count
        $itemsPerPage = 5
        $page = 1
        $totalPages = [math]::Ceiling($totalApps / $itemsPerPage)
        $descriptionWidth = 60  # Set description width to 50 characters
        $borderChar = "_"

        while ($true) {
            Clear-Host
            Write-Host "=== $($selectedCategory.name) ===" -ForegroundColor Yellow

            $startIndex = ($page - 1) * $itemsPerPage
            $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalApps)

            for ($i = $startIndex; $i -lt $endIndex; $i++) {
                $app = $apps[$i]
                $description = $app.description

                # Wrap description text to the specified width
                $wrappedDescription = $description -split "(?<=\G.{${descriptionWidth}})"
                
                Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
                Write-Host "`nDescription:" -ForegroundColor Cyan
                Write-Host "$($borderChar * $descriptionWidth)" -ForegroundColor Gray
                
                foreach ($line in $wrappedDescription) {
                    $paddedLine = $line.PadLeft($descriptionWidth + 2) # Align text with padding
                    Write-Host $paddedLine -ForegroundColor Gray
                }

                Write-Host "$($borderChar * $descriptionWidth)" -ForegroundColor Gray
                Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
                Write-Host "" # Add extra line for readability
            }

            Write-Host "Page $page of $totalPages"
            Write-Host "[0] Back to Category Menu" -ForegroundColor Red
            Write-Host "[N] Next Page" -ForegroundColor Cyan
            Write-Host "[P] Previous Page" -ForegroundColor Cyan

            $input = Read-Host "Choose an option"

            if ($input -match '^\d+$') {
                $selectedAppIndex = [int]$input - 1
                if ($selectedAppIndex -ge 0 -and $selectedAppIndex -lt $totalApps) {
                    Handle-AppSelection -appIndex ($selectedAppIndex + 1) -categoryIndex $categoryIndex
                } else {
                    Write-Host "Invalid app selection, please try again." -ForegroundColor Red
                }
            } elseif ($input -eq 'N' -or $input -eq 'n') {
                if ($page -lt $totalPages) {
                    $page++
                } else {
                    Write-Host "You are already on the last page." -ForegroundColor Red
                }
            } elseif ($input -eq 'P' -or $input -eq 'p') {
                if ($page -gt 1) {
                    $page--
                } else {
                    Write-Host "You are already on the first page." -ForegroundColor Red
                }
            } elseif ($input -eq '0') {
                break
            } else {
                Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
            }
        }
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
        [int]$appIndex,
        [int]$categoryIndex
    )

    $categories = Get-MenuOptions
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options
        $app = $apps[$appIndex - 1]

        if ($app) {
            Write-Host "`nYou selected $($app.name) with Winget ID: $($app.wingetId)." -ForegroundColor Green
            Write-Host "Installing application..." -ForegroundColor Yellow
            Install-Application -wingetId $app.wingetId
        } else {
            Write-Host "Invalid app selection." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid category selection." -ForegroundColor Red
    }
}

# Main menu logic
while ($true) {
    Show-Header
    Show-CategoryMenu

    $categoryInput = Read-Host "Select a category"

    if ($categoryInput -match '^\d+$') {
        $categoryIndex = [int]$categoryInput
        if ($categoryIndex -eq 0) {
            Write-Host "Exiting menu. Goodbye!" -ForegroundColor Green
            break
        } elseif ($categoryIndex -gt 0 -and $categoryIndex -lt 10) {
            Show-AppsInCategory -categoryIndex $categoryIndex
        } else {
            Write-Host "Invalid category selection, please try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }
}
