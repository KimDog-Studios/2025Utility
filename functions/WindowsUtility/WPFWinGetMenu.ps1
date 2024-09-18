$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"

# Fetch JSON data from the URL
function Get-JsonData {
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

        return $data.categories
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
function Show-MainHeader {
    cls
    Write-Host "KimDog's Winget Menu | Last Updated: 2024-09-16" -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to display the main menu options
function Show-MainMenu {
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "`[*] $($menuOptions[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[ ] $($menuOptions[$i].Name)"  # Regular menu item
        }
    }
    "`n" | Out-String  # Explicitly add a line break after each option
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
        $categoryOptions += @{ Name = "$($category.name) [$($category.options.Count) Apps]"; Action = { Show-AppsInCategory -categoryIndex $i } }
    }
    
    $categoryOptions += @{ Name = "Back to Main Menu"; Action = { return } }

    $currentIndex = 0  # Reset current index for category menu
    while ($true) {
        Show-MainHeader
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
                $currentIndex = ($currentIndex - 1 + $categoryOptions.Count) % $categoryOptions.Count  # Move up
            }
            'DownArrow' {
                $currentIndex = ($currentIndex + 1) % $categoryOptions.Count  # Move down
            }
            'Enter' {
                Clear-Host  # Clear the screen before running the action
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

    while ($true) {
        cls
        Write-Host "Category: $($category.name)" -ForegroundColor Cyan
        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($page * $itemsPerPage, $apps.Count) - 1
        for ($i = $startIndex; $i -le $endIndex; $i++) {
            $app = $apps[$i]
            Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
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
        $input = Read-Host "Choose an option or enter app number"
        switch ($input.ToUpper()) {
            'N' { if ($page -lt $totalPages) { $page++ } else { Write-Host "Last page." -ForegroundColor Red } }
            'P' { if ($page -gt 1) { $page-- } else { Write-Host "First page." -ForegroundColor Red } }
            'B' { return }
            default {
                if ($input -match '^\d+$') {
                    $index = [int]$input - 1
                    if ($index -ge 0 -and $index -lt $apps.Count) {
                        Handle-AppSelection -app $apps[$index]
                    } else {
                        Write-Host "Invalid app selection. Please enter a number between 1 and $($apps.Count)." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input. Please enter a valid option." -ForegroundColor Red
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
    Write-Host "[W] Install with Winget" -ForegroundColor Green
    Write-Host "[C] Install with Chocolatey" -ForegroundColor Green
    Write-Host "[B] Back" -ForegroundColor Red
    Write-Host ""
    switch (Read-Host "Choose an option") {
        'W' {
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
        'C' {
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
        'B' { return }
        default {
            Write-Host "Invalid option. Please select [W], [C], or [B]." -ForegroundColor Red
        }
    }
}

# Main menu loop
while ($true) {
    Show-MainHeader
    Show-MainMenu

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
            & $menuOptions[$currentIndex].Action
        }
    }
    Start-Sleep -Milliseconds 100
}
