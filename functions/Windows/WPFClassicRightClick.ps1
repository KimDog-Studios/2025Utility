function Set-ClassicRightClickMenu {
    # Set registry key to enable classic right-click menu
    $keyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $keyPath -Name "UseClassicContextMenu" -Value 1

    # Notify user
    Write-Host "Classic right-click menu has been enabled. Please restart Explorer or your computer for changes to take effect."
}

Set-ClassicRightClickMenu