# PowerShell Script to Check, Activate, and Add Ultimate Power Plan

# GUID of the Ultimate Power Plan
$ultimatePowerPlanGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"

# Function to check if the Ultimate Power Plan exists
function Check-UltimatePowerPlanExists {
    try {
        $existingPlans = powercfg /list
        if ($existingPlans -match $ultimatePowerPlanGUID) {
            Write-Host "Ultimate Power Plan is already available." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Ultimate Power Plan is not available on this PC." -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "An error occurred while checking for the Ultimate Power Plan: $_" -ForegroundColor Red
        return $false
    }
}

# Function to activate and add the Ultimate Power Plan
function Add-UltimatePowerPlan {
    # Check if the Ultimate Power Plan already exists
    if (-not (Check-UltimatePowerPlanExists)) {
        try {
            # Duplicate the Ultimate Power Plan
            Write-Host "Duplicating the Ultimate Power Plan..." -ForegroundColor Cyan
            $result = Start-Process -FilePath "powercfg" -ArgumentList "-duplicatescheme $ultimatePowerPlanGUID" -NoNewWindow -Wait -PassThru
            
            if ($result.ExitCode -eq 0) {
                Write-Host "Ultimate Power Plan has been successfully added." -ForegroundColor Green
            } else {
                Write-Host "Failed to add the Ultimate Power Plan. Exit Code: $($result.ExitCode)" -ForegroundColor Red
            }
        } catch {
            Write-Host "An error occurred while adding the Ultimate Power Plan: $_" -ForegroundColor Red
        }
    }
}

# Call the function to add the Ultimate Power Plan if not already present
Add-UltimatePowerPlan
