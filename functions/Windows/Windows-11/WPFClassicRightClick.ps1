function Set-ClassicRightClickMenu {
    # Check if the classic right-click menu is already enabled
    $keyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $currentValue = Get-ItemProperty -Path $keyPath -Name "UseClassicContextMenu" -ErrorAction SilentlyContinue

    if ($currentValue.UseClassicContextMenu -ne 1) {
        # Set registry key to enable classic right-click menu
        Set-ItemProperty -Path $keyPath -Name "UseClassicContextMenu" -Value 1

        # Notify user
        Write-Host "Classic right-click menu has been enabled."
    } else {
        Write-Host "Classic right-click menu is already enabled."
    }
}

Set-ClassicRightClickMenu