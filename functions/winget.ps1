$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Function to fetch JSON data
function Get-JsonData {
    try {
        $jsonData = Invoke-RestMethod -Uri $jsonFileUrl -Method Get
        if ($jsonData -and $jsonData.categories) {
            return $jsonData.categories
        } else {
            Write-Host "JSON structure is invalid or missing 'categories'." -ForegroundColor Red
            exit
        }
    } catch {
        Write-Host "Failed to fetch JSON data: $_" -ForegroundColor Red
        exit
    }
}

# Function to align header text
function Align-Header {
    param (
        [string]$Text,
        [int]$Width = 50
    )

    $TextLength = $Text.Length
    if ($TextLength -ge $Width) {
        return $Text
    }
    $Padding = $Width - $TextLength
    $LeftPadding = [math]::Floor($Padding / 2)
    $RightPadding = [math]::Ceiling($Padding / 2)

    return ("=" * $LeftPadding) + $Text + ("=" * $RightPadding)
}

# Function to draw a box around text
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

# Function to display the main header
function Show-Header {
    cls
    Draw-Box -Text "KimDog's Winget Menu | Last Updated: 2024-09-16"
    Write-Host "`n"
}

# Function to display the category menu
function Show-CategoryMenu {
    cls
    $categories = Get-JsonData
    if (!$categories) {
        Write-Host "No categories found in the JSON data." -ForegroundColor Red
        return
    }

    Write-Host "`nCategories:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $categories.Count; $i++) {
        $category = $categories[$i]
        Write-Host "[$($i + 1)] $($category.name) [$($category.options.Count) Apps]" -ForegroundColor Cyan
    }

    Write-Host "[F] Search All Apps" -ForegroundColor Green
    Write-Host "[U] Upgrade All Installed Apps & Drivers" -ForegroundColor Green
    Write-Host "[X] Exit Script" -ForegroundColor Red
    Write-Host "`n"
}

# Function to display apps in a selected category with pagination
function Show-AppsInCategory {
    param (
        [int]$categoryIndex
    )

    cls
    $categories = Get-JsonData

    if ($categoryIndex -lt 1 -or $categoryIndex -gt $categories.Count) {
        Write-Host "Invalid category selection." -ForegroundColor Red
        return
    }

    $selectedCategory = $categories[$categoryIndex - 1]
    $apps = $selectedCategory.options
    $totalApps = $apps.Count
    $itemsPerPage = 5
    $page = 1
    $totalPages = [math]::Ceiling($totalApps / $itemsPerPage)

    while ($true) {
        cls
        Draw-Box -Text "Category: $($selectedCategory.name)"

        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalApps)

        for ($i = $startIndex; $i -lt $endIndex; $i++) {
            $app = $apps[$i]
            Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
            Write-Host "   Description: $($app.description)" -ForegroundColor White
            Write-Host "   Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
            Write-Host ""
        }

        $pageIndicator = "Page $page of $totalPages"
        Draw-Box -Text $pageIndicator

        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Category Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""

        $input = Read-Host "Choose an option or enter app number to install"

        switch ($input.ToUpper()) {
            'N' {
                if ($page -lt $totalPages) {
                    $page++
                } else {
                    Write-Host "You are already on the last page." -ForegroundColor Red
                }
            }
            'P' {
                if ($page -gt 1) {
                    $page--
                } else {
                    Write-Host "You are already on the first page." -ForegroundColor Red
                }
            }
            'B' {
                return
            }
            default {
                if ($input -match '^\d+$') {
                    $selectedAppIndex = [int]$input - 1
                    if ($selectedAppIndex -ge $startIndex -and $selectedAppIndex -lt $endIndex) {
                        Handle-AppSelection -app $apps[$selectedAppIndex]
                    } else {
                        Write-Host "Invalid app selection, please try again." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
                }
            }
        }
    }
}

