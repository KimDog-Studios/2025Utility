$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"

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
    return $AlignedText
}

# Function to draw a box around text
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

# Function to show the main header
function Show-MainHeader {
    Clear-Host
    Draw-Box -Text "KimDog's Windows Utility | Last Updated: 2024-09-15"
    Write-Host "`n"
}

# Function to show a message if winget is installed
function Show-WingetMessage {
    $wingetCommand = "winget"
    $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue

    if ($wingetPath -ne $null) {
        Write-Host "[INFO] WinGet is Installed." -ForegroundColor Green
    } else {
        Write-Host "[INFO] WinGet is not installed." -ForegroundColor Yellow
    }
}

# Fetch URLs from the JSON file
function Fetch-UrlsFromJson {
    try {
        Write-Host "Fetching URLs from $jsonUrl..." -ForegroundColor Cyan
        $jsonData = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop

        # Verify the JSON structure
        if ($jsonData.urls -and $jsonData.urls.WPFWindowsManager.URL -and $jsonData.urls.WPFWinGetMenu.URL) {
            Write-Host "Successfully fetched URLs." -ForegroundColor Green
            return $jsonData.urls
        } else {
            Write-Host "Invalid JSON structure or missing URLs." -ForegroundColor Red
            exit
        }
    } catch {
        Write-Host "Failed to fetch URLs: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
}

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [string]$Url
    )
    
    try {
        Write-Host "Fetching script from $Url..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $Url -ErrorAction Stop
        Write-Host "Fetched script successfully." -ForegroundColor Green
        
        Write-Host "Executing script content..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute script: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to read key input
function Read-Key {
    $key = [System.Console]::ReadKey($true)
    return $key
}

# Define menu options and their corresponding actions
$menuOptions = @(
    @{ Name = "Windows Manager"; Action = { Option1 -windowsManagerUrl $urls.WPFWindowsManager.URL } },
    @{ Name = "Application Manager"; Action = { Option2 -wingetMenuUrl $urls.WPFWinGetMenu.URL } },
    @{ Name = "Exit"; Action = { Write-Host "Exiting..." -ForegroundColor Red; exit } }
)

# Function for Option 1: Windows Manager
function Option1 {
    param (
        [string]$windowsManagerUrl
    )
    Write-Host "You selected Windows Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $windowsManagerUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Function for Option 2: Application Manager
function Option2 {
    param (
        [string]$wingetMenuUrl
    )
    Write-Host "You selected Application Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $wingetMenuUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

$currentIndex = 0  # Track the current index

# Function to display the menu options
function Show-MainMenu {
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "`[->] $($menuOptions[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[-] $($menuOptions[$i].Name)"  # Regular menu item
        }
    }
    Write-Host "`n"
}

# Main loop
$urls = Fetch-UrlsFromJson
do {
    Show-MainHeader
    Show-MainMenu

    # Read key input
    $key = Read-Key

    # Handle arrow keys and selection
    switch ($key.Key) {
        'UpArrow' {
            $currentIndex = ($currentIndex - 1 + $menuOptions.Count) % $menuOptions.Count  # Move up
        }
        'DownArrow' {
            $currentIndex = ($currentIndex + 1) % $menuOptions.Count  # Move down
        }
        'Enter' {
            Clear-Host  # Clear the screen before running the action
            & $menuOptions[$currentIndex].Action  # Execute the selected option
        }
    }
    Start-Sleep -Milliseconds 100
} while ($true)
