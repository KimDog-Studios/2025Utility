# Fetch URLs from the JSON file
function Fetch-UrlsFromJson {
    $jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/urls.json"
    try {
        Write-Host "Fetching URLs from $jsonUrl..." -ForegroundColor Cyan
        $jsonData = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        Write-Host "Successfully fetched URLs." -ForegroundColor Green
        return $jsonData.urls
    } catch {
        Write-Host "Failed to fetch URLs: $_" -ForegroundColor Red
        exit
    }
}

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [string]$Url
    )
    
    try {
        Write-Host "Fetching script from $Url..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $Url -ErrorAction Stop
        Write-Host "Fetched script successfully." -ForegroundColor Green
        
        Write-Host "Executing script content..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute script: $_" -ForegroundColor Red
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
        Start-Process explorer
        Write-Host "Windows Explorer has been restarted." -ForegroundColor Green
    } catch {
        Write-Warning "An error occurred while restarting Windows Explorer: ${_}"
    }
}

# Fetch URLs from JSON
$urls = Fetch-UrlsFromJson

# Assign URLs to variables
$ultimatePerformanceUrl = $urls.WPFUltimatePerformance.URL
$darkModeUrl = $urls.InvokeDarkMode.URL
$mouseAccelerationUrl = $urls.InvokeMouseAcceleration.URL
$gamingOptimizationUrl = $urls.WPFGamingOptimization.URL

# Execute scripts from URLs
Run-ScriptFromUrl -Url $ultimatePerformanceUrl
Run-ScriptFromUrl -Url $darkModeUrl
Run-ScriptFromUrl -Url $mouseAccelerationUrl
Run-ScriptFromUrl -Url $gamingOptimizationUrl
Restart-WindowsExplorer