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

# Function to handle the menu system
function Show-MenuSystem {
    param (
        [array]$menuOptions,
        [int]$currentIndex
    )

    Show-MainHeader
    Show-MainMenu -menuOptions $menuOptions -currentIndex $currentIndex

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

    return $currentIndex  # Return the updated index
}

# Main loop
$currentIndex = 0  # Track the current index
while ($true) {
    $currentIndex = Show-MenuSystem -menuOptions $menuOptions -currentIndex $currentIndex
}
