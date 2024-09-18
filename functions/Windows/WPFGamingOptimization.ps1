# Fetch URLs from the JSON file
function Fetch-UrlsFromJson {
    $jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"
    try {
        Write-Verbose "Fetching URLs from $jsonUrl..."
        $jsonData = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        Write-Host "Successfully fetched URLs." -ForegroundColor Green
        return $jsonData.urls
    } catch {
        Write-Host "Failed to fetch URLs: $_" -ForegroundColor Red
        throw
    }
}

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [string]$Description
    )
    
    try {
        Write-Verbose "Fetching script for $Description from $Url..."
        $scriptContent = Invoke-RestMethod -Uri $Url -ErrorAction Stop
        Write-Host "Fetched script successfully." -ForegroundColor Green
        
        Write-Host "Executing $Description script..." -ForegroundColor Green
        $global:ErrorActionPreference = 'Stop'
        Invoke-Command -ScriptBlock ([scriptblock]::Create($scriptContent))
        Write-Host "$Description script executed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to fetch or execute $Description script: $_" -ForegroundColor Red
    } finally {
        $global:ErrorActionPreference = 'Continue'
    }
}

function Restart-WindowsExplorer {
    <#
    .SYNOPSIS
        Restarts Windows Explorer to refresh the shell.
    #>
    try {
        Write-Host "Restarting Windows Explorer..." -ForegroundColor Green
        Stop-Process -Name explorer -Force
       $process = Get-Process -Name "explorer"
      Stop-Process -InputObject $process
    } catch {
        Write-Host "Failed to restart Windows Explorer: $_" -ForegroundColor Red
    }
}

Write-Host "This Script runs the Following Tweaks to your System: " -ForegroundColor Red
Write-Host "Add and Enables Ultimate Performance Power Scheme" -ForegroundColor Red
Write-Host "Sets Desktop Theme to Dark Mode" -ForegroundColor Red
Write-Host "Disballes Mouse Acceleration" -ForegroundColor Red
Write-Host "Sets Windows 11 Right click menu to the Classic!" -ForegroundColor Red
Write-Host "Sets Windows Updates to Security" -ForegroundColor Red

# Main execution
try {
    # Fetch URLs from JSON
    $urls = Fetch-UrlsFromJson

    # Check if URLs are not empty
    if (-not $urls) {
        throw "No URLs fetched from the JSON."
    }

    # Countdown timer for 5 seconds
    for ($i = 5; $i -gt 0; $i--) {
        Write-Host "Starting in $i seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
    }

    # Execute scripts from URLs with checks
    if ($urls.WPFUltimatePerformance.URL) {
        Run-ScriptFromUrl -Url $urls.WPFUltimatePerformance.URL -Description "Ultimate Performance"
    }
    if ($urls.InvokeDarkMode.URL) {
        Run-ScriptFromUrl -Url $urls.InvokeDarkMode.URL -Description "Dark Mode"
    }
    if ($urls.InvokeMouseAcceleration.URL) {
        Run-ScriptFromUrl -Url $urls.InvokeMouseAcceleration.URL -Description "Mouse Acceleration"
    }
    if ($urls.WPFClassRightClick.URL) {
        Run-ScriptFromUrl -Url $urls.WPFClassRightClick.URL -Description "Sets the Windows 11 Right click menu to the Classic!"
    }
    if ($urls.InvokeSetWindowsUpdatesToSecurity.URL) {
        Run-ScriptFromUrl -Url $urls.InvokeSetWindowsUpdatesToSecurity.URL -Description "Sets Windows Updates to Security Only"
    }

    Restart-WindowsExplorer
    Write-Host "All optimizations completed successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred during the optimization process: $_" -ForegroundColor Red
}