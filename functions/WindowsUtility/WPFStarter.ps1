# Function to check if Winget is installed
function Test-WinUtilWingetInstalled {
    try {
        $wingetPath = Get-Command "winget" -ErrorAction SilentlyContinue
        return $wingetPath -ne $null
    } catch {
        Write-Host "Error checking Winget installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check if Chocolatey is installed
function Test-WinUtilChocoInstalled {
    try {
        $chocoPath = Get-Command "choco" -ErrorAction SilentlyContinue
        return $chocoPath -ne $null
    } catch {
        Write-Host "Error checking Chocolatey installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to install Winget
function Install-WinUtilWinget {
    if (Test-WinUtilWingetInstalled) {
        Write-Host "Winget is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Winget is not installed. Installing now..." -ForegroundColor Yellow

    try {
        # Check Windows version
        $ComputerInfo = Get-ComputerInfo -ErrorAction Stop
        if ([version]$ComputerInfo.WindowsVersion -lt [version]"10.0.17763") {
            Write-Host "Winget is not supported on this version of Windows." -ForegroundColor Red
            return
        }

        # Install Winget prerequisites and Winget
        Write-Host "Downloading and installing Winget..." -ForegroundColor Cyan
        Get-WinUtilWingetPrerequisites
        Get-WinUtilWingetLatest
        Add-AppxProvisionedPackage -Online -PackagePath $ENV:TEMP\Microsoft.DesktopAppInstaller.msixbundle -DependencyPackagePath $ENV:TEMP\Microsoft.VCLibs.x64.Desktop.appx, $ENV:TEMP\Microsoft.UI.Xaml.x64.appx -LicensePath $ENV:TEMP\License1.xml

        Write-Host "Winget installed successfully." -ForegroundColor Green
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name Microsoft.WinGet.Client -Force
    } catch {
        Write-Host "Failed to install Winget. Attempting Chocolatey installation as a fallback." -ForegroundColor Red
        Install-WinUtilChoco
        Start-Process -Verb runas -FilePath "powershell.exe" -ArgumentList "choco install winget-cli"
        Write-Host "Winget installed via Chocolatey." -ForegroundColor Green
    }

    # Refresh Environment Variables
    $ENV:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Function to install Chocolatey
function Install-WinUtilChoco {
    if (Test-WinUtilChocoInstalled) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Chocolatey is not installed. Installing now..." -ForegroundColor Yellow

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($urls.ChocoInstall.URL))
        Write-Host "Chocolatey installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Chocolatey: $_" -ForegroundColor Red
    }
}

# Function to create a shortcut without dialogs
function Create-Shortcut {
    param (
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

    Write-Host "Shortcut '$ShortcutName' created at $ShortcutPath with 'Run as administrator' set to $RunAsAdmin"
}

# Function to create a folder in the Start Menu and add a shortcut
function Create-ShortcutInStartMenu {
    param (
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

# Function to create a shortcut on the desktop
function Create-DesktopShortcut {
    param (
        [string]$ShortcutName,
        [string]$TargetPath,
        [string]$Arguments = "",
        [bool]$RunAsAdmin = $true
    )

    # Define the path for the desktop
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "$ShortcutName.lnk")

    # Prepare the Shortcut
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($desktopPath)
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
        $bytes = [System.IO.File]::ReadAllBytes($desktopPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($desktopPath, $bytes)
    }

    Write-Host "Shortcut '$ShortcutName' created on the desktop with 'Run as administrator' set to $RunAsAdmin"
}

# Function to automatically create shortcuts in both the Start Menu and the Desktop
function Create-WinUtilShortcuts {
    $shell = if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { "powershell.exe" }
    $shellArgs = "-ExecutionPolicy Bypass -Command `"Start-Process $shell -verb runas -ArgumentList `'-Command `"irm https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/WindowsUtility/WPFStarter.ps1 | iex`"`'"

    # Create the shortcut in the Start Menu folder
    Create-ShortcutInStartMenu -ShortcutName "KimDog's Windows Utility" -TargetPath $shell -Arguments $shellArgs -RunAsAdmin $true

    # Create the shortcut on the desktop
    Create-DesktopShortcut -ShortcutName "KimDog's Windows Utility" -TargetPath $shell -Arguments $shellArgs -RunAsAdmin $true
}

# Function to execute a script from a URL
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

        # Parse the JSON content
        return $jsonContent
    } catch {
        Write-Host "An error occurred while fetching or parsing the JSON from ${jsonUrl}: ${_}" -ForegroundColor Red
        return $null
    }
}

# Get the JSON file URL and parse the JSON
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/WindowsUtility/utilityLinks.json"
$urls = Get-URLsFromJson -jsonUrl $jsonUrl

if ($urls) {
    # Install Winget and Chocolatey
    Install-WinUtilWinget
    Install-WinUtilChoco

    # Create the shortcuts
    Create-WinUtilShortcuts
} else {
    Write-Host "Failed to get URLs from JSON." -ForegroundColor Red
}
