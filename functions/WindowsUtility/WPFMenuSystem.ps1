# Function to display the menu options
function Show-MainMenu {
    param (
        [array]$menuOptions,
        [int]$currentIndex
    )

    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "`[*] $($menuOptions[$i].Name)" -ForegroundColor Yellow  # Highlight the current item in yellow
        } else {
            Write-Host "`[ ] $($menuOptions[$i].Name)"  # Regular menu item
        }
    }
    "`n" | Out-String  # Explicitly add a line break after each option
}

# Function to handle the menu system
function Show-MenuSystem {
    param (
        [array]$menuOptions,
        [int]$currentIndex
    )

    Show-MainHeader
    Show-MainMenu -menuOptions $menuOptions -currentIndex $currentIndex

    # Read key input
    $key = Read-Key

    # Handle arrow keys and selection
    switch ($key.Key) {
        'UpArrow' {
            $currentIndex = ($currentIndex - 1 + $menuOptions.Count) % $menuOptions.Count  # Move up
        }
        'DownArrow' {
            $currentIndex = ($currentIndex + 1) % $menuOptions.Count  # Move down
        }
        'Enter' {
            Clear-Host  # Clear the screen before running the action
            & $menuOptions[$currentIndex].Action  # Execute the selected option
        }
    }
    Start-Sleep -Milliseconds 100

    return $currentIndex  # Return the updated index
}
