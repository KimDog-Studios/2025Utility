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
$urlsToAccess = @(
    "WPFRemoveAppX", # Removes Bloatware from the System
    "WPFUltimatePerformance", # Adds and Enbales Ultimate Performance Power Scheme
    "InvokeDarkMode", # Sets PC Theme to Dark Mode
    "InvokeMouseAcceleration", # Disbales Mouse Acceleration
    "WPFGamingOptimization", # Enables Gaming Optimizations
    "UninstallWinUtilEdgeBrowser", # Uninstall Microsoft Edge
    "InvokeSetWindowsUpdatesToDefault", # Sets Windows Updates to Default
    "InvokeSetWindowsUpdatesToDisabled", # Sets Windows Updates to Disabled
    "InvokeSetWindowsUpdatesToSecurity", # Sets Windows Updates to Security
    "WPFClassicRightClick" # Enables Classic Right Click Menu [Right Clicking on Windows 11]
)

foreach ($urlKey in $urlsToAccess) {
    Set-Variable -Name "${urlKey}Url" -Value $urls.urls."$urlKey".URL
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

# Function to read key input
function Read-Key {
    $key = [System.Console]::ReadKey($true)
    return $key
}

# Define menu options and their corresponding actions
$menuOptions = @(
    @{ Name = "Optimize for Gaming [Runs Options: 3, 4, 5]"; Action = { Run-ScriptFromUrl -Url $gamingOptimizationUrl } },
    @{ Name = "Remove Bloatware [Windows 11 Only]"; Action = { Run-ScriptFromUrl -Url $removeAppXFilesUrl } },
    @{ Name = "Add & Apply Ultimate Performance Mode"; Action = { Run-ScriptFromUrl -Url $ultimatePerformanceUrl } },
    @{ Name = "Apply Dark Mode to Windows"; Action = { Run-ScriptFromUrl -Url $darkModeUrl } },
    @{ Name = "Disable Mouse Acceleration"; Action = { Run-ScriptFromUrl -Url $mouseAccelerationUrl } },
    @{ Name = "Remove Microsoft Edge"; Action = { Run-ScriptFromUrl -Url $UninstallWinUtilEdgeBrowser } },
    @{ Name = "Set Windows Updates to Default"; Action = { Run-ScriptFromUrl -Url $setWindowsUpdatesToDefault } },
    @{ Name = "Set Windows Updates to Disabled"; Action = { Run-ScriptFromUrl -Url $setWindowsUpdatesToDisabled } },
    @{ Name = "Set Windows Updates to Security"; Action = { Run-ScriptFromUrl -Url $setWindowsUpdatesToSecurity } },
    @{ Name = "Enable Classic Right Click Menu [Right Clicking on Windows 11]"; Action = { Run-ScriptFromUrl -Url $classicRightClickUrl } },
    @{ Name = "Exit"; Action = { Write-Host "Exiting..." -ForegroundColor Red; exit } }
)

# Sort menu options alphabetically by Name
$menuOptions = $menuOptions | Sort-Object { $_.Name }

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
