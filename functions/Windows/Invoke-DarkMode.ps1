function Invoke-WinUtilDarkMode {
    <#
    .SYNOPSIS
        Enables Dark Mode in Windows if not already enabled.
    #>
    try {
        Write-Host "Checking Dark Mode status..." -ForegroundColor Green
        
        $DarkModeValue = 0  # 0 for Dark Mode, 1 for Light Mode
        $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $currentDarkMode = (Get-ItemProperty -Path $Path -Name AppsUseLightTheme).AppsUseLightTheme

        if ($currentDarkMode -ne $DarkModeValue) {
            Write-Host "Enabling Dark Mode..." -ForegroundColor Green
            Set-ItemProperty -Path $Path -Name AppsUseLightTheme -Value $DarkModeValue
            Set-ItemProperty -Path $Path -Name SystemUsesLightTheme -Value $DarkModeValue
            Write-Host "Dark Mode has been enabled." -ForegroundColor Green
        } else {
            Write-Host "Dark Mode is already enabled." -ForegroundColor Yellow
        }
    } catch [System.Security.SecurityException] {
        Write-Warning "Unable to modify Dark Mode settings due to a Security Exception."
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning "Registry path or key not found: $Path"
    } catch {
        Write-Warning "An unexpected error occurred: ${_}"
    }
}

# Invoke the function
Invoke-WinUtilDarkMode