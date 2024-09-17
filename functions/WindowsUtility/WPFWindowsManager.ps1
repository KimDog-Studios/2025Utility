# Define the URL for the JSON file containing script URLs
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/urls.json"

# Fetch the JSON and parse it
try {
    Write-Host "Fetching URLs from JSON..." -ForegroundColor Cyan
    $urls = Invoke-RestMethod -Uri $jsonUrl -Method Get -ErrorAction Stop
    Write-Host "URLs successfully loaded." -ForegroundColor Green
} catch {
    Write-Host "Failed to fetch or parse the JSON: ${_}" -ForegroundColor Red
    exit
}

# Access the URLs from the parsed JSON
$removeAppXFilesUrl = $urls.urls.WPFRemoveAppX.URL
$ultimatePerformanceUrl = $urls.urls.WPFUltimatePerformance.URL
$darkModeUrl = $urls.urls.InvokeDarkMode.URL
$mouseAccelerationUrl = $urls.urls.InvokeMouseAcceleration.URL
$gamingOptimizationUrl = $urls.urls.WPFGamingOptimization.URL

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

    Draw-Box -Text "KimDog's Windows Manager Menu | Last Updated: 2024-09-17"
    Write-Host "`n"
}

# Function to show the main menu
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Windows Manager" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Optimize for Gaming [Runs Options: 3, 4, 5]" -ForegroundColor Green
    Write-Host "2. Remove Bloatware [Windows 11 Only]" -ForegroundColor Green
    Write-Host "3. Add & Apply Ultimate Performance Mode" -ForegroundColor Green
    Write-Host "4. Apply Dark Mode to Windows" -ForegroundColor Green
    Write-Host "5. Disable Mouse Acceleration" -ForegroundColor Green
    Write-Host "6. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function for Option 1: Optimize for Gaming
function Option1 {
    cls
    Write-Host "You selected Option 1: Optimize for Gaming" -ForegroundColor Green
    Run-ScriptFromUrl -Url $gamingOptimizationUrl
    Read-Host
}

# Function for Option 2: Remove Bloatware
function Option2 {
    cls
    Write-Host "You selected Option 2: Remove Bloatware" -ForegroundColor Green
    Run-ScriptFromUrl -Url $removeAppXFilesUrl
    Read-Host
}

# Function for Option 3: Add & Apply Ultimate Performance Mode
function Option3 {
    cls
    Write-Host "You selected Option 3: Add & Apply Ultimate Performance Mode" -ForegroundColor Green
    Run-ScriptFromUrl -Url $ultimatePerformanceUrl
    Read-Host
}

# Function for Option 4: Apply Dark Mode to Windows
function Option4 {
    cls
    Write-Host "You selected Option 4: Apply Dark Mode to Windows" -ForegroundColor Green
    Run-ScriptFromUrl -Url $darkModeUrl
    Read-Host
}

# Function for Option 5: Disable Mouse Acceleration
function Option5 {
    cls
    Write-Host "You selected Option 5: Disable Mouse Acceleration" -ForegroundColor Green
    Run-ScriptFromUrl -Url $mouseAccelerationUrl
    Read-Host
}

# Function for invalid option
function Show-InvalidOption {
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
    Read-Host
}

# Main loop
while ($true) {
    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Option3 }
        "4" { Option4 }
        "5" { Option5 }
        "6" { Write-Host "Exiting..." -ForegroundColor Red; exit }
        default { Show-InvalidOption }
    }
}
