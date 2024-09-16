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
            Write-Host "=== $($selectedCategory.name) ===" -ForegroundColor Yellow

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

function Upgrade-AllApps {
    Write-Host "Starting upgrade for all installed apps..." -ForegroundColor Yellow

    try {
        $cmdCommand = "winget upgrade --all --silent --include-unknown"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdCommand" -NoNewWindow -Wait
        Write-Host "Upgrade process for all installed apps has started." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start the upgrade process: $_" -ForegroundColor Red
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
        $action = Read-Host "Do you want to [I]nstall, [U]ninstall, or [C]ancel this action? (I/U/C)"

        switch ($action.ToUpper()) {
            'I' {
                Install-Application -wingetId $selectedApp.wingetId
            }
            'U' {
                Uninstall-Application -wingetId $selectedApp.wingetId
            }
            'C' {
                Write-Host "Action cancelled." -ForegroundColor Yellow
            }
            default {
                Write-Host "Invalid option, please enter 'I' to install, 'U' to uninstall, or 'C' to cancel." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Invalid application selection." -ForegroundColor Red
    }
}

while ($true) {
    Show-Header
    Show-CategoryMenu

    $selection = Read-Host "Select a category or option"

    if ($selection -match '^\d+$') {
        $categoryIndex = [int]$selection
        if ($categoryIndex -gt 0) {
            Show-AppsInCategory -categoryIndex $categoryIndex
        } elseif ($categoryIndex -eq 0) {
            Write-Host "Exiting script." -ForegroundColor Green
            exit
        } else {
            Write-Host "Invalid category selection, please try again." -ForegroundColor Red
        }
    } elseif ($selection.ToUpper() -eq 'U') {
        Upgrade-AllApps
    } elseif ($selection.ToUpper() -eq 'X') {
        Write-Host "Exiting script." -ForegroundColor Green
        exit
    } else {
        Write-Host "Invalid input, please enter a number or an option." -ForegroundColor Red
    }
}
