function Show-FileExtensions {
    # Define the registry key and value
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $regValue = "HideFileExt"

    # Get the current value of the setting (1 = hide extensions, 0 = show extensions)
    $currentValue = Get-ItemProperty -Path $regPath -Name $regValue -ErrorAction SilentlyContinue

    if ($currentValue.HideFileExt -ne 0) {
        # Change the registry value to 0 (show extensions)
        Set-ItemProperty -Path $regPath -Name $regValue -Value 0

        # Notify the user that the change was made
        Write-Host "File extensions are now visible."

        # Refresh Explorer to apply the changes immediately
        Stop-Process -Name explorer -Force
        Write-Host "Explorer restarted to apply changes."
    } else {
        Write-Host "File extensions are already visible. No change made."
    }
}

# Call the function
Show-FileExtensions
