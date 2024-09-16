# Function to check if winget is installed
function Check-Winget {
    $wingetCommand = "winget"
    
    try {
        $wingetPath = Get-Command $wingetCommand -ErrorAction SilentlyContinue
        if ($wingetPath) {
            Write-Host "winget is already installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "winget is not installed." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error checking winget installation: $_" -ForegroundColor Red
        return $false
    }
}

# Function to run winget commands
function Run-WingetCommand {
    param (
        [string]$command
    )

    if (-not (Check-Winget)) {
        Write-Host "winget is not available. Please install winget first." -ForegroundColor Red
        return
    }

    try {
        Write-Host "Running winget command: $command" -ForegroundColor Green
        cmd.exe /c $command
    } catch {
        Write-Host "Failed to execute winget command: $_" -ForegroundColor Red
    }
}

# Add more winget-related functions as needed.
