# Function to check if Winget is installed
function Test-WinUtilWingetInstalled {
    try {
        $wingetPath = Get-Command "winget" -ErrorAction SilentlyContinue
        if ($wingetPath -ne $null) {
            return "installed"
        } else {
            return "not installed"
        }
    } catch {
        Write-Host "Error checking Winget installation: $_" -ForegroundColor Red
        return "error"
    }
}

# Function to check if Chocolatey is installed
function Test-WinUtilChocoInstalled {
    try {
        $chocoPath = Get-Command "choco" -ErrorAction SilentlyContinue
        if ($chocoPath -ne $null) {
            return "installed"
        } else {
            return "not installed"
        }
    } catch {
        Write-Host "Error checking Chocolatey installation: $_" -ForegroundColor Red
        return "error"
    }
}

# Function to install Winget
function Install-WinUtilWinget {
    $isWingetInstalled = Test-WinUtilWingetInstalled

    try {
        if ($isWingetInstalled -eq "installed") {
            Write-Host "`nWinget is already installed.`r" -ForegroundColor Green
            return
        } else {
            Write-Host "`nWinget is not installed. Continuing with install.`r" -ForegroundColor Yellow
        }

        # Gets the computer's information
        $ComputerInfo = Get-ComputerInfo -ErrorAction Stop

        if (($ComputerInfo.WindowsVersion) -lt "1809") {
            Write-Host "Winget is not supported on this version of Windows (Pre-1809)" -ForegroundColor Red
            return
        }

        Write-Host "Downloading Winget Prerequisites`n"
        Get-WinUtilWingetPrerequisites
        Write-Host "Downloading Winget and License File`r"
        Get-WinUtilWingetLatest
        Write-Host "Installing Winget w/ Prerequisites`r"
        Add-AppxProvisionedPackage -Online -PackagePath $ENV:TEMP\Microsoft.DesktopAppInstaller.msixbundle -DependencyPackagePath $ENV:TEMP\Microsoft.VCLibs.x64.Desktop.appx, $ENV:TEMP\Microsoft.UI.Xaml.x64.appx -LicensePath $ENV:TEMP\License1.xml
        Write-Host "Winget Installed" -ForegroundColor Green
        Write-Host "Enabling NuGet and Module..."
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name Microsoft.WinGet.Client -Force

        Write-Output "Refreshing Environment Variables...`n"
        $ENV:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {
        Write-Host "Failure detected while installing via GitHub method. Continuing with Chocolatey method as fallback." -ForegroundColor Red

        try {
            Install-WinUtilChoco
            Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "choco install winget-cli"
            Write-Host "Winget Installed" -ForegroundColor Green
            Write-Output "Refreshing Environment Variables...`n"
            $ENV:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        } catch {
            throw [WingetFailedInstall]::new('Failed to install!')
        }
    }
}

# Function to install Chocolatey
function Install-WinUtilChoco {
    try {
        Write-Host "Checking if Chocolatey is Installed..."

        $isChocoInstalled = Test-WinUtilChocoInstalled
        if ($isChocoInstalled -eq "installed") {
            Write-Host "Chocolatey is already installed." -ForegroundColor Green
            return
        }

        Write-Host "Seems Chocolatey is not installed, installing now."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($urls.ChocoInstall))

    } catch {
        Write-Host "===========================================" -Foregroundcolor Red
        Write-Host "--     Chocolatey failed to install     ---" -Foregroundcolor Red
        Write-Host "===========================================" -Foregroundcolor Red
    }
}

# Function to create a shortcut without dialogs
function Create-Shortcut {
    param(
        [string]$ShortcutName,
        [string]$ShortcutPath,
        [string]$TargetPath,
        [string]$Arguments = "",
        [bool]$RunAsAdmin = $true
    )

    # Prepare the Shortcut
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments

    # Add an icon if available
    $iconUrl = "https://christitus.com/images/logo-full.ico"
    $iconPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "logo.ico")
    Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
    $Shortcut.IconLocation = $iconPath

    # Save the Shortcut
    $Shortcut.Save()

    # Set 'Run as administrator' if specified
    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }

    Write-Host "Shortcut '$ShortcutName' has been created at $ShortcutPath with 'Run as administrator' set to $RunAsAdmin"
}

# Function to create a folder in the Start Menu and add a shortcut
function Create-ShortcutInStartMenu {
    param(
        [string]$ShortcutName,
        [string]$TargetPath,
        [string]$Arguments = "",
        [bool]$RunAsAdmin = $true
    )

    # Define the Start Menu folder path
    $startMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), 'Programs', 'KimDog Studios')
    
    # Create the folder if it does not exist
    if (-not (Test-Path -Path $startMenuPath)) {
        New-Item -Path $startMenuPath -ItemType Directory | Out-Null
    }

    # Define the shortcut path
    $shortcutPath = [System.IO.Path]::Combine($startMenuPath, "$ShortcutName.lnk")

    # Create the shortcut
    Create-Shortcut -ShortcutName $ShortcutName -ShortcutPath $shortcutPath -TargetPath $TargetPath -Arguments $Arguments -RunAsAdmin $RunAsAdmin
}

# Automatically create the shortcut in the Start Menu
function Create-WinUtilShortcut {
    $shell = if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { "powershell.exe" }
    $shellArgs = "-ExecutionPolicy Bypass -Command `"Start-Process $shell -verb runas -ArgumentList `'-Command `"irm https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/WindowsUtility/WPFStarter.ps1 | iex`"`'"

    # Create the shortcut in the Start Menu folder
    Create-ShortcutInStartMenu -ShortcutName "KimDog's Windows Utility" -TargetPath $shell -Arguments $shellArgs -RunAsAdmin $true
}

# Call the shortcut creation function
Create-WinUtilShortcut

function Execute-ScriptFromUrl {
    param (
        [string]$url
    )

    try {
        $scriptContent = Invoke-RestMethod -Uri $url -Method Get

        if ($scriptContent) {
            # Execute the fetched script content
            Invoke-Expression $scriptContent
        }
    } catch {
        Write-Host "An error occurred while fetching or executing the script from ${url}: ${_}" -ForegroundColor Red
    }
}

# Function to get the URLs from the JSON file
function Get-URLsFromJson {
    param (
        [string]$jsonUrl
    )

    try {
        # Fetch the JSON from the provided URL
        $jsonContent = Invoke-RestMethod -Uri $jsonUrl -Method Get

        if ($jsonContent) {
            return $jsonContent.urls
        }
    } catch {
        Write-Host "An error occurred while fetching the JSON: $_" -ForegroundColor Red
    }
}

# Main script starts here
$urlsJson = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/urls.json"

# Fetch URLs from the JSON file
$urls = Get-URLsFromJson -jsonUrl $urlsJson

if ($urls) {
    # Install Winget and Chocolatey
    Install-WinUtilWinget
    Install-WinUtilChoco

    # Execute the scripts dynamically based on the URLs in the JSON
    Execute-ScriptFromUrl -url $urls.WPFMain.URL
    Execute-ScriptFromUrl -url $urls.WPFWinGetMenu.URL
    Execute-ScriptFromUrl -url $urls.WPFWindowsManager.URL
}
