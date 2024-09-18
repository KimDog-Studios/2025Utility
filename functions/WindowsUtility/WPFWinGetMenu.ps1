$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

# Fetch JSON data
function Get-JsonData {
    try {
        $response = Invoke-WebRequest -Uri $jsonFileUrl -UseBasicParsing
        $statusCode = $response.StatusCode
        
        if ($statusCode -ne 200) {
            Write-Host "HTTP Error: Status code $statusCode" -ForegroundColor Red
            return $null
        }
        
        $content = $response.Content
        $data = $content | ConvertFrom-Json
        
        if ($null -eq $data) {
            Write-Host "Failed to parse JSON content." -ForegroundColor Red
            return $null
        }
        
        if ($null -eq $data.categories) {
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
    for ($i = 0; $i -lt $categories.Count; $i++) {
        $category = $categories[$i]
        Write-Host ("[{0}] {1} [{2} Apps]" -f ($i + 1), $category.name, $category.options.Count) -ForegroundColor Cyan
    }
    Write-Host "[F] Search All Apps" -ForegroundColor Green
    Write-Host "[U] Upgrade All Installed Apps & Drivers" -ForegroundColor Green
    Write-Host "[X] Exit Script" -ForegroundColor Red
    Write-Host "`n"
}

# Display apps in a category with pagination
function Show-AppsInCategory {
    param ([int]$categoryIndex)
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
        Draw-Box -Text "Page $page of $totalPages"
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
    $results = @()
    foreach ($category in $categories) {
        $results += $category.options | Where-Object { $_.name -imatch $searchTerm -or $_.description -imatch $searchTerm }
    }

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
        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($page * $itemsPerPage, $results.Count) - 1
        for ($i = $startIndex; $i -le $endIndex; $i++) {
            $app = $results[$i]
            Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
            Write-Host "   Description: $($app.description)" -ForegroundColor White
            Write-Host "   Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host "   Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
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
        default { Write-Host "Invalid option." -ForegroundColor Red }
    }
}

# Main menu loop
function Show-MainMenu {
    while ($true) {
        Show-Header
        Show-CategoryMenu
        $input = Read-Host "Choose an option"
        switch ($input.ToUpper()) {
            'F' {
                $searchTerm = Read-Host "Enter search term"
                Show-SearchResults -searchTerm $searchTerm
            }
            'U' { Upgrade-InstalledApps }
            'X' { exit }
            default {
                if ($input -match '^\d+$') {
                    $categoryIndex = [int]$input
                    $categories = Get-JsonData
                    if ($categoryIndex -ge 1 -and $categoryIndex -le $categories.Count) {
                        Show-AppsInCategory -categoryIndex $categoryIndex
                    } else {
                        Write-Host "Invalid category number." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                } else {
                    Write-Host "Invalid option." -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
        }
    }
}

Show-MainMenu