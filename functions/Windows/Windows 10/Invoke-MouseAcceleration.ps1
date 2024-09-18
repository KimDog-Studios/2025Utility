function Invoke-WinUtilMouseAcceleration {
    <#
    .SYNOPSIS
        Disables Mouse Acceleration and Enhance Pointer Precision if not already disabled.
    #>
    try {
        Write-Host "Checking Mouse Acceleration settings..." -ForegroundColor Green
        
        $MouseSpeed = 0
        $MouseThreshold1 = 0
        $MouseThreshold2 = 0
        $EnhancePointerPrecision = 0  # 0 to disable, 1 to enable

        $Path = "HKCU:\Control Panel\Mouse"
        $currentSettings = Get-ItemProperty -Path $Path

        if ($currentSettings.MouseSpeed -ne $MouseSpeed -or 
            $currentSettings.MouseThreshold1 -ne $MouseThreshold1 -or
            $currentSettings.MouseThreshold2 -ne $MouseThreshold2 -or
            $currentSettings.MouseEnhancePointerPrecision -ne $EnhancePointerPrecision) {
            
            Write-Host "Disabling Mouse Acceleration and Enhance Pointer Precision..." -ForegroundColor Green
            Set-ItemProperty -Path $Path -Name MouseSpeed -Value $MouseSpeed
            Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value $MouseThreshold1
            Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value $MouseThreshold2
            Set-ItemProperty -Path $Path -Name MouseEnhancePointerPrecision -Value $EnhancePointerPrecision

            Write-Host "Mouse Acceleration and Enhance Pointer Precision have been disabled." -ForegroundColor Green
            Write-Host "You might need to restart your computer or log out and log back in for changes to take effect."
        } else {
            Write-Host "Mouse Acceleration and Enhance Pointer Precision are already disabled." -ForegroundColor Yellow
        }
    } catch [System.Security.SecurityException] {
        Write-Warning "Unable to set mouse acceleration settings due to a Security Exception."
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning "Registry path or key not found: $Path"
    } catch {
        Write-Warning "An unexpected error occurred: ${_}"
    }
}

# Example usage
Invoke-WinUtilMouseAcceleration