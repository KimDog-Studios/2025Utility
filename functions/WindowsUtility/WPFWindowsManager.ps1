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

# Function to read key input
function Read-Key {
    $key = [System.Console]::ReadKey($true)
    return $key
}

# Define menu options and their corresponding actions
$menuOptions = @(
    @{ Name = "Optimize for Gaming [Runs Options: 3, 4, 5]"; Action = { Option1 } },
    @{ Name = "Remove Bloatware [Windows 11 Only]"; Action = { Option2 } },
    @{ Name = "Add & Apply Ultimate Performance Mode"; Action = { Option3 } },
    @{ Name = "Apply Dark Mode to Windows"; Action = { Option4 } },
    @{ Name = "Disable Mouse Acceleration"; Action = { Option5 } },
    @{ Name = "Exit"; Action = { Write-Host "Exiting..." -ForegroundColor Red; exit } }
)

$currentIndex = 0  # Track the current index

# Function to show the main header
function Show-MainHeader {
    Clear-Host
    Write-Host "KimDog's Windows Manager Menu | Last Updated: 2024-09-17" -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to display the menu options
function Show-MainMenu {
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "`[*] $($menuOptions[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[ ] $($menuOptions[$i].Name)"  # Regular menu item
        }
    }
    "`n" | Out-String  # Explicitly add a line break after each option
}

# Function for Option 1: Optimize for Gaming
function Option1 {
    Write-Host "You selected Option 1: Optimize for Gaming" -ForegroundColor Green
    Run-ScriptFromUrl -Url $gamingOptimizationUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Function for Option 2: Remove Bloatware
function Option2 {
    Write-Host "You selected Option 2: Remove Bloatware" -ForegroundColor Green
    Run-ScriptFromUrl -Url $removeAppXFilesUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Function for Option 3: Add & Apply Ultimate Performance Mode
function Option3 {
    Write-Host "You selected Option 3: Add & Apply Ultimate Performance Mode" -ForegroundColor Green
    Run-ScriptFromUrl -Url $ultimatePerformanceUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Function for Option 4: Apply Dark Mode to Windows
function Option4 {
    Write-Host "You selected Option 4: Apply Dark Mode to Windows" -ForegroundColor Green
    Run-ScriptFromUrl -Url $darkModeUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Function for Option 5: Disable Mouse Acceleration
function Option5 {
    Write-Host "You selected Option 5: Disable Mouse Acceleration" -ForegroundColor Green
    Run-ScriptFromUrl -Url $mouseAccelerationUrl
    Write-Host "`nPress Enter to return to the main menu..." -ForegroundColor Cyan
    Read-Host
}

# Main loop
while ($true) {
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
}
