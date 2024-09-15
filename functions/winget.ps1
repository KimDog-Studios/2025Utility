# Custom Winget Management Menu in PowerShell

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
    $HeaderWidth = 30

    Write-Host (Align-Header "KimDog's Winget Menu" $HeaderWidth) -ForegroundColor Yellow
    Write-Host (Align-Header "Last Updated: 2024-09-15" $HeaderWidth) -ForegroundColor Cyan
    Write-Host (Align-Header "=" $HeaderWidth) -ForegroundColor Cyan
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
        $sortedApps = $apps | Sort-Object { $_.name.ToLower() }
        
        $totalApps = $sortedApps.Count
        $itemsPerPage = 5
        $page = 1
        $totalPages = [math]::Ceiling($totalApps / $itemsPerPage)
        
        while ($true) {
            Clear-Host
            Write-Host "=== $($selectedCategory.name) ===" -ForegroundColor Yellow

            $startIndex = ($page - 1) * $itemsPerPage
            $endIndex = [math]::Min($startIndex + $itemsPerPage, $totalApps)

            for ($i = $startIndex; $i -lt $endIndex; $i++) {
                $app = $sortedApps[$i]
                Write-Host "$($i + 1). $($app.name)" -ForegroundColor Green
                Write-Host "Winget ID: $($app.wingetId)" -ForegroundColor Cyan
                Write-Host ""
            }

            Write-Host "Page $page of $totalPages"
            Write-Host "[B] Back to Category Menu" -ForegroundColor Red
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

function Handle-AppSelection {
    param (
        [int]$appIndex,
        [int]$categoryIndex
    )

    $categories = Get-JsonData
    $selectedCategory = $categories[$categoryIndex - 1]
    $selectedApp = $selectedCategory.options[$appIndex - 1]

    if ($selectedApp) {
        Write-Host "You have selected $($selectedApp.name)."
        if (Read-Host "Do you want to install this application? (Y/N)" -match '^[Yy]$') {
            Install-Application -wingetId $selectedApp.wingetId
        }
    } else {
        Write-Host "Invalid application selection." -ForegroundColor Red
    }
}

while ($true) {
    Show-Header
    Show-CategoryMenu

    $selection = Read-Host "Select a category"

    if ($selection -match '^\d+$') {
        $categoryIndex = [int]$selection
        if ($categoryIndex -eq 0) {
            Write-Host "Exiting script." -ForegroundColor Green
            exit
        } elseif ($categoryIndex -gt 0) {
            Show-AppsInCategory -categoryIndex $categoryIndex
        } else {
            Write-Host "Invalid category selection, please try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid input, please enter a number." -ForegroundColor Red
    }
}
