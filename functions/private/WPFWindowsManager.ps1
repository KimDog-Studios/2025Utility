# Define the URLs of the scripts to execute
$setServicesToManualUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/WPFSetServicesToManual.ps1"
$removeAppXFilesUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/WPFRemoveAppX.ps1"
$ultimatePerormanceUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/private/WPFUltimatePerformance.ps1"
$darkModeUrl = ""

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [string]$Url
    )

    try {
        Write-Host "Fetching script from $Url..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop

        if ($scriptContent) {
            Write-Host "Executing script content..." -ForegroundColor Green
            Invoke-Expression $scriptContent
        } else {
            Write-Host "No script content received." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to fetch or execute script: $_" -ForegroundColor Red
    }
}

# Function to align and display header
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

    Draw-Box -Text "KimDog's Windows Manager Menu | Last Updated: 2024-09-15"
    Write-Host "`n"
}

# Function to show the main menu
function Show-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Windows Manager" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Optimize for Gaming" -ForegroundColor Green
    Write-Host "2. Remove Bloatware [Windows 11]" -ForegroundColor Green
    Write-Host "3. Add & Apply Ultimate Performance Mode" -ForegroundColor Green
    Write-Host "4. Apply Dark Mode to Windows" -ForegroundColor Green
    Write-Host "5. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"  # Reduced gap
}

# Function for Option 1
function Option1 {
    Clear-Host
    Write-Host "You selected Option 1: Optimize for Gaming" -ForegroundColor Green
    Run-ScriptFromUrl -Url $setServicesToManualUrl
}

# Function for Option 2
function Option2 {
    Clear-Host
    Write-Host "You selected Option 2: Remove Bloatware" -ForegroundColor Green
    Run-ScriptFromUrl -Url $removeAppXFilesUrl
}

function Option3 {
    Clear-Host
    Write-Host "You selected Option 3: Add & Apply Ultimate Performance Mode" -ForegroundColor Green
    Run-ScriptFromUrl -Url $ultimatePerormanceUrl
}

# Function for Option 4
function Option4 {
    Clear-Host
    Write-Host "You selected Option 4: Apply Dark Mode to Windows" -ForegroundColor Green
    Run-ScriptFromUrl -Url $darkModeUrl

# Function for invalid option
function Show-InvalidOption {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main loop
while ($true) {
    Show-MainHeader
    Show-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Option1 }
        "2" { Option2 }
        "3" { Option3 }
        "4" { Option4 }
        "5" { Write-Host "Exiting..." -ForegroundColor Red; exit }
        default { Show-InvalidOption }
    }
}
