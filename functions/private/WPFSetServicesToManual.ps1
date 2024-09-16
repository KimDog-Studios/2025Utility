# Define the URL of the JSON configuration file
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/tweaks.json"

# Function to download and parse JSON file
function Get-ServicesFromJson {
    param (
        [string]$Url
    )

    try {
        # Download the JSON file
        $response = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop
        
        # Parse the JSON response
        $services = $response.services
        return $services
    } catch {
        Write-Host "Failed to download or parse JSON file: $_" -ForegroundColor Red
        return @()
    }
}

# Function to set services to manual
function Set-ServicesToManual {
    param (
        [string[]]$Services
    )

    foreach ($service in $Services) {
        try {
            Write-Host "Setting service '$service' to manual..." -ForegroundColor Cyan
            # Set the service startup type to Manual
            Set-Service -Name $service -StartupType Manual
            Write-Host "Service '$service' set to manual." -ForegroundColor Green
        } catch {
            Write-Host "Failed to set service '$service': $_" -ForegroundColor Red
        }
    }
}

# Main script logic
$services = Get-ServicesFromJson -Url $jsonUrl

if ($services.Count -eq 0) {
    Write-Host "No services to process." -ForegroundColor Yellow
} else {
    Set-ServicesToManual -Services $services
}
