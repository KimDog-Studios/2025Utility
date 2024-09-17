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
    $jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/urls.json"
    try {
        Write-Host "Fetching URLs from $jsonUrl..." -ForegroundColor Cyan
        $jsonData = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        Write-Host "Successfully fetched URLs." -ForegroundColor Green
        return $jsonData.urls
    } catch {
        Write-Host "Failed to fetch URLs: $_" -ForegroundColor Red
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
        Write-Host "Failed to fetch or execute script: $_" -ForegroundColor Red
    }
}

# Function to show the main menu
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Windows Manager" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Create Shortcut" -ForegroundColor Green
    Write-Host "4. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

# Function for Option 1: Windows Manager
function Option1 {
    param (
        [string]$windowsManagerUrl
    )
    Clear-Host
    Write-Host "You selected Option 1: Windows Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $windowsManagerUrl
}

# Function for Option 2: Application Manager
function Option2 {
    param (
        [string]$wingetMenuUrl
    )
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $wingetMenuUrl
}

# Function to create a shortcut using Invoke-WPFShortcut
function Create-Shortcut {
    param (
        [string]$invokeWPFShortcutUrl
    )
    Clear-Host
    Write-Host "Creating Desktop Shortcut..." -ForegroundColor Green
    Run-ScriptFromUrl -Url $invokeWPFShortcutUrl
}

# Function for invalid option
function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main script execution
$urls = Fetch-UrlsFromJson

# Automatically run the shortcut script
$invokeWPFShortcutUrl = $urls.Invoke-WPFShortcut.URL
Create-Shortcut -invokeWPFShortcutUrl $invokeWPFShortcutUrl

# Show main menu for additional options
do {
    Show-MainHeader
    Show-WingetMessage
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 -windowsManagerUrl $urls.WPFWindowsManager.URL }
        "2" { Option2 -wingetMenuUrl $urls.WPFWinGetMenu.URL }
        "3" { Option3 -invokeWPFShortcutUrl $invokeWPFShortcutUrl}
        "4" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidOption }
    }

} while ($true)
