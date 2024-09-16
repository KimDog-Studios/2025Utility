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
    Write-Host "[F] Search for an App" -ForegroundColor Cyan
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
        [int]$categoryIndex,
        [string]$searchTerm
    )

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]

    if ($selectedCategory) {
        $apps = $selectedCategory.options
        $matchingApps = $apps | Where-Object { $_.name -match $searchTerm }

        Clear-Host

        if ($matchingApps.Count -eq 0) {
            Write-Host "No apps found matching '$searchTerm'." -ForegroundColor Red
            return
        }

        Write-Host "`nSearch Results:" -ForegroundColor Yellow
        $counter = 1
        foreach ($app in $matchingApps) {
            Write-Host "[$counter] $($app.name)" -ForegroundColor Green
            Write-Host "Description: $($app.description)" -ForegroundColor White
            Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
            Write-Host ""
            $counter++
        }
        Write-Host "[B] Back to Category Menu" -ForegroundColor Red
    } else {
        Write-Host "Invalid category selection." -ForegroundColor Red
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

    Write-Host "Starting installation of $wingetId..." -ForegroundColor Yellow

    try {
        $cmdCommand = "winget install --id $wingetId --silent"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdCommand" -NoNewWindow -Wait
        Write-Host "Installation process for $wingetId has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start the installation process: $_" -ForegroundColor Red
    }
}

function Uninstall-Application {
    param (
        [string]$wingetId
    )

    if (-not $wingetId) {
        Write-Host "No Winget ID provided. Exiting..." -ForegroundColor Red
        return
    }

    Write-Host "Starting uninstallation of $wingetId..." -ForegroundColor Yellow

    try {
        $cmdCommand = "winget uninstall --id $wingetId --silent"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdCommand" -NoNewWindow -Wait
        Write-Host "Uninstallation process for $wingetId has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start the uninstallation process: $_" -ForegroundColor Red
    }
}

function Handle-AppSelection {
    param (
        [int]$appIndex,
        [int]$categoryIndex
    )

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]
    $app = $selectedCategory.options[$appIndex - 1]

    if ($app) {
        Write-Host "`nYou selected: $($app.name)" -ForegroundColor Green
        Write-Host "Description: $($app.description)" -ForegroundColor White
        Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan

        Write-Host "`n[1] Install" -ForegroundColor Cyan
        Write-Host "[2] Uninstall" -ForegroundColor Red
        Write-Host "[B] Back to App List" -ForegroundColor Red

        $choice = Read-Host "Select an option"

        switch ($choice) {
            '1' {
                Install-Application -wingetId $app.wingetId
            }
            '2' {
                Uninstall-Application -wingetId $app.wingetId
            }
            'B' {
                return
            }
            default {
                Write-Host "Invalid option selected." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Invalid app selection." -ForegroundColor Red
    }
}

function Show-Menu {
    $searchMode = $false
    $currentCategoryIndex = 0

    Show-Header

    while ($true) {
        if (-not $searchMode) {
            Show-CategoryMenu
        }

        if ($searchMode) {
            $searchTerm = Read-Host "Enter search term (or type [B] to go back)"
            if ($searchTerm -eq 'B') {
                $searchMode = $false
            } else {
                Show-SearchResults -categoryIndex $currentCategoryIndex -searchTerm $searchTerm
            }
        } else {
            $input = Read-Host "Select an option"

            switch ($input) {
                'F' {
                    $searchMode = $true
                    $currentCategoryIndex = Read-Host "Enter category number to search within"
                }
                'U' {
                    Write-Host "Upgrading all installed apps & drivers..." -ForegroundColor Green
                    # You can add your upgrade logic here
                }
                'X' {
                    Write-Host "Exiting script..." -ForegroundColor Red
                    exit
                }
                default {
                    if ($input -match '^\d+$') {
                        $categoryIndex = [int]$input
                        $currentCategoryIndex = $categoryIndex
                        Show-AppsInCategory -categoryIndex $categoryIndex
                    } else {
                        Write-Host "Invalid input. Please try again." -ForegroundColor Red
                    }
                }
            }
        }
    }
}

Show-Menu
