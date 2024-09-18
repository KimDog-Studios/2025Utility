# Function to handle key press
function Read-Key {
    $key = [System.Console]::ReadKey($true)  # Call ReadKey directly on the Console class
    return $key
}

# Array of random items
$items = @("Item 1", "Item 2", "Item 3", "Item 4", "Item 5")
$currentIndex = 0  # Track the current index

# Main loop
while ($true) {
    Clear-Host
    Write-Host "Use arrow keys to navigate. Press 'Enter' to select an item. Press 'Esc' to exit."
    
    # Display items with the current selection
    for ($i = 0; $i -lt $items.Length; $i++) {
        if ($i -eq $currentIndex) {
            Write-Host "[ * ] $($items[$i])"  # Highlight the current item
        } else {
            Write-Host "[   ] $($items[$i])"
        }
    }

    # Read key input
    $key = Read-Key

    # Handle arrow keys and selection
    switch ($key.Key) {
        'UpArrow' {
            $currentIndex = ($currentIndex - 1 + $items.Length) % $items.Length  # Move up
        }
        'DownArrow' {
            $currentIndex = ($currentIndex + 1) % $items.Length  # Move down
        }
        'Enter' {
            Write-Host "You selected: $($items[$currentIndex])"  # Display selected item
            Start-Sleep -Seconds 2  # Pause for 2 seconds to see the selection
        }
        'Escape' {
            break
        }
    }
    Start-Sleep -Milliseconds 100
}
