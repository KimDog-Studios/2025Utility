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

    Draw-Box -Text "KimDog's Winget Menu | Last Updated: 2024-09-16"
    Write-Host "`n"
}

function Show-CategoryMenu {
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

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options

        # Track original indexes
        $indexedApps = $apps | ForEach-Object { [PSCustomObject]@{ OriginalIndex = [array]::IndexOf($apps, $_); App = $_ } }
        $sortedApps = $indexedApps | Sort-Object { $_.App.name.ToLower() }

        $totalApps = $sortedApps.Count
        $itemsPerPage = 5
        $page = 1
        $totalPages = [math]::Ceiling($totalApps / $itemsPerPage)
        
        while ($true) {
            Clear-Host

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
                $app = $sortedApps[$i]
                Write-Host "$($i + 1). $($app.App.name)" -ForegroundColor Green
                Write-Host "Description: $($app.App.description)" -ForegroundColor White
                Write-Host "Winget ID: $($app.App.wingetId)" -ForegroundColor Cyan
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
                            $originalIndex = $sortedApps[$selectedAppIndex].OriginalIndex
                            Handle-AppSelection -appIndex ($originalIndex + 1) -categoryIndex $categoryIndex
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

    $categories = Get-JsonData
    $searchResults = @()

    foreach ($category in $categories) {
        foreach ($app in $category.options) {
            if ($app.name -match $searchTerm -or $app.description -match $searchTerm) {
                $searchResults += [PSCustomObject]@{
                    Name = $app.name
                    Description = $app.description
                    WingetId = $app.wingetId
                }
            }
        }
    }

    if ($searchResults.Count -eq 0) {
        Write-Host "No results found for '$searchTerm'." -ForegroundColor Red
        return
    }

    Write-Host "`nSearch Results:" -ForegroundColor Yellow

    $counter = 1
    foreach ($result in $searchResults) {
        Write-Host "[$counter] $($result.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($result.Description)" -ForegroundColor White
        Write-Host "Winget ID: $($result.WingetId)" -ForegroundColor Cyan
        Write-Host ""
        $counter++
    }

    # Ask user to select a result for installation
    $selection = Read-Host "Enter the number of the app you want to install, or [B] to go back"

    if ($selection -eq 'B') {
        return
    }

    if ($selection -match '^\d+$') {
        $selectedIndex = [int]$selection - 1
        if ($selectedIndex -ge 0 -and $selectedIndex -lt $searchResults.Count) {
            $selectedApp = $searchResults[$selectedIndex]
            $confirmation = Read-Host "Do you want to install $($selectedApp.Name)? (Y/N)"
            if ($confirmation -eq 'Y') {
                Install-Application -wingetId $selectedApp.WingetId
            } else {
                Write-Host "Installation canceled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Invalid selection, returning to search results." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid input, returning to search results." -ForegroundColor Red
    }
}

function Install-Application {
    param (
        [string]$wingetId
    )

    if (-not $wingetId) {
        Write-Host "No Winget ID provided. Exiting..." -ForegroundColor Red
        return
    }

    Write-Host "Installing $wingetId..." -ForegroundColor Green
    Start-Process "winget" -ArgumentList "install $wingetId" -NoNewWindow -Wait
    Write-Host "Installation of $wingetId completed." -ForegroundColor Green
}

function Handle-AppSelection {
    param (
        [int]$appIndex,
        [int]$categoryIndex
    )

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options
        $app = $apps[$appIndex - 1]

        if ($app) {
            Write-Host "You selected: $($app.name)" -ForegroundColor Yellow
            $confirmation = Read-Host "Do you want to install $($app.name)? (Y/N)"
            if ($confirmation -eq 'Y') {
                Install-Application -wingetId $app.wingetId
            } else {
                Write-Host "Installation canceled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Invalid app selection." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid category selection." -ForegroundColor Red
    }
}

Show-Header
while ($true) {
    Show-CategoryMenu
    $option = Read-Host "Choose an option"

    switch ($option) {
        'F' {
            $searchTerm = Read-Host "Enter search term"
            Show-SearchResults -searchTerm $searchTerm
        }
        'U' {
            Write-Host "Upgrading all installed apps and drivers..." -ForegroundColor Green
            # Add upgrade logic here
        }
        'X' {
            Write-Host "Exiting script." -ForegroundColor Red
            break
        }
        default {
            if ($option -match '^\d+$') {
                $categoryIndex = [int]$option
                if ($categoryIndex -ge 1) {
                    Show-AppsInCategory -categoryIndex $categoryIndex
                } else {
                    Write-Host "Invalid category selection." -ForegroundColor Red
                }
            } else {
                Write-Host "Invalid option, please try again." -ForegroundColor Red
            }
        }
    }
}
