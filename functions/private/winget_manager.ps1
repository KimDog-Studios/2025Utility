# winget-management.ps1

function Align-Header {
    param (
        [string]$Text,
        [int]$Width = 30
    )

    $TextLength = $Text.Length
    $Padding = $Width - $TextLength
    $LeftPadding = [math]::Floor($Padding / 2)
    $RightPadding = [math]::Ceiling($Padding / 2)
    
    $AlignedText = ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
    $AlignedText
}

function Show-Header {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Windows Utility" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

function Show-Menu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Copy KimDog's On Screen Display Settings" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

function Option1 {
    Clear-Host
    Write-Host "You selected Option 1." -ForegroundColor Green
    # Add your Option 1 code here
    Start-Sleep -Seconds 2
}

function Option2 {
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green

    if (-not (Check-Winget)) {
        Write-Host "winget is not installed. Proceeding with installation..." -ForegroundColor Yellow
        Install-Winget
    } else {
        Write-Host "winget is already installed." -ForegroundColor Green
    }

    # Show the App Menu after ensuring winget is installed
    Show-AppMenu
}

function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
    Start-Sleep -Seconds 2
}

function Check-Winget {
    $wingetCommand = "winget"
    
    try {
        # Check if winget command is available
        $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue
        if ($wingetPath) {
            Write-Host "winget is already installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "winget is not installed." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error checking winget installation: $_" -ForegroundColor Red
        return $false
    }
}

function Get-Latest-Winget-Release-Url {
    $githubApiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    
    try {
        $response = Invoke-RestMethod -Uri $githubApiUrl -Headers @{ "User-Agent" = "PowerShell" }
        $latestRelease = $response.assets | Where-Object { $_.name -like "*AppInstaller*.msixbundle" }
        if ($latestRelease) {
            $downloadUrl = $latestRelease.browser_download_url
            Write-Host "Latest winget release URL: $downloadUrl" -ForegroundColor Cyan
            return $downloadUrl
        } else {
            Write-Host "No suitable release found." -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "Failed to fetch latest release URL: $_" -ForegroundColor Red
        return $null
    }
}

function Install-Winget {
    $downloadUrl = Get-Latest-Winget-Release-Url
    if (-not $downloadUrl) {
        Write-Host "Cannot proceed with installation. Exiting..." -ForegroundColor Red
        return
    }
    
    Write-Host "Downloading winget from $downloadUrl..." -ForegroundColor Yellow

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
        Write-Host "Download complete. Installing..." -ForegroundColor Green

        Start-Process -FilePath $tempFile -ArgumentList "/quiet" -Wait
        Write-Host "winget installation process has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download or install winget: $_" -ForegroundColor Red
    } finally {
        # Clean up temporary file
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

# Function to show the app menu
function Show-AppMenu {
    function Align-Header {
        param (
            [string]$Text,
            [int]$Width = 30
        )

        $TextLength = $Text.Length
        $Padding = $Width - $TextLength
        $LeftPadding = [math]::Floor($Padding / 2)
        $RightPadding = [math]::Ceiling($Padding / 2)
        
        $AlignedText = ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
        $AlignedText
    }

    function Show-Header {
        Clear-Host
        $HeaderWidth = 30

        Write-Host (Align-Header "KimDog's Windows Utility" $HeaderWidth) -ForegroundColor Yellow
        Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
        Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
        Write-Host "`n"  # Reduced gap
    }

    function Show-Menu {
        $MenuWidth = 30

        Write-Host (Align-Header "App Manager Menu" $MenuWidth) -ForegroundColor Yellow
        Write-Host "1. Option 1" -ForegroundColor Green
        Write-Host "2. Option 2" -ForegroundColor Green
        Write-Host "3. Exit" -ForegroundColor Red
        Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
        Write-Host "`n"  # Reduced gap
    }

    function Option1 {
        Clear-Host
        Write-Host "You selected Option 1." -ForegroundColor Green
        # Add your Option 1 code here
        Start-Sleep -Seconds 2
    }

    function Option2 {
        Clear-Host
        Write-Host "You selected Option 2." -ForegroundColor Green
        # Add your Option 2 code here
        Start-Sleep -Seconds 2
    }

    function Show-InvalidOption {
        Clear-Host
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }

    # Main loop for App Menu
    while ($true) {
        Show-Header
        Show-Menu
        $selection = Read-Host "Please enter your choice"

        switch ($selection) {
            "1" { Option1 }
            "2" { Option2 }
            "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
            default { Show-InvalidOption }
        }
    }
}

# Main execution
Show-Header
Show-Menu
$selection = Read-Host "Please enter your choice"

switch ($selection) {
    "1" { Option1 }
    "2" { Option2 }
    "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
    default { Show-InvalidOption }
}
