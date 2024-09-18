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

# Function to show the main header
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
function Show-WingetStatus {
    $wingetCommand = "winget"
    $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue

    if ($wingetPath -ne $null) {
        Write-Host "[INFO] WinGet is Installed." -ForegroundColor Green
    } else {
        Write-Host "[INFO] WinGet is not installed." -ForegroundColor Yellow
    }
}

# Function to fetch URLs from the JSON file
function Fetch-Urls {
    $jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"
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
function Execute-ScriptFromUrl {
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

# Function to show the main menu for additional options
function Display-MainMenu {
    $MenuWidth = 30

    Write-Host (Align-Header "Main Menu" $MenuWidth) -ForegroundColor Yellow
    Write-Host "1. Windows Manager" -ForegroundColor Green
    Write-Host "2. Application Manager" -ForegroundColor Green
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host (Align-Header "=" $MenuWidth) -ForegroundColor Cyan
    Write-Host "`n"
}

# Function for Option 1: Windows Manager
function Execute-WindowsManager {
    param (
        [string]$windowsManagerUrl
    )
    Clear-Host
    Write-Host "You selected Option 1: Windows Manager" -ForegroundColor Green
    Execute-ScriptFromUrl -Url $windowsManagerUrl
}

# Function for Option 2: Application Manager
function Execute-ApplicationManager {
    param (
        [string]$wingetMenuUrl
    )
    Clear-Host
    Write-Host "You selected Option 2: Application Manager" -ForegroundColor Green
    Execute-ScriptFromUrl -Url $wingetMenuUrl
}

# Function for invalid option
function Show-InvalidSelection {
    Clear-Host
    Write-Host "Invalid selection, please try again." -ForegroundColor Red
}

# Main script execution
$urls = Fetch-Urls  # Fetch URLs at the start

do {
    Show-MainHeader
    Show-WingetStatus
    Display-MainMenu
    $selection = Read-Host "Please enter your choice"

    switch ($selection) {
        "1" { Execute-WindowsManager -windowsManagerUrl $urls.WPFWindowsManager.URL }
        "2" { Execute-ApplicationManager -wingetMenuUrl $urls.WPFWinGetMenu.URL }
        "3" { Write-Host "Exiting..." -ForegroundColor Red; break }
        default { Show-InvalidSelection }
    }

} while ($true)

# Fetch JSON data from the URL
function Get-JsonData {
    $jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"
    try {
        $response = Invoke-WebRequest -Uri $jsonFileUrl -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            Write-Host "HTTP Error: Status code $($response.StatusCode)" -ForegroundColor Red
            return $null
        }

        $data = $response.Content | ConvertFrom-Json

        if (-not $data.categories) {
            Write-Host "JSON does not contain a 'categories' property." -ForegroundColor Red
            return $null
        }

        return $data.categories  # Ensure this returns the categories array
    } catch {
        Write-Host "Error fetching or parsing data: $_" -ForegroundColor Red
        Write-Host "Exception details: $($_.Exception)" -ForegroundColor Red
        return $null
    }
}

# Define menu options and their corresponding actions
$menuOptions = @(
    @{ Name = "Display Categories"; Action = { Show-CategoryMenu } },
    @{ Name = "Search All Apps"; Action = { 
        $searchTerm = Read-Host "Enter search term"
        Show-SearchResults -searchTerm $searchTerm 
    }},
    @{ Name = "Upgrade All Installed Apps & Drivers"; Action = { Upgrade-InstalledApps } },
    @{ Name = "Exit"; Action = { Write-Host "Exiting..." -ForegroundColor Red; exit } }
)

$currentIndex = 0  # Track the current index in the main menu

# Function to show the main header
function Show-WingetMainHeader {
    cls
    Write-Host "KimDog's Winget Menu | Last Updated: 2024-09-16" -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to display the main menu options
function Show-WingetMainMenu {
    $currentIndex = 0  # Track the current index in the main menu
    while ($true) {
        Show-WingetMainHeader
        Write-Host "Main Menu Options:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $menuOptions.Count; $i++) {
            if ($i -eq $currentIndex) {
                Write-Host "`[*] $($menuOptions[$i].Name)" -ForegroundColor Yellow
            } else {
                Write-Host "`[ ] $($menuOptions[$i].Name)"
            }
        }
        "`n" | Out-String

        # Read key input
        $key = [System.Console]::ReadKey($true)

        # Handle arrow keys and selection
        switch ($key.Key) {
            'UpArrow' {
                $currentIndex = ($currentIndex - 1 + $menuOptions.Count) % $menuOptions.Count
            }
            'DownArrow' {
                $currentIndex = ($currentIndex + 1) % $menuOptions.Count
            }
            'Enter' {
                Clear-Host
                & $menuOptions[$currentIndex].Action  # Execute the selected option
            }
        }
        Start-Sleep -Milliseconds 100
    }
}

# Function to display categories in a menu format
function Show-CategoryMenu {
    cls
    $categories = Get-JsonData
    if (-not $categories) {
        Write-Host "No categories found." -ForegroundColor Red
        return
    }

    $categoryOptions = @()
    for ($i = 0; $i -lt $categories.Count; $i++) {
        $category = $categories[$i]
        $index = $i  # Capture the current index
        $categoryOptions += @{ Name = "$($category.name) [$($category.options.Count) Apps]"; Action = { Show-AppsInCategory -categoryIndex $index } }
    }
    
    $categoryOptions += @{ Name = "Back to Main Menu"; Action = { return } }

    $currentIndex = 0  # Reset current index for category menu
    while ($true) {
        Show-WingetMainHeader
        Write-Host "Category Menu Options:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $categoryOptions.Count; $i++) {
            if ($i -eq $currentIndex) {
                Write-Host "`[*] $($categoryOptions[$i].Name)" -ForegroundColor Yellow
            } else {
                Write-Host "`[ ] $($categoryOptions[$i].Name)"
            }
        }
        "`n" | Out-String

        # Read key input
        $key = [System.Console]::ReadKey($true)

        # Handle arrow keys and selection
        switch ($key.Key) {
            'UpArrow' {
                $currentIndex = ($currentIndex - 1 + $categoryOptions.Count) % $categoryOptions.Count
            }
            'DownArrow' {
                $currentIndex = ($currentIndex + 1) % $categoryOptions.Count
            }
            'Enter' {
                Clear-Host
                & $categoryOptions[$currentIndex].Action  # Execute the selected option
            }
        }
        Start-Sleep -Milliseconds 100
    }
}

