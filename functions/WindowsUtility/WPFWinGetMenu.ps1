$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Fetch JSON data
function Get-JsonData {
    try {
        $data = Invoke-RestMethod -Uri $jsonFileUrl
        if ($data?.categories) { return $data.categories }
        Write-Host "Invalid JSON or missing 'categories'." -ForegroundColor Red
    } catch {
        Write-Host "Error fetching data: $_" -ForegroundColor Red
    }
    exit
}

# Align header text
function Align-Header {
    param ([string]$Text, [int]$Width = 50)
    $Text.PadLeft(([math]::Ceiling($Width / 2) + $Text.Length) - 1, "=").PadRight($Width, "=")
}

# Draw a box around text
function Draw-Box {
    param ([string]$Text)
    $width = $Text.Length + 4
    $border = "+" + ("-" * ($width - 2)) + "+"
    $empty = "|" + (" " * ($width - 2)) + "|"
    Write-Host "$border" -ForegroundColor Cyan
    Write-Host "$empty" -ForegroundColor Cyan
    Write-Host "| $Text |" -ForegroundColor Cyan
    Write-Host "$empty" -ForegroundColor Cyan
    Write-Host "$border" -ForegroundColor Cyan
}

# Display header
function Show-Header {
    cls
    Draw-Box -Text "KimDog's Winget Menu | Last Updated: 2024-09-16"
    Write-Host "`n"
}

# Display category menu
function Show-CategoryMenu {
    cls
    $categories = Get-JsonData
    if (!$categories) {
        Write-Host "No categories found." -ForegroundColor Red
        return
    }
    Write-Host "`nCategories:" -ForegroundColor Yellow
    $categories | ForEach-Object { Write-Host "[{0}] {1} [{2} Apps]" -f ($categories.IndexOf($_) + 1), $_.name, $_.options.Count -ForegroundColor Cyan }
    Write-Host "[F] Search All Apps" -ForegroundColor Green
    Write-Host "[U] Upgrade All Installed Apps & Drivers" -ForegroundColor Green
    Write-Host "[X] Exit Script" -ForegroundColor Red
    Write-Host "`n"
}

