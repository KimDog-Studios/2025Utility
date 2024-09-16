# Define the URL of the JSON configuration file
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/tweaks.json"

# Function to download and parse JSON file
function Get-ServicesFromJson {
    param (
        [string]$Url
    )

    try {
        # Download the JSON file
        Write-Host "Downloading JSON configuration from $Url..." -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop
        
        # Debug: Output the raw JSON response
        Write-Host "Raw JSON Response:" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 5)

        # Parse the JSON response
        if ($response.WPFTweaksServices -eq $null -or $response.WPFTweaksServices.service -eq $null) {
            Write-Host "No 'WPFTweaksServices' or 'service' property found in JSON file." -ForegroundColor Red
            return @()
        }
        
        return $response.WPFTweaksServices.service
    } catch {
        Write-Host "Failed to download or parse JSON file: $_" -ForegroundColor Red
        return @()
    }
}

# Function to set a service to a specific startup type
function Set-ServiceStartupType {
    param (
        [string]$Name,
        [string]$StartupType
    )
    
    try {
        Write-Host "Setting Service '$Name' to '$StartupType'..." -ForegroundColor Cyan

        # Check if the service exists
        $service = Get-Service -Name $Name -ErrorAction Stop

        # Service exists, proceed with changing properties
        $service | Set-Service -StartupType $StartupType -ErrorAction Stop
        Write-Host "Service '$Name' set to '$StartupType' successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Unable to set '$Name' to '$StartupType'. Exception: $($_.Exception.Message)"
    }
}

# Main script logic
$servicesToProcess = Get-ServicesFromJson -Url $jsonUrl

if ($servicesToProcess.Count -eq 0) {
    Write-Host "No services to process." -ForegroundColor Yellow
} else {
    foreach ($service in $servicesToProcess) {
        $serviceName = $service.Name
        $serviceStartupType = "Manual"  # Set to "Manual" regardless of the original type

        # Set the service startup type
        Set-ServiceStartupType -Name $serviceName -StartupType $serviceStartupType
    }
}

Write-Host "Specified services have been processed. Check logs for any issues." -ForegroundColor Green
