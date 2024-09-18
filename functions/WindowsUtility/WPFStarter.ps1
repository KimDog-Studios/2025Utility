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

# Optimize Create-Shortcut function
function Create-Shortcut {
    param(
        [string]$ShortcutName,
        [string]$ShortcutPath,
        [string]$TargetPath,
        [string]$Arguments = "",
        [bool]$RunAsAdmin = $true
    )

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments

    $iconUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/icon.ico"
    $iconPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "logo.ico")
    Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
    $Shortcut.IconLocation = $iconPath

    $Shortcut.Save()

    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }

    Write-Host "Shortcut '$ShortcutName' created at $ShortcutPath (Run as admin: $RunAsAdmin)"
}

# Combine Create-ShortcutInStartMenu and Create-DesktopShortcut
function Create-WinUtilShortcuts {
    $shell = if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell.exe" }
    $shellArgs = "-ExecutionPolicy Bypass -Command `"Start-Process $shell -verb runas -ArgumentList `'-Command `"irm https://bit.ly/4dcheD5 | iex`"`'"

    $locations = @{
        "Start Menu" = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), 'Programs', 'KimDog Studios')
        "Desktop" = [System.Environment]::GetFolderPath('Desktop')
    }

    foreach ($location in $locations.GetEnumerator()) {
        if ($location.Key -eq "Start Menu" -and -not (Test-Path -Path $location.Value)) {
            New-Item -Path $location.Value -ItemType Directory | Out-Null
        }
        $shortcutPath = [System.IO.Path]::Combine($location.Value, "KimDog's Windows Utility.lnk")
        Create-Shortcut -ShortcutName "KimDog's Windows Utility" -ShortcutPath $shortcutPath -TargetPath $shell -Arguments $shellArgs -RunAsAdmin $true
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
    $scriptsToExecute = @("WPFMain", "WPFWinGetMenu", "WPFWindowsManager")
    foreach ($script in $scriptsToExecute) {
        if ($urls.$script.URL) {
            Execute-ScriptFromUrl -url $urls.$script.URL
        } else {
            Write-Host "URL for $script not found in JSON." -ForegroundColor Yellow
        }
    }
}

# Call the shortcut creation function
Create-WinUtilShortcuts
