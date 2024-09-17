# Function to align header text
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

function Show-MainHeader {
    Clear-Host

    function Draw-Box {
        param (
            [string]$Text
        )

        $boxWidth = $Text.Length + 4
        $topBottomBorder = "+" + ("-" * ($boxWidth - 2)) + "+"
        $emptyLine = "|" + (" " * ($boxWidth - 2)) + "|"

        Write-Host "$topBottomBorder" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "| $Text |" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "$topBottomBorder" -ForegroundColor Cyan
    }

    Draw-Box -Text "KimDog's Windows Utility | Last Updated: 2024-09-15"
    Write-Host "`n"
}

# Function to show a message if winget is installed
function Show-WingetMessage {
    $wingetCommand = "winget"
    $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue

    if ($wingetPath -ne $null) {
        Write-Host "[INFO] WinGet is Installed." -ForegroundColor Green
    } else {
        Write-Host "[INFO] WinGet is not installed." -ForegroundColor Yellow
    }
}

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

# Function to create a shortcut using Invoke-WPFShortcut
function Invoke-WPFShortcut {
    <#

    .SYNOPSIS
        Creates a shortcut and prompts for a save location

    .PARAMETER ShortcutToAdd
        The name of the shortcut to add

    .PARAMETER RunAsAdmin
        A boolean value to make 'Run as administrator' property on (true) or off (false), defaults to off

    #>
    param(
        $ShortcutToAdd,
        [bool]$RunAsAdmin = $false
    )

    # Prepare the Shortcut Fields and add a Custom Icon if it's available, else don't add a Custom Icon.
    Switch ($ShortcutToAdd) {
        "WinUtil" {
            # Use Powershell 7 if installed and fallback to PS5 if not
            if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
                $shell = "pwsh.exe"
            } else {
                $shell = "powershell.exe"
            }

            $shellArgs = "-ExecutionPolicy Bypass -Command `"Start-Process $shell -verb runas -ArgumentList `'-Command `"irm https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/WindowsUtility/WPFStarter.ps1 | iex`"`'"
            $DestinationName = "KimDog's Windows Utility.lnk"
        }
    }

    # Show a File Dialog Browser, to let the User choose the Name and Location of where to save the Shortcut
    $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $FileBrowser.Filter = "Shortcut Files (*.lnk)|*.lnk"
    $FileBrowser.FileName = $DestinationName

    # Do an Early Return if the Save Operation was canceled by User's Input.
    $FileBrowserResult = $FileBrowser.ShowDialog()
    $DialogResultEnum = New-Object System.Windows.Forms.DialogResult
    if (-not ($FileBrowserResult -eq $DialogResultEnum::OK)) {
        return
    }

    # Prepare the Shortcut parameter
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($FileBrowser.FileName)
    $Shortcut.TargetPath = $shell
    $Shortcut.Arguments = $shellArgs
    if (-NOT (Test-Path -Path $winutildir["logo.ico"])) {
        Invoke-WebRequest -Uri "https://christitus.com/images/logo-full.ico" -OutFile $winutildir["logo.ico"]
    }
    if (Test-Path -Path $winutildir["logo.ico"]) {
        $Shortcut.IconLocation = $winutildir["logo.ico"]
    }

    # Save the Shortcut to disk
    $Shortcut.Save()

    if ($RunAsAdmin -eq $true) {
        $bytes = [System.IO.File]::ReadAllBytes($FileBrowser.FileName)
        # Set byte value at position 0x15 in hex, or 21 in decimal, from the value 0x00 to 0x20 in hex
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($FileBrowser.FileName, $bytes)
    }

    Write-Host "Shortcut for $ShortcutToAdd has been saved to $($FileBrowser.FileName) with 'Run as administrator' set to $RunAsAdmin"
}

# Automatically run the shortcut creation function
$urls = Fetch-UrlsFromJson
$invokeWPFShortcutUrl = $urls.InvokeWPFShortcut.URL
Invoke-WPFShortcut -ShortcutToAdd "WinUtil" -RunAsAdmin $true

# Show the main menu for additional options
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Windows Manager" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

# Function for Option 1: Windows Manager
function Option1 {
    param (
        [string]$windowsManagerUrl
    )
    Clear-Host
    Write-Host "You selected Option 1: Windows Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $windowsManagerUrl
}

# Function for Option 2: Application Manager
function Option2 {
    param (
        [string]$wingetMenuUrl
    )
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green
    Run-ScriptFromUrl -Url $wingetMenuUrl
}

# Function for invalid option
function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main script execution
do {
    Show-MainHeader
    Show-WingetMessage
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 -windowsManagerUrl $urls.WPFWindowsManager.URL }
        "2" { Option2 -wingetMenuUrl $urls.WPFWinGetMenu.URL }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidOption }
    }

} while ($true)
