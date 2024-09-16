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
            Write-Host "[$($i + 1)] $($result.Name)" -ForegroundColor Cyan
            Write-Host "Description: $($result.Description)" -ForegroundColor White
            Write-Host "Winget ID: $($result.WingetId)" -ForegroundColor Cyan
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
                        $result = $searchResults[$selectedResultIndex]
                        Handle-AppSelection -appIndex ($selectedResultIndex + 1) -categoryIndex $null
                    } else {
                        Write-Host "Invalid selection, please try again." -ForegroundColor Red
                    }
                } else {
                    Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
                }
            }
        }
    }
}

function Handle-AppSelection {
    param (
        [int]$appIndex,
        [int]$categoryIndex
    )

    $categories = Get-JsonData
    if ($categoryIndex -ne $null) {
        $category = $categories[$categoryIndex - 1]
        $app = $category.options[$appIndex - 1]
    } else {
        $app = $categories | ForEach-Object { $_.options[$appIndex - 1] } | Where-Object { $_ }
    }

    if ($app) {
        Write-Host "`nSelected App:" -ForegroundColor Green
        Write-Host "Name: $($app.name)" -ForegroundColor Cyan
        Write-Host "Description: $($app.description)" -ForegroundColor White
        Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
        Write-Host "`n[O] Open Winget for $($app.name)" -ForegroundColor Green
        Write-Host "[B] Back to Results" -ForegroundColor Red

        $input = Read-Host "Choose an option"

        switch ($input) {
            'O' {
                Start-Process "winget" -ArgumentList "install $($app.wingetId)"
            }
            'B' {
                return
            }
            default {
                Write-Host "Invalid option, please try again." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Invalid app selection." -ForegroundColor Red
    }
}

# Main menu loop
Show-Header

while ($true) {
    Show-CategoryMenu

    $choice = Read-Host "Select an option"

    switch ($choice) {
        'X' {
            exit
        }
        'F' {
            $searchTerm = Read-Host "Enter search term"
            Show-SearchResults -searchTerm $searchTerm
        }
        'U' {
            Write-Host "Upgrade functionality not implemented yet." -ForegroundColor Yellow
        }
        default {
            if ($choice -match '^\d+$') {
                $categoryIndex = [int]$choice
                if ($categoryIndex -ge 1 -and $categoryIndex -le (Get-JsonData).Count) {
                    Show-AppsInCategory -categoryIndex $categoryIndex
                } else {
                    Write-Host "Invalid category selection, please try again." -ForegroundColor Red
                }
            } else {
                Write-Host "Invalid option, please try again." -ForegroundColor Red
            }
        }
    }
}
