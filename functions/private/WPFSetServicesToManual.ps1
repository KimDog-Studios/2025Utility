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
    } catch [System.ServiceProcess.ServiceNotFoundException] {
        Write-Warning "Service '$Name' was not found"
    } catch {
        Write-Warning "Unable to set '$Name' due to unhandled exception"
        Write-Warning $_.Exception.Message
    }
}

# Get a list of all services
$allServices = Get-Service

# Set each service to manual
foreach ($service in $allServices) {
    Set-ServiceStartupType -Name $service.Name -StartupType "Manual"
}

Write-Host "All services have been set to Manual startup type." -ForegroundColor Green
