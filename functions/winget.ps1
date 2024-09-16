$jsonFileUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/apps.json"

function Get-JsonData {
    try {
        $script:jsonData = $script:jsonData ?? (Invoke-RestMethod -Uri $jsonFileUrl -Method Get).categories
        return $script:jsonData
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
        $topBottomBorder = "+$("-" * ($boxWidth - 2))+"
        $emptyLine = "|$(" " * ($boxWidth - 2))|"

        Write-Host "$topBottomBorder`n$emptyLine`n| $Text |`n$emptyLine`n$topBottomBorder" -ForegroundColor Cyan
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

            Draw-Box -Text "Category: $($selectedCategory.name)"

            $startIndex = ($page - 1) * $itemsPerPage
            $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalApps)

            $apps[$startIndex..($endIndex-1)] | ForEach-Object {
                Write-Host "$($_.name)" -ForegroundColor Green
                Write-Host "Description: $($_.description)" -ForegroundColor White
                Write-Host "Winget ID: $($_.wingetId)" -ForegroundColor Cyan
                Write-Host "Chocolatey ID: $($_.chocoId)`n" -ForegroundColor Cyan
            }

            Draw-Box -Text "Page $page of $totalPages"

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
    $searchResults = $categories | ForEach-Object {
        $_.options | Where-Object { $_.name -match $searchTerm -or $_.description -match $searchTerm }
    }

    if ($searchResults.Count -eq 0) {
        Write-Host "No results found for '$searchTerm'." -ForegroundColor Red
        return
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

        $searchResults[$startIndex..($endIndex-1)] | ForEach-Object {
            Write-Host "$($_.name)" -ForegroundColor Cyan
            Write-Host "Description: $($_.description)" -ForegroundColor White
            Write-Host "Winget ID: $($_.wingetId)" -ForegroundColor Cyan
            Write-Host "Chocolatey ID: $($_.chocoId)`n" -ForegroundColor Cyan
        }

        Draw-Box -Text "Page $page of $totalPages"

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
        Write-Host "Chocolatey ID: $($app.chocoId)" -ForegroundColor Cyan
        Write-Host "`n[W] Install with Winget" -ForegroundColor Green
        Write-Host "[C] Install with Chocolatey" -ForegroundColor Green
        Write-Host "[B] Back to Results" -ForegroundColor Red

        $input = Read-Host "Choose an option"

        switch ($input) {
            'W' {
                Start-Process "winget" -ArgumentList "install $($app.wingetId)"
            }
            'C' {
                if ($app.chocoId) {
                    Start-Process "choco" -ArgumentList "install $($app.chocoId) -y"
                } else {
                    Write-Host "Chocolatey ID not found for $($app.name)." -ForegroundColor Red
                }
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
