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
$UninstallWinUtilEdgeBrowser = $urls.urls.UninstallWinUtilEdgeBrowser.URL
$InvokeSetWindowsUpdatesToDefault = $urls.urls.InvokeSetWindowsUpdatesToDefault.URL
$InvokeSetWindowsUpdatesToDisabled = $urls.urls.InvokeSetWindowsUpdatesToDisabled.URL
$InvokeSetWindowsUpdatesToSecurity = $urls.urls.InvokeSetWindowsUpdatesToSecurity.URL
$WPFClassicRightClick = $urls.urls.WPFClassicRightClick.URL
$WPFShortcut = $urls.urls.WPFShortcut.URL

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
    @{ Name = "Add & Apply Ultimate Performance Mode"; Action = { Run-ScriptFromUrl -Url $ultimatePerformanceUrl } },
    @{ Name = "Apply Dark Mode to Windows"; Action = { Run-ScriptFromUrl -Url $darkModeUrl } },
    @{ Name = "Disable Mouse Acceleration"; Action = { Run-ScriptFromUrl -Url $mouseAccelerationUrl } },
    @{ Name = "Optimize for Gaming"; Action = { Run-ScriptFromUrl -Url $gamingOptimizationUrl } },
    @{ Name = "Remove Bloatware [Windows 11 Only]"; Action = { Run-ScriptFromUrl -Url $removeAppXFilesUrl } },
    @{ Name = "Uninstall Microsoft Edge"; Action = { Run-ScriptFromUrl -Url $UninstallWinUtilEdgeBrowser } },
    @{ Name = "Set Windows 11 Right Click Menu to Classic"; Action = { Run-ScriptFromUrl -Url $WPFClassicRightClick } },
    @{ Name = "Set Windows Updates to Default"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToDefault } },
    @{ Name = "Set Windows Updates to Disabled [Not Recommended]"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToDisabled } },
    @{ Name = "Set Windows Updates to Security [Recommended]"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToSecurity } },
    @{ Name = "Create Utility Shortcuts Manually"; Action = { Run-ScriptFromUrl -Url $WPFShortcut } }
)

# Sort the menu options alphabetically and add the Exit option at the end
$menuOptions = $menuOptions | Sort-Object Name
$menuOptions += @{ Name = "Exit"; Action = { Write-Host "Exiting..." -ForegroundColor Red; exit } }  # Exit option added here

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
            Write-Host "`[->] $($menuOptions[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[-] $($menuOptions[$i].Name)"  # Regular menu item
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
