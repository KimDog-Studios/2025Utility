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
    <#

    .SYNOPSIS
        Installs Winget if it is not already installed.

    .DESCRIPTION
        This function will download the latest version of Winget and install it. If Winget is already installed, it will do nothing.
    #>

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
    <#
    .SYNOPSIS
        Installs Chocolatey if it is not already installed
    #>

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
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    } catch {
        Write-Host "===========================================" -Foregroundcolor Red
        Write-Host "--     Chocolatey failed to install     ---" -Foregroundcolor Red
        Write-Host "===========================================" -Foregroundcolor Red
    }
}

# Main script starts here
Install-WinUtilWinget
Install-WinUtilChoco

# Define the URL of the script to execute
$scriptUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/public/WPFMain.ps1"

try {
    $scriptContent = Invoke-RestMethod -Uri $scriptUrl -Method Get

    if ($scriptContent) {
        # Execute the fetched script content
        Invoke-Expression $scriptContent
    }
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