# Function to display search results with pagination
function Show-SearchResults {
    param (
        [string]$searchTerm
    )

    cls
    $categories = Get-JsonData
    $searchResults = @()

    foreach ($category in $categories) {
        foreach ($app in $category.options) {
            if ($app.name -imatch $searchTerm -or $app.description -imatch $searchTerm) {
                $searchResults += [PSCustomObject]@{
                    Name = $app.name
                    Description = $app.description
                    WingetId = $app.wingetId
                    ChocolateyId = $app.chocoId
                }
            }
        }
    }

    if ($searchResults.Count -eq 0) {
        Write-Host "No results found for '$searchTerm'." -ForegroundColor Red
        return
    }

    $totalResults = $searchResults.Count
    $itemsPerPage = 5
    $page = 1
    $totalPages = [math]::Ceiling($totalResults / $itemsPerPage)

    while ($true) {
        cls
        Draw-Box -Text "Search Results | Search Term: '$searchTerm'"

        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalResults)

        for ($i = $startIndex; $i -lt $endIndex; $i++) {
            $result = $searchResults[$i]
            Write-Host "$($i + 1). $($result.Name)" -ForegroundColor Green
            Write-Host "   Description: $($result.Description)" -ForegroundColor White
            Write-Host "   Winget ID: $($result.WingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($result.ChocolateyId)" -ForegroundColor Cyan
            Write-Host ""
        }

        $pageIndicator = "Page $page of $totalPages"
        Draw-Box -Text $pageIndicator

        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Main Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""

        $input = Read-Host "Choose an option or enter result number to install"

        switch ($input.ToUpper()) {
            'N' {
                if ($page -lt $totalPages) {
                    $page++
                } else {
                    Write-Host "You are already on the last page." -ForegroundColor Red
                }
            }
            'P' {
                if ($page -gt 1) {
                    $page--
                } else {
                    Write-Host "You are already on the first page." -ForegroundColor Red
                }
            }
            'B' {
                return
            }
            default {
                if ($input -match '^\d+$') {
                    $selectedResultIndex = [int]$input - 1
                    if ($selectedResultIndex -ge $startIndex -and $selectedResultIndex -lt $endIndex) {
                        Handle-AppSelection -app $searchResults[$selectedResultIndex]
                    } else {
                        Write-Host "Invalid result selection, please try again." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
                }
            }
        }
    }
}

# Function to upgrade all installed apps using Winget
function Upgrade-InstalledApps {
    cls
    Write-Host "Upgrading all installed apps using Winget..." -ForegroundColor Cyan
    try {
        winget upgrade --all
        Write-Host "Upgrade process completed." -ForegroundColor Green
    } catch {
        Write-Host "Failed to upgrade apps: $_" -ForegroundColor Red
    }
}

