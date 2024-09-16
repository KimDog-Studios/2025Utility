# Define the URL of the JSON configuration file
$jsonUrl = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/refs/heads/main/config/tweaks.json"

# Function to download the JSON file to a temporary directory
function Download-JsonToTemp {
    param (
        [string]$Url,
        [string]$TempFilePath
    )

    try {
        Write-Host "Downloading JSON file from $Url..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $Url -OutFile $TempFilePath -ErrorAction Stop
        Write-Host "Downloaded JSON file successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download JSON file: $_" -ForegroundColor Red
    }
}

# Function to parse JSON file
function Get-ServicesFromJson {
    param (
        [string]$JsonFilePath
    )

    try {
        Write-Host "Parsing JSON file from $JsonFilePath..." -ForegroundColor Cyan
        # Read and parse the JSON file
        $jsonContent = Get-Content -Path $JsonFilePath -Raw | ConvertFrom-Json
        
        # Extract services
        $services = $jsonContent.services
        return $services
    } catch {
        Write-Host "Failed to parse JSON file: $_" -ForegroundColor Red
        return @()
    }
}

# Function to set a service to a specific startup type
function Set-WinUtilService {
    <#
    .SYNOPSIS
        Changes the startup type of the given service

    .PARAMETER Name
        The name of the service to modify

    .PARAMETER StartupType
        The startup type to set the service to

    .EXAMPLE
        Set-WinUtilService -Name "HomeGroupListener" -StartupType "Manual"
    #>
    param (
        [string]$Name,
        [string]$StartupType
    )
    try {
        Write-Host "Setting Service $Name to $StartupType" -ForegroundColor Cyan

        # Check if the service exists
        $service = Get-Service -Name $Name -ErrorAction Stop

        # Service exists, proceed with changing properties
        $service | Set-Service -StartupType $StartupType -ErrorAction Stop
        Write-Host "Service $Name set to $StartupType successfully." -ForegroundColor Green
    } catch [System.ServiceProcess.ServiceNotFoundException] {
        Write-Warning "Service $Name was not found"
    } catch {
        Write-Warning "Unable to set $Name due to unhandled exception"
        Write-Warning $_.Exception.Message
    }
}

# Function to set all services to manual
function Set-ServicesToManual {
    param (
        [string[]]$Services
    )

    foreach ($service in $Services) {
        Set-WinUtilService -Name $service -StartupType "Manual"
    }
}

# Main script logic
$tempFilePath = [System.IO.Path]::Combine($env:TEMP, "tweaks.json")

# Download the JSON configuration file to a temporary directory
Download-JsonToTemp -Url $jsonUrl -TempFilePath $tempFilePath

# Parse the JSON file
$services = Get-ServicesFromJson -JsonFilePath $tempFilePath

if ($services.Count -eq 0) {
    Write-Host "No services to process." -ForegroundColor Yellow
} else {
    Set-ServicesToManual -Services $services
}

# Clean up the temporary file
Remove-Item -Path $tempFilePath -Force
Write-Host "Temporary JSON file removed." -ForegroundColor Green