# Display apps in a category with pagination
function Show-AppsInCategory {
    param ([int]$categoryIndex)
    $categories = Get-JsonData

    if ($categoryIndex -lt 0 -or $categoryIndex -ge $categories.Count) {
        Write-Host "Invalid category index. Please restart and select a valid category." -ForegroundColor Red
        return
    }

    $category = $categories[$categoryIndex]
    $apps = $category.options
    $itemsPerPage = 5
    $totalPages = [math]::Ceiling($apps.Count / $itemsPerPage)
    $page = 1
    $currentIndex = 0  # Track the current index of the app selection

    while ($true) {
        cls
        Write-Host "Category: $($category.name)" -ForegroundColor Cyan
        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($page * $itemsPerPage, $apps.Count) - 1

        Write-Host "Apps in this category:" -ForegroundColor Cyan
        for ($i = $startIndex; $i -le $endIndex; $i++) {
            $app = $apps[$i]
            if ($i -eq $startIndex + $currentIndex) {
                Write-Host "`[*] $($app.name)" -ForegroundColor Yellow  # Highlight selected app
            } else {
                Write-Host "`[ ] $($app.name)"
            }
            Write-Host "   Description: $($app.description)" -ForegroundColor White
            Write-Host "   Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
            Write-Host ""
        }

        Write-Host "Page $page of $totalPages" -ForegroundColor Yellow
        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Category Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""

        # Read key input
        $key = [System.Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow' {
                if ($currentIndex -gt 0) {
                    $currentIndex--  # Move up in the list
                }
            }
            'DownArrow' {
                if ($currentIndex -lt [math]::Min($itemsPerPage - 1, $endIndex - $startIndex)) {
                    $currentIndex++  # Move down in the list
                }
            }
            'N' {
                if ($page -lt $totalPages) { $page++ } else { Write-Host "Last page." -ForegroundColor Red }
                $currentIndex = 0  # Reset current index when changing pages
            }
            'P' {
                if ($page -gt 1) { $page-- } else { Write-Host "First page." -ForegroundColor Red }
                $currentIndex = 0  # Reset current index when changing pages
            }
            'B' { return }
            'Enter' {
                # Handle app selection
                $selectedAppIndex = $startIndex + $currentIndex
                if ($selectedAppIndex -ge 0 -and $selectedAppIndex -lt $apps.Count) {
                    Handle-AppSelection -app $apps[$selectedAppIndex]
                }
            }
        }
    }
}