# Display apps in a category with pagination
function Show-AppsInCategory {
    param ([int]$categoryIndex)
    cls
    $categories = Get-JsonData
    if ($categoryIndex -lt 1 -or $categoryIndex -gt $categories.Count) {
        Write-Host "Invalid category." -ForegroundColor Red
        return
    }
    $category = $categories[$categoryIndex - 1]
    $apps = $category.options
    $itemsPerPage = 5
    $totalPages = [math]::Ceiling($apps.Count / $itemsPerPage)
    $page = 1

    while ($true) {
        cls
        Draw-Box -Text "Category: $($category.name)"
        $apps[$((($page - 1) * $itemsPerPage)..([math]::Min($page * $itemsPerPage, $apps.Count) - 1))] | ForEach-Object {
            Write-Host "$($_.Index + 1). $($_.name)" -ForegroundColor Green
            Write-Host "   Description: $($_.description)" -ForegroundColor White
            Write-Host "   Winget ID: $($_.wingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($_.chocoId)" -ForegroundColor Cyan
            Write-Host ""
        }
        Draw-Box -Text "Page $page of $totalPages"
        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Category Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""
        switch (Read-Host "Choose an option or enter app number") {
            'N' { if ($page -lt $totalPages) { $page++ } else { Write-Host "Last page." -ForegroundColor Red } }
            'P' { if ($page -gt 1) { $page-- } else { Write-Host "First page." -ForegroundColor Red } }
            'B' { return }
            default {
                if ($input -match '^\d+$') {
                    $index = [int]$input - 1
                    if ($index -ge ($page - 1) * $itemsPerPage -and $index -lt $page * $itemsPerPage) {
                        Handle-AppSelection -app $apps[$index]
                    } else {
                        Write-Host "Invalid app selection." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input." -ForegroundColor Red
                }
            }
        }
    }
}

# Display search results with pagination
function Show-SearchResults {
    param ([string]$searchTerm)
    cls
    $categories = Get-JsonData
    $results = $categories | ForEach-Object { $_.options | Where-Object { $_.name -imatch $searchTerm -or $_.description -imatch $searchTerm } }

    if ($results.Count -eq 0) {
        Write-Host "No results for '$searchTerm'." -ForegroundColor Red
        return
    }
    $itemsPerPage = 5
    $totalPages = [math]::Ceiling($results.Count / $itemsPerPage)
    $page = 1

    while ($true) {
        cls
        Draw-Box -Text "Search Results | Term: '$searchTerm'"
        $results[$((($page - 1) * $itemsPerPage)..([math]::Min($page * $itemsPerPage, $results.Count) - 1))] | ForEach-Object {
            Write-Host "$($_.Index + 1). $($_.Name)" -ForegroundColor Green
            Write-Host "   Description: $($_.Description)" -ForegroundColor White
            Write-Host "   Winget ID: $($_.WingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($_.ChocolateyId)" -ForegroundColor Cyan
            Write-Host ""
        }
        Draw-Box -Text "Page $page of $totalPages"
        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "[B] Back to Main Menu" -ForegroundColor Red
        if ($page -lt $totalPages) { Write-Host "[N] Next Page" -ForegroundColor Cyan }
        if ($page -gt 1) { Write-Host "[P] Previous Page" -ForegroundColor Cyan }
        Write-Host ""
        switch (Read-Host "Choose an option or result number") {
            'N' { if ($page -lt $totalPages) { $page++ } else { Write-Host "Last page." -ForegroundColor Red } }
            'P' { if ($page -gt 1) { $page-- } else { Write-Host "First page." -ForegroundColor Red } }
            'B' { return }
            default {
                if ($input -match '^\d+$') {
                    $index = [int]$input - 1
                    if ($index -ge (($page - 1) * $itemsPerPage) -and $index -lt ($page * $itemsPerPage)) {
                        Handle-AppSelection -app $results[$index]
                    } else {
                        Write-Host "Invalid result selection." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input." -ForegroundColor Red
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
    Write-Host "Name: $($app.Name)" -ForegroundColor Cyan
    Write-Host "Description: $($app.Description)" -ForegroundColor White
    Write-Host "Winget ID: $($app.WingetId)" -ForegroundColor Cyan
    Write-Host "Chocolatey ID: $($app.ChocolateyId)" -ForegroundColor Cyan
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "[W] Install with Winget" -ForegroundColor Green
    Write-Host "[C] Install with Chocolatey" -ForegroundColor Green
    Write-Host "[B] Back" -ForegroundColor Red
    Write-Host ""
    switch (Read-Host "Choose an option") {
        'W' {
            if ($app.WingetId) {
                Write-Host "Installing with Winget..." -ForegroundColor Cyan
                try {
                    winget install --id $app.WingetId
                    Write-Host "Installation completed." -ForegroundColor Green
                } catch {
                    Write-Host "Installation failed: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "No Winget ID available for this app." -ForegroundColor Red
            }
        }
        'C' {
            if ($app.ChocolateyId) {
                Write-Host "Installing with Chocolatey..." -ForegroundColor Cyan
                try {
                    choco install $app.ChocolateyId
                    Write-Host "Installation completed." -ForegroundColor Green
                } catch {
                    Write-Host "Installation failed: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "No Chocolatey ID available for this app." -ForegroundColor Red
            }
        }
        'B' { return }
        default { Write-Host "Invalid option." -ForegroundColor Red }
    }
}

# Main menu loop
function Show-MainMenu {
    Show-Header
    while ($true) {
        Show-CategoryMenu
        switch (Read-Host "Choose an option") {
            'F' {
                $searchTerm = Read-Host "Enter search term"
                Show-SearchResults -searchTerm $searchTerm
            }
            'U' { Upgrade-InstalledApps }
            'X' { exit }
            default {
                if ($input -match '^\d+$') {
                    Show-AppsInCategory -categoryIndex [int]$input
                } else {
                    Write-Host "Invalid option." -ForegroundColor Red
                }
            }
        }
    }
}

Show-MainMenu
