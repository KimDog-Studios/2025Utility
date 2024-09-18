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

# Main execution
try {
    # Fetch URLs from JSON
    $urls = Fetch-UrlsFromJson

    # Execute scripts from URLs
    foreach ($url in @(
        @{ Url = $urls.WPFUltimatePerformance.URL; Description = "Ultimate Performance" },
        @{ Url = $urls.InvokeDarkMode.URL; Description = "Dark Mode" },
        @{ Url = $urls.InvokeMouseAcceleration.URL; Description = "Mouse Acceleration" },
        @{ Url = $urls.WPFClassRightClick.URL; Description = "Sets the Windows 11 Right click menu to the Classic!" },
        @{ Url = $urls.InvokeSetWindowsUpdatesToSecurity.URL; Description = "Sets Windows Updates to Security Only" }
    )) {
        if (-not [string]::IsNullOrWhiteSpace($url.Url)) {
            Run-ScriptFromUrl -Url $url.Url -Description $url.Description
        } else {
            Write-Host "Warning: URL for $($url.Description) is empty." -ForegroundColor Yellow
        }
    }

    Restart-WindowsExplorer
    Write-Host "All optimizations completed successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred during the optimization process: $_" -ForegroundColor Red
}