# Upgrade all installed apps
function Upgrade-InstalledApps {
    cls
    Write-Host "Upgrading apps with Winget..." -ForegroundColor Cyan
    try {
        winget upgrade --all
        Write-Host "Upgrade completed." -ForegroundColor Green
    } catch {
        Write-Host "Upgrade failed: $_" -ForegroundColor Red
    }
}

# Handle app selection and installation
function Handle-AppSelection {
    param ([PSCustomObject]$app)
    cls
    Write-Host "`nSelected App:" -ForegroundColor Green
    Write-Host "Name: $($app.name)" -ForegroundColor Cyan
    Write-Host "Description: $($app.description)" -ForegroundColor White
    Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
    Write-Host "Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
    Write-Host "`nOptions:" -ForegroundColor Yellow

    # Define installation options
    $options = @(
        @{ Name = "Install with Winget"; Action = { Install-WithWinget -app $app } },
        @{ Name = "Install with Chocolatey"; Action = { Install-WithChocolatey -app $app } },
        @{ Name = "Back"; Action = { return } }
    )

    $currentIndex = 0  # Track the current index in the options menu

    while ($true) {
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($i -eq $currentIndex) {
                Write-Host "`[*] $($options[$i].Name)" -ForegroundColor Yellow  # Highlight selected option
            } else {
                Write-Host "`[ ] $($options[$i].Name)"
            }
        }
        Write-Host ""

        # Read key input
        $key = [System.Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow' {
                $currentIndex = ($currentIndex - 1 + $options.Count) % $options.Count  # Move up
            }
            'DownArrow' {
                $currentIndex = ($currentIndex + 1) % $options.Count  # Move down
            }
            'Enter' {
                & $options[$currentIndex].Action  # Execute the selected option
                break  # Exit the loop after executing the action
            }
        }
        Start-Sleep -Milliseconds 100
        cls  # Clear the screen for the next display
    }
}

# Function to install with Winget
function Install-WithWinget {
    param ([PSCustomObject]$app)
    if ($app.wingetId) {
        Write-Host "Installing with Winget..." -ForegroundColor Cyan
        try {
            winget install --id $app.wingetId
            Write-Host "Installation completed." -ForegroundColor Green
        } catch {
            Write-Host "Installation failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "No Winget ID available for this app." -ForegroundColor Red
    }
}

# Function to install with Chocolatey
function Install-WithChocolatey {
    param ([PSCustomObject]$app)
    if ($app.chocoId) {
        Write-Host "Installing with Chocolatey..." -ForegroundColor Cyan
        try {
            choco install $app.chocoId
            Write-Host "Installation completed." -ForegroundColor Green
        } catch {
            Write-Host "Installation failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "No Chocolatey ID available for this app." -ForegroundColor Red
    }
}

# Main menu loop
Display-MainMenu