# Function to handle app selection and installation
function Handle-AppSelection {
    param (
        [PSCustomObject]$app
    )

    cls
    Write-Host "`nSelected App:" -ForegroundColor Green
    Write-Host "Name: $($app.Name)" -ForegroundColor Cyan
    Write-Host "Description: $($app.Description)" -ForegroundColor White
    Write-Host "Winget ID: $($app.WingetId)" -ForegroundColor Cyan
    Write-Host "Chocolatey ID: $($app.ChocolateyId)" -ForegroundColor Cyan
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "[W] Install with Winget" -ForegroundColor Green
    Write-Host "[C] Install with Chocolatey" -ForegroundColor Green
    Write-Host "[B] Back to Previous Menu" -ForegroundColor Red
    Write-Host ""

    $input = Read-Host "Choose an option"

    switch ($input.ToUpper()) {
        'W' {
            if ($app.WingetId) {
                Write-Host "Installing $($app.Name) with Winget..." -ForegroundColor Cyan
                try {
                    winget install --id $app.WingetId --silent
                    Write-Host "Installation started for $($app.Name)." -ForegroundColor Green
                } catch {
                    Write-Host "Failed to install with Winget: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Winget ID not found for $($app.Name)." -ForegroundColor Red
            }
        }
        'C' {
            if ($app.ChocolateyId) {
                Write-Host "Installing $($app.Name) with Chocolatey..." -ForegroundColor Cyan
                try {
                    choco install $app.ChocolateyId -y
                    Write-Host "Installation started for $($app.Name)." -ForegroundColor Green
                } catch {
                    Write-Host "Failed to install with Chocolatey: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Chocolatey ID not found for $($app.Name)." -ForegroundColor Red
            }
        }
        'B' {
            return
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor Red
        }
    }

    # Wait for user to acknowledge before returning
    Read-Host "Press Enter to continue..."
}

# Function to display search results and handle selections
function Show-SearchResults {
    param (
        [string]$searchTerm
    )

    cls
    $categories = Get-JsonData
    $searchResults = @()

    foreach ($category in $categories) {
        foreach ($app in $category.options) {
            if ($app.name -imatch $searchTerm -or $app.description -imatch $searchTerm) {
                $searchResults += [PSCustomObject]@{
                    Name = $app.name
                    Description = $app.description
                    WingetId = $app.wingetId
                    ChocolateyId = $app.chocoId
                }
            }
        }
    }

    if ($searchResults.Count -eq 0) {
        Write-Host "No results found for '$searchTerm'." -ForegroundColor Red
        return
    }

    $totalResults = $searchResults.Count
    $itemsPerPage = 5
    $page = 1
    $totalPages = [math]::Ceiling($totalResults / $itemsPerPage)

    while ($true) {
        cls
        Draw-Box -Text "Search Results | Search Term: '$searchTerm'"

        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalResults)

        for ($i = $startIndex; $i -lt $endIndex; $i++) {
            $result = $searchResults[$i]
            Write-Host "$($i + 1). $($result.Name)" -ForegroundColor Green
            Write-Host "   Description: $($result.Description)" -ForegroundColor White
            Write-Host "   Winget ID: $($result.WingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($result.ChocolateyId)" -ForegroundColor Cyan
            Write-Host ""
        }

        $pageIndicator = "Page $page of $totalPages"
        Draw-Box -Text $pageIndicator

        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Main Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""

        $input = Read-Host "Choose an option or enter result number to install"

        switch ($input.ToUpper()) {
            'N' {
                if ($page -lt $totalPages) {
                    $page++
                } else {
                    Write-Host "You are already on the last page." -ForegroundColor Red
                }
            }
            'P' {
                if ($page -gt 1) {
                    $page--
                } else {
                    Write-Host "You are already on the first page." -ForegroundColor Red
                }
            }
            'B' {
                return
            }
            default {
                if ($input -match '^\d+$') {
                    $selectedResultIndex = [int]$input - 1
                    if ($selectedResultIndex -ge $startIndex -and $selectedResultIndex -lt $endIndex) {
                        Handle-AppSelection -app $searchResults[$selectedResultIndex]
                    } else {
                        Write-Host "Invalid result selection, please try again." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
                }
            }
        }
    }
}

# Function to upgrade all installed apps using Winget
function Upgrade-InstalledApps {
    cls
    Write-Host "Upgrading all installed apps using Winget..." -ForegroundColor Cyan
    try {
        winget upgrade --all
        Write-Host "Upgrade process completed." -ForegroundColor Green
    } catch {
        Write-Host "Failed to upgrade apps: $_" -ForegroundColor Red
    }
}

# Function to handle app installation
function Handle-AppSelection {
    param (
        [PSCustomObject]$app
    )

    cls
    Write-Host "`nSelected App:" -ForegroundColor Green
    Write-Host "Name: $($app.Name)" -ForegroundColor Cyan
    Write-Host "Description: $($app.Description)" -ForegroundColor White
    Write-Host "Winget ID: $($app.WingetId)" -ForegroundColor Cyan
    Write-Host "Chocolatey ID: $($app.ChocolateyId)" -ForegroundColor Cyan
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "[W] Install with Winget" -ForegroundColor Green
    Write-Host "[C] Install with Chocolatey" -ForegroundColor Green
    Write-Host "[B] Back to Previous Menu" -ForegroundColor Red
    Write-Host ""

    $input = Read-Host "Choose an option"

    switch ($input.ToUpper()) {
        'W' {
            if ($app.WingetId) {
                Write-Host "Installing $($app.Name) with Winget..." -ForegroundColor Cyan
                try {
                    winget install --id $app.WingetId --silent
                    Write-Host "Installation started for $($app.Name)." -ForegroundColor Green
                } catch {
                    Write-Host "Failed to install with Winget: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Winget ID not found for $($app.Name)." -ForegroundColor Red
            }
        }
        'C' {
            if ($app.ChocolateyId) {
                Write-Host "Installing $($app.Name) with Chocolatey..." -ForegroundColor Cyan
                try {
                    choco install $app.ChocolateyId -y
                    Write-Host "Installation started for $($app.Name)." -ForegroundColor Green
                } catch {
                    Write-Host "Failed to install with Chocolatey: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Chocolatey ID not found for $($app.Name)." -ForegroundColor Red
            }
        }
        'B' {
            return
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor Red
        }
    }

    # Wait for user to acknowledge before returning
    Read-Host "Press Enter to continue..."
}

# Main menu function
function Main-Menu {
    Show-Header

    while ($true) {
        Show-CategoryMenu
        $input = Read-Host "Select a category or option"

        switch ($input.ToUpper()) {
            'X' {
                Write-Host "Exiting the script..." -ForegroundColor Yellow
                exit
            }
            'U' {
                Upgrade-InstalledApps
            }
            'F' {
                $searchTerm = Read-Host "Enter a search term"
                Show-SearchResults -searchTerm $searchTerm
            }
            default {
                if ($input -match '^\d+$') {
                    $categoryIndex = [int]$input
                    Show-AppsInCategory -categoryIndex $categoryIndex
                } else {
                    Write-Host "Invalid selection, please try again." -ForegroundColor Red
                }
            }
        }
    }
}

# Execute the main menu
Main-Menu
