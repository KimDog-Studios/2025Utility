# Main-Menu.ps1

# Function to download and execute a script from a URL
function Invoke-RemoteScript {
    param (
        [string]$url
    )

    try {
        $scriptContent = Invoke-RestMethod -Uri $url -Method Get
        Invoke-Expression $scriptContent
    } catch {
        Write-Host "Failed to fetch or execute script from $url: $_" -ForegroundColor Red
    }
}

# URLs of the scripts
$categoryScriptUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/Get-CategoryData.ps1"
$installScriptUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/Install-Application.ps1"

# Import functions from the remote scripts
Invoke-RemoteScript -url $categoryScriptUrl
Invoke-RemoteScript -url $installScriptUrl

# Function to maximize the PowerShell window
function Set-FullScreenWindow {
    $console = $Host.UI.RawUI
    $console.WindowSize = $console.MaxWindowSize
    $console.BufferSize = $console.MaxWindowSize
    $console.WindowPosition = New-Object System.Management.Automation.Host.Coordinates -ArgumentList 0,0
}

Set-FullScreenWindow

function Align-Header {
    param (
        [string]$Text,
        [int]$Width = 30
    )

    $Padding = $Width - $Text.Length
    $LeftPadding = [math]::Floor($Padding / 2)
    $RightPadding = [math]::Ceiling($Padding / 2)

    return ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
}

function Show-Header {
    Clear-Host
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Winget Menu" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

while ($true) {
    Show-Header
    Show-CategoryMenu

    $selection = Read-Host "Select a category"

    if ($selection -match '^\d+$') {
        $categoryIndex = [int]$selection
        if ($categoryIndex -eq 0) {
            Write-Host "Exiting script." -ForegroundColor Green
            exit
        } elseif ($categoryIndex -gt 0) {
            Show-AppsInCategory -categoryIndex $categoryIndex
        } else {
            Write-Host "Invalid category selection, please try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }
}
