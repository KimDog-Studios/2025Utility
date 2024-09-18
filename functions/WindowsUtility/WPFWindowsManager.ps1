# Define the URL for the JSON file containing script URLs
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"

# Fetch the JSON and parse it
try {
    Write-Host "Fetching URLs from JSON..." -ForegroundColor Cyan
    $urls = Invoke-RestMethod -Uri $jsonUrl -Method Get -ErrorAction Stop
    Write-Host "URLs successfully loaded." -ForegroundColor Green
} catch {
    Write-Host "Failed to fetch or parse the JSON: ${_}" -ForegroundColor Red
    exit
}

# Create a hashtable of menu options and corresponding URLs
$menuOptions = @{
    "Optimize for Gaming [Runs Options: 3, 4, 5]"            = $urls.urls.WPFGamingOptimization.URL
    "Remove Bloatware [Windows 11]"  = $urls.urls.WPFRemoveAppX.URL
    "Apply Ultimate Performance Mode"= $urls.urls.WPFUltimatePerformance.URL
    "Apply Dark Mode to Windows"     = $urls.urls.InvokeDarkMode.URL
    "Disable Mouse Acceleration"     = $urls.urls.InvokeMouseAcceleration.URL
    "Set Windows Updates to Default" = $urls.urls.InvokeSetWindowsUpdatesToDefault.URL
    "Set Updates to Security [Recommended]"        = $urls.urls.InvokeSetWindowsUpdatesToSecurity.URL
    "Disable Windows Updates [NOT Recommended]"        = $urls.urls.InvokeSetWindowsUpdatesToDisabled.URL
}

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [string]$Url
    )

    try {
        Write-Host "Fetching script from $Url..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop

        if ($scriptContent) {
            Write-Host "Executing script content..." -ForegroundColor Green
            Invoke-Expression $scriptContent
        } else {
            Write-Host "No script content received." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to fetch or execute script: ${_}" -ForegroundColor Red
    }
}

# Function to align and display header
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

# Function to show the main header
function Show-MainHeader {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " KimDog's Windows Manager Menu" -ForegroundColor Cyan
    Write-Host " Last Updated: 2024-09-17" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to show the main menu dynamically
function Show-MainMenu {
    $MenuWidth = 30
    Write-Host (Align-Header "Windows Manager" $MenuWidth) -ForegroundColor Yellow

    $i = 1
    foreach ($option in $menuOptions.Keys) {
        Write-Host "$i. $option" -ForegroundColor Green
        $i++
    }
    Write-Host "9. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to handle menu selection and execute corresponding scripts
function Handle-MenuSelection {
    param (
        [string]$selection
    )

    if ($menuOptions.ContainsKey($selection)) {
        Run-ScriptFromUrl -Url $menuOptions[$selection]
    } else {
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
    }
}

# Main loop
while ($true) {
    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    if ($selection -eq 'e') {
        Write-Host "Exiting..." -ForegroundColor Red
        exit
    }

    Handle-MenuSelection -selection $selection
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}
