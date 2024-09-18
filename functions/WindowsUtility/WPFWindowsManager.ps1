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

# Create a list of menu options and corresponding URLs
$menuOptions = @(
    @{ Name = "Optimize for Gaming [Runs Options: 3, 4, 5]"; URL = $urls.urls.WPFGamingOptimization.URL },
    @{ Name = "Remove Bloatware [Windows 11]"; URL = $urls.urls.WPFRemoveAppX.URL },
    @{ Name = "Apply Ultimate Performance Mode"; URL = $urls.urls.WPFUltimatePerformance.URL },
    @{ Name = "Apply Dark Mode to Windows"; URL = $urls.urls.InvokeDarkMode.URL },
    @{ Name = "Disable Mouse Acceleration"; URL = $urls.urls.InvokeMouseAcceleration.URL },
    @{ Name = "Set Windows Updates to Default"; URL = $urls.urls.InvokeSetWindowsUpdatesToDefault.URL },
    @{ Name = "Set Updates to Security [Recommended]"; URL = $urls.urls.InvokeSetWindowsUpdatesToSecurity.URL },
    @{ Name = "Disable Windows Updates [NOT Recommended]"; URL = $urls.urls.InvokeSetWindowsUpdatesToDisabled.URL }
)

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

    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        $option = $menuOptions[$i]
        Write-Host "$($i + 1). $($option.Name)" -ForegroundColor Green
    }
    Write-Host "9. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function to handle menu selection and execute corresponding scripts
function Handle-MenuSelection {
    param (
        [int]$selection
    )

    # Subtract 1 from selection to match zero-based index
    $index = $selection - 1

    if ($index -ge 0 -and $index -lt $menuOptions.Count) {
        $url = $menuOptions[$index].URL
        Run-ScriptFromUrl -Url $url
    } else {
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
    }
}

# Main loop
while ($true) {
    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    if ($selection -eq '9') {
        Write-Host "Exiting..." -ForegroundColor Red
        exit
    }

    # Ensure that the input is numeric and valid
    if ([int]::TryParse($selection, [ref]$null)) {
        $selectionInt = [int]$selection
        Handle-MenuSelection -selection $selectionInt
    } else {
        Write-Host "Invalid input, please enter a valid number." -ForegroundColor Red
    }

    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}
