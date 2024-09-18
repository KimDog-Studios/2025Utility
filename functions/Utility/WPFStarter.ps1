# Combine Test-WinUtilWingetInstalled and Test-WinUtilChocoInstalled into one function
function Test-PackageManagerInstalled {
    param (
        [string]$PackageManager
    )
    try {
        $path = Get-Command $PackageManager -ErrorAction Stop
        return "installed"
    } catch {
        return "not installed"
    }
}

# Add this function to fetch URLs from JSON
function Get-URLsFromJson {
    param (
        [string]$jsonUrl
    )
    try {
        $jsonContent = Invoke-WebRequest -Uri $jsonUrl | ConvertFrom-Json
        return $jsonContent.urls
    } catch {
        Write-Host "Error fetching URLs from JSON: $_" -ForegroundColor Red
        return $null
    }
}

# Add this function to install Winget
function Install-WinUtilWinget {
    Write-Host "Installing Winget..."
    $progressPreference = 'silentlyContinue'
    $latestWinget = Invoke-WebRequest -Uri https://api.github.com/repos/microsoft/winget-cli/releases/latest
    $latestWingetVersion = ($latestWinget.Content | ConvertFrom-Json).tag_name
    $wingetUrl = "https://github.com/microsoft/winget-cli/releases/download/$latestWingetVersion/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    
    Invoke-WebRequest -Uri $wingetUrl -OutFile "winget.msixbundle"
    Add-AppxPackage -Path "winget.msixbundle"
    Remove-Item "winget.msixbundle"
    Write-Host "Winget installed successfully." -ForegroundColor Green
}

# Add this function to install Chocolatey
function Install-WinUtilChoco {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Host "Chocolatey installed successfully." -ForegroundColor Green
}

# Add this function to execute scripts from URLs
function Execute-ScriptFromUrl {
    param (
        [string]$url
    )
    try {
        $scriptContent = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Error executing script from URL: $_" -ForegroundColor Red
    }
}

# Main script starts here
$urlsJson = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"

# Fetch URLs from the JSON file
$urls = Get-URLsFromJson -jsonUrl $urlsJson

if ($urls) {
    # Check and install Winget and Chocolatey if not present
    $packageManagers = @{
        "winget" = @{
            TestFunction = "Test-PackageManagerInstalled"
            InstallFunction = "Install-WinUtilWinget"
        }
        "choco" = @{
            TestFunction = "Test-PackageManagerInstalled"
            InstallFunction = "Install-WinUtilChoco"
        }
    }

    foreach ($manager in $packageManagers.Keys) {
        $status = & $packageManagers[$manager].TestFunction -PackageManager $manager
        if ($status -ne "installed") {
            Write-Host "$manager is not installed. Installing now..." -ForegroundColor Yellow
            & $packageManagers[$manager].InstallFunction
        } else {
            Write-Host "$manager is already installed." -ForegroundColor Green
        }
    }

    # Execute the scripts dynamically based on the URLs in the JSON
    $scriptsToExecute = @("WPFMain", "WPFWinGetMenu", "WPFWindowsManager", "WPFShortcut")
    foreach ($script in $scriptsToExecute) {
        if ($urls.$script.URL) {
            Execute-ScriptFromUrl -url $urls.$script.URL
        } else {
            Write-Host "URL for $script not found in JSON." -ForegroundColor Yellow
        }
    }
}
