# Optimize Create-Shortcut function
function Create-Shortcut {
    param(
        [string]$ShortcutName,
        [string]$ShortcutPath,
        [string]$TargetPath,
        [string]$Arguments = "",
        [bool]$RunAsAdmin = $true
    )

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"  # Change to PowerShell
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$TargetPath`""  # Pass the script path as an argument

    $iconUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/icon.ico"
    $iconPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "logo.ico")
    Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
    $Shortcut.IconLocation = $iconPath

    $Shortcut.Save()

    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }

    Write-Host "Shortcut '$ShortcutName' created at $ShortcutPath (Run as admin: $RunAsAdmin)"
}

# Combine Create-ShortcutInStartMenu and Create-DesktopShortcut
function Create-WinUtilShortcuts {
    $shell = if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell.exe" }
    $shellArgs = "-ExecutionPolicy Bypass -Command `"Start-Process $shell -verb runas -ArgumentList `'-Command `"irm https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/functions/Utility/WPFStarter.ps1 | iex`"`'"

    $locations = @{
        "Start Menu" = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), 'Programs', 'KimDog Studios')
        "Desktop" = [System.Environment]::GetFolderPath('Desktop')
    }

    foreach ($location in $locations.GetEnumerator()) {
        if ($location.Key -eq "Start Menu" -and -not (Test-Path -Path $location.Value)) {
            New-Item -Path $location.Value -ItemType Directory | Out-Null
        }
        
        # Always create or update the shortcut
        $adminShortcutPath = [System.IO.Path]::Combine($location.Value, "KimDog's Utility.lnk")
        Create-Shortcut -ShortcutName "KimDog's Utility" -ShortcutPath $adminShortcutPath -TargetPath $shell -Arguments $shellArgs -RunAsAdmin $true
        Write-Host "Shortcut '$adminShortcutPath' created or updated." -ForegroundColor Green
    }
}

# Main script starts here
Create-WinUtilShortcuts