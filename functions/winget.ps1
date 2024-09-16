$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

function Get-JsonData {
    try {
        $jsonData = Invoke-RestMethod -Uri $jsonFileUrl -Method Get
        return $jsonData.categories
    } catch {
        Write-Host "Failed to fetch JSON data: $_" -ForegroundColor Red
        exit
    }
}

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
    cls # Alternative console clearing

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

    Draw-Box -Text "KimDog's Winget Menu | Last Updated: 2024-09-16"
    Write-Host "`n"
}

function Show-CategoryMenu {
    cls # Alternative console clearing

    $categories = Get-JsonData

    Write-Host "`nCategories:" -ForegroundColor Yellow
    $counter = 1
    foreach ($category in $categories) {
        Write-Host "[$counter] $($category.name)" -ForegroundColor Cyan
        $counter++
    }
    Write-Host "[F] Search All Apps" -ForegroundColor Green
    Write-Host "[U] Upgrade All Installed Apps & Drivers" -ForegroundColor Green
    Write-Host "[X] Exit Script" -ForegroundColor Red
    Write-Host "`n"
}

function Show-AppsInCategory {
    param (
        [int]$categoryIndex
    )

    cls # Alternative console clearing

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options
        $totalApps = $apps.Count
        $itemsPerPage = 5
        $page = 1
        $totalPages = [math]::Ceiling($totalApps / $itemsPerPage)
        
        while ($true) {
            cls # Alternative console clearing

            # Draw the category name with a box
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

            Draw-Box -Text "Category: $($selectedCategory.name)"

            $startIndex = ($page - 1) * $itemsPerPage
            $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalApps)

            for ($i = $startIndex; $i -lt $endIndex; $i++) {
                $app = $apps[$i]
                Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
                Write-Host "Description: $($app.description)" -ForegroundColor White
                Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
                Write-Host "Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
                Write-Host ""
            }

            # Page indicator with box
            $pageIndicator = "Page $page of $totalPages"
            $boxWidth = $pageIndicator.Length + 4
            $topBottomBorder = "+" + ("-" * ($boxWidth - 2)) + "+"
            $emptyLine = "|" + (" " * ($boxWidth - 2)) + "|"

            Write-Host "`n$topBottomBorder" -ForegroundColor Cyan
            Write-Host "$emptyLine" -ForegroundColor Cyan
            Write-Host "| $pageIndicator |" -ForegroundColor Cyan
            Write-Host "$emptyLine" -ForegroundColor Cyan
            Write-Host "$topBottomBorder" -ForegroundColor Cyan

            Write-Host "`n[B] Back to Category Menu" -ForegroundColor Red
            Write-Host "[N] Next Page" -ForegroundColor Cyan
            Write-Host "[P] Previous Page" -ForegroundColor Cyan

            $input = Read-Host "Choose an option"

            switch ($input) {
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
                        if ($selectedAppIndex -ge 0 -and $selectedAppIndex -lt $totalApps) {
                            Handle-AppSelection -appIndex ($selectedAppIndex + 1) -categoryIndex $categoryIndex
                        } else {
                            Write-Host "Invalid app selection, please try again." -ForegroundColor Red
                        }
                    } else {
                        Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
                    }
                }
            }
        }
    } else {
        Write-Host "Invalid category selection." -ForegroundColor Red
    }
}

function Show-SearchResults {
    param (
        [string]$searchTerm
    )

    cls # Alternative console clearing

    $categories = Get-JsonData
    $searchResults = @()

    foreach ($category in $categories) {
        foreach ($app in $category.options) {
            if ($app.name -match $searchTerm -or $app.description -match $searchTerm) {
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

    # Draw the search results header with a box
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

    Draw-Box -Text "Search Results | Search Term: $searchTerm"

    $totalResults = $searchResults.Count
    $itemsPerPage = 5
    $page = 1
    $totalPages = [math]::Ceiling($totalResults / $itemsPerPage)

    while ($true) {
        cls # Alternative console clearing

        # Display the current page of search results
        $startIndex = ($page - 1) * $itemsPerPage
        $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalResults)

        for ($i = $startIndex; $i -lt $endIndex; $i++) {
            $result = $searchResults[$i]
            Write-Host "$($i + 1). $($result.Name)" -ForegroundColor Green
            Write-Host "Description: $($result.Description)" -ForegroundColor White
            Write-Host "Winget ID: $($result.WingetId)" -ForegroundColor Cyan
            Write-Host "Chocolatey ID: $($result.ChocolateyId)" -ForegroundColor Cyan
            Write-Host ""
        }

        # Page indicator with box
        $pageIndicator = "Page $page of $totalPages"
        $boxWidth = $pageIndicator.Length + 4
        $topBottomBorder = "+" + ("-" * ($boxWidth - 2)) + "+"
        $emptyLine = "|" + (" " * ($boxWidth - 2)) + "|"

        Write-Host "`n$topBottomBorder" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "| $pageIndicator |" -ForegroundColor Cyan
        Write-Host "$emptyLine" -ForegroundColor Cyan
        Write-Host "$topBottomBorder" -ForegroundColor Cyan

        Write-Host "`n[B] Back to Main Menu" -ForegroundColor Red
        Write-Host "[N] Next Page" -ForegroundColor Cyan
        Write-Host "[P] Previous Page" -ForegroundColor Cyan

        $input = Read-Host "Choose an option"

        switch ($input) {
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
                    if ($selectedResultIndex -ge 0 -and $selectedResultIndex -lt $totalResults) {
                        Handle-AppSelection -appIndex ($selectedResultIndex + 1)
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

function Upgrade-InstalledApps {
    cls # Clear the console screen

    Write-Host "Upgrading all installed apps using Winget..." -ForegroundColor Cyan

    # Upgrade all apps using Winget
    & winget upgrade --all

    Write-Host "Upgrade process completed." -ForegroundColor Green
}

function Handle-AppSelection {
    param (
        [int]$appIndex,
        [int]$categoryIndex = 0
    )

    $categories = Get-JsonData
    $app = $categories[$categoryIndex - 1].options[$appIndex - 1]

    if ($app) {
        Write-Host "`nApp: $($app.name)" -ForegroundColor Green
        Write-Host "Description: $($app.description)" -ForegroundColor White

        if ($app.wingetId) {
            Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host "Running Winget Install..."
            & winget install $app.wingetId
        }

        if ($app.chocoId) {
            Write-Host "Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
            Write-Host "Running Chocolatey Install..."
            & choco install $app.chocoId
        }
    } else {
        Write-Host "Invalid app selection." -ForegroundColor Red
    }
}

function Main-Menu {
    Show-Header

    while ($true) {
        Show-CategoryMenu
        $input = Read-Host "Choose an option"

        switch ($input) {
            'U' {
                Upgrade-InstalledApps
            }
            'F' {
                $searchTerm = Read-Host "Enter search term"
                Show-SearchResults -searchTerm $searchTerm
            }
            [int] {
                if ($input -ge 1 -and $input -le 10) {
                    Show-AppsInCategory -categoryIndex $input
                } else {
                    Write-Host "Invalid category selection." -ForegroundColor Red
                }
            }
            'X' {
                Write-Host "Exiting script." -ForegroundColor Red
                break
            }
            default {
                Write-Host "Invalid option. Please try again." -ForegroundColor Red
            }
        }
    }
}

#Main-Menu
