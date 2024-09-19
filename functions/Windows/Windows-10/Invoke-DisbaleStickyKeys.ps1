function Set-StickyKeysOff {
    # Check if Sticky Keys is already disabled
    $stickyKeysPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
    $currentValue = Get-ItemProperty -Path $stickyKeysPath -Name "Flags"

    if ($currentValue.Flags -ne 0) {
        # Disable Sticky Keys
        Set-ItemProperty -Path $stickyKeysPath -Name "Flags" -Value 0
        Write-Host "Sticky Keys has been disabled."
    } else {
        Write-Host "Sticky Keys is already disabled."
    }
}

# Call the function to ensure Sticky Keys is off by default
Set-StickyKeysOff