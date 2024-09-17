function Invoke-WinUtilDarkMode {
    <#
    .SYNOPSIS
        Enables Dark Mode in Windows.

    #>
    try {
        Write-Host "Enabling Dark Mode..." -ForegroundColor Green
        
        $DarkMoveValue = 0  # 0 for Dark Mode, 1 for Light Mode

        $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $Path -Name AppsUseLightTheme -Value $DarkMoveValue
        Set-ItemProperty -Path $Path -Name SystemUsesLightTheme -Value $DarkMoveValue
        
        Write-Host "Dark Mode has been enabled." -ForegroundColor Green
        
        # Wait for user to press Enter
        Read-Host -Prompt "Press Enter to continue..."
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