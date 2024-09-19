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
$InvokeDisableStickyKeys = $urls.urls.InvokeDisableStickyKeys.URL

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

# Define menu options for Windows 10
$windows10Options = @(
    @{ Name = "Add & Apply Ultimate Performance Mode"; Action = { Run-ScriptFromUrl -Url $ultimatePerformanceUrl }; Write-Host "Running Add Ultimate Performance Scheme" },
    @{ Name = "Apply Dark Mode to Windows"; Action = { Run-ScriptFromUrl -Url $darkModeUrl }; Write-Host "Running Dark Mode" },
    @{ Name = "Disable Mouse Acceleration"; Action = { Run-ScriptFromUrl -Url $mouseAccelerationUrl }; Write-Host "Running Disable Mouse Acceleration" },
    @{ Name = "Optimizations for Gaming [Recommended]"; Action = { Run-ScriptFromUrl -Url $gamingOptimizationUrl }; Write-Host "Running Gaming Optimizations" },
    @{ Name = "Uninstall Microsoft Edge"; Action = { Run-ScriptFromUrl -Url $UninstallWinUtilEdgeBrowser }; Write-Host "Running Uninstall Microsoft Edge" },
    @{ Name = "Set Windows Updates to Default"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToDefault }; Write-Host "Running Set Windows Updates to Default" },
    @{ Name = "Set Windows Updates to Disabled [Not Recommended]"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToDisabled } Write-Host "Running Set Windows Updates to Disabled" },
    @{ Name = "Set Windows Updates to Security [Recommended]"; Action = { Run-ScriptFromUrl -Url $InvokeSetWindowsUpdatesToSecurity }; Write-Host "Running Set Windows Updates to Security" },
    @{ Name = "Disable Sticky Keys"; Action = { Run-ScriptFromUrl -Url $InvokeDisableStickyKeys }; Write-Host "Running Disable Sticky Keys" }
)

# Define menu options for Windows 11
$windows11Options = @(
    @{ Name = "Set Right Click Menu to Classic"; Action = { Run-ScriptFromUrl -Url $WPFClassicRightClick }; Write-Host "Running Set Right Click Menu to Classic" },
    @{ Name = "Remove Bloatware"; Action = { Run-ScriptFromUrl -Url $removeAppXFilesUrl }; Write-Host "Running Remove Bloatware"}
)

# Combine the options with headers for Windows 10 and Windows 11
$menuOptions = $windows10Options + @{ Name = "----- Windows 10 Options -----"; Action = { } } + $windows11Options + @{ Name = "----- Windows 11 Options -----"; Action = { } }

# Add the "Create Utility Shortcuts Manually" option to General Options
$menuOptions += @{ Name = "Create Utility Shortcuts Manually"; Action = { Run-ScriptFromUrl -Url $WPFShortcut } }
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
    Clear-Host  # Clear the console for a fresh display
    Write-Host "[INFO] Windows 10 Options will also work for Windows 11! Some Windows 11 Options wont Work in Windows 10 USE AT YOUR OWN RISK!!!`n" -ForegroundColor Cyan
    Write-Host "----- Windows 10 Options -----" -ForegroundColor Cyan
    for ($i = 0; $i -lt $windows10Options.Count; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "`[->] $($windows10Options[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[-] $($windows10Options[$i].Name)"  # Regular menu item
        }
    }

    Write-Host "`n----- Dedicated Windows 11 Options -----" -ForegroundColor Cyan
    for ($i = 0; $i -lt $windows11Options.Count; $i++) {
        if ($i -eq $currentIndex - $windows10Options.Count - 1) {  # Adjust index for Windows 11 options
            Write-Host "`[->] $($windows11Options[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[-] $($windows11Options[$i].Name)"  # Regular menu item
        }
    }

    # Display Exit option on its own line
   Write-Host "`n----- General Options -----" -ForegroundColor Cyan
    if ($currentIndex -eq $menuOptions.Count - 1) {  # Highlight exit if selected
        Write-Host "`[->] Exit" -ForegroundColor Yellow
    } else {
        Write-Host "`[-] Exit"  # Regular exit option
    }
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
            $currentIndex = ($currentIndex - 1 + $menuOptions.Count) % $menuOptions.Count  # Wrap around to the last item
        }
        'DownArrow' {
            $currentIndex = ($currentIndex + 1) % $menuOptions.Count  # Move down
        }
        'Enter' {
            Clear-Host  # Clear the screen before running the action
            & $menuOptions[$currentIndex].Action  # Execute the selected option
        }
    }
}