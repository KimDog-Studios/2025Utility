function Invoke-WinUtilMouseAcceleration {
    <#
    .SYNOPSIS
        Disables Mouse Acceleration

    #>
    try {
        Write-Host "Disabling Mouse Acceleration..." -ForegroundColor Green
        
        $MouseSpeed = 0
        $MouseThreshold1 = 0
        $MouseThreshold2 = 0

        $Path = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $Path -Name MouseSpeed -Value $MouseSpeed
        Set-ItemProperty -Path $Path -Name MouseThreshold1 -Value $MouseThreshold1
        Set-ItemProperty -Path $Path -Name MouseThreshold2 -Value $MouseThreshold2
        
        Write-Host "Mouse Acceleration has been disabled." -ForegroundColor Green
    } catch [System.Security.SecurityException] {
        Write-Warning "Unable to set mouse acceleration settings due to a Security Exception."
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning "Registry path or key not found: $Path"
    } catch {
        Write-Warning "An unexpected error occurred: ${_}"
    }
}
