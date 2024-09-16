# URL of the winget menu script
$wingetMenuUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/winget.ps1"

# URL of the Windows Manager script
$windowsManagerUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/windowsManager.ps1"

# Function to check if a command is available
function Test-Command {
    param ([string]$Command)
    
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            Write-Host "$Command is already installed." -ForegroundColor Green
            return $true
        }
    } catch {}
    
    Write-Host "$Command is not installed." -ForegroundColor Red
    return $false
}

# Function to download and execute a script
function Invoke-RemoteScript {
    param ([string]$Url, [string]$Description)
    
    try {
        $scriptContent = Invoke-RestMethod -Uri $Url
        Write-Host "Executing $Description script..." -ForegroundColor Green
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute $Description script: $_" -ForegroundColor Red
    }
}

# Function to install winget
function Install-Winget {
    $downloadUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.8.1911/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
        Write-Host "Installing winget..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -ArgumentList "/quiet" -Wait
    } catch {
        Write-Host "Failed to download or install winget: $_" -ForegroundColor Red
    } finally {
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

# Function to install Chocolatey
function Install-Chocolatey {
    $chocoInstallScriptUrl = "https://chocolatey.org/install.ps1"
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($chocoInstallScriptUrl))
    } catch {
        Write-Host "Failed to install Chocolatey: $_" -ForegroundColor Red
    }
}

function Show-MainHeader {
    Clear-Host
    $headerText = "KimDog's Windows Utility | Last Updated: 2024-09-15"
    $boxWidth = $headerText.Length + 4
    $border = "+$("-" * ($boxWidth - 2))+"
    $emptyLine = "|$(" " * ($boxWidth - 2))|"
    
    Write-Host "$border`n$emptyLine`n| $headerText |`n$emptyLine`n$border" -ForegroundColor Cyan
    Write-Host
}

function Show-MainMenu {
    $menuItems = @(
        "Windows Manager",
        "Application Manager",
        "Exit"
    )
    
    $menuWidth = ($menuItems | Measure-Object -Property Length -Maximum).Maximum + 4
    $header = "Main Menu".PadLeft(($menuWidth + "Main Menu".Length) / 2).PadRight($menuWidth)
    
    Write-Host ("=" * $menuWidth) -ForegroundColor Yellow
    Write-Host $header -ForegroundColor Yellow
    Write-Host ("=" * $menuWidth) -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        $color = if ($i -eq $menuItems.Count - 1) { "Red" } else { "Green" }
        Write-Host "$($i + 1). $($menuItems[$i])" -ForegroundColor $color
    }
    
    Write-Host ("=" * $menuWidth) -ForegroundColor Cyan
    Write-Host
}

# Main loop
while ($true) {
    if (-not (Test-Command "winget")) { Install-Winget }
    if (-not (Test-Command "choco")) { Install-Chocolatey }

    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" {
            try {
                $scriptContent = Invoke-RestMethod -Uri $windowsManagerUrl
                Write-Host "Executing Windows Manager script..." -ForegroundColor Green
                Invoke-Expression $scriptContent
            } catch {
                Write-Host "Failed to fetch or execute Windows Manager script: $_" -ForegroundColor Red
            }
        }
        "2" {
            try {
                $scriptContent = Invoke-RestMethod -Uri $wingetMenuUrl
                Write-Host "Executing Application Manager script..." -ForegroundColor Green
                Invoke-Expression $scriptContent
            } catch {
                Write-Host "Failed to fetch or execute Application Manager script: $_" -ForegroundColor Red
            }
        }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; exit }
        default { 
            Clear-Host
            Write-Host "Invalid selection, please try again." -ForegroundColor Red 
        }
    }
}
