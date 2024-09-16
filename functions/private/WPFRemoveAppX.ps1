# Function to remove certain features from a Windows image
function Remove-Features {
    <#
        .SYNOPSIS
            Removes certain features from a Windows image

        .PARAMETER Name
            No Params

        .EXAMPLE
            Remove-Features
    #>
    try {
        $featlist = Get-WindowsOptionalFeature -Online

        $featlist = $featlist | Where-Object {
            $_.FeatureName -NotLike "*Defender*" -AND
            $_.FeatureName -NotLike "*Printing*" -AND
            $_.FeatureName -NotLike "*TelnetClient*" -AND
            $_.FeatureName -NotLike "*PowerShell*" -AND
            $_.FeatureName -NotLike "*NetFx*" -AND
            $_.FeatureName -NotLike "*Media*" -AND
            $_.FeatureName -NotLike "*NFS*" -AND
            $_.State -ne "Disabled"
        }

        $counter = 1
        foreach ($feature in $featlist) {
            $status = "Removing feature $($feature.FeatureName)"
            Write-Progress -Activity "Removing features" -Status $status -PercentComplete (($counter++) / $featlist.Count * 100)
            Write-Debug "Removing feature $($feature.FeatureName)"
            Disable-WindowsOptionalFeature -FeatureName $($feature.FeatureName) -Remove -ErrorAction SilentlyContinue -NoRestart
        }
        Write-Progress -Activity "Removing features" -Status "Ready" -Completed
        Write-Host "You can re-enable the disabled features at any time, using either Windows Update or the SxS folder in <installation media>\Sources."
    } catch {
        Write-Host "Unable to get information about the features. Feature removal will continue, but features will not be processed" -ForegroundColor Yellow
        Write-Host "Error information: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to remove certain packages from a Windows image
function Remove-Packages {
    try {
        $pkglist = (Get-WindowsPackage -Online).PackageName

        $pkglist = $pkglist | Where-Object {
            $_ -NotLike "*ApplicationModel*" -AND
            $_ -NotLike "*indows-Client-LanguagePack*" -AND
            $_ -NotLike "*LanguageFeatures-Basic*" -AND
            $_ -NotLike "*Package_for_ServicingStack*" -AND
            $_ -NotLike "*.NET*" -AND
            $_ -NotLike "*Store*" -AND
            $_ -NotLike "*VCLibs*" -AND
            $_ -NotLike "*AAD.BrokerPlugin*" -AND
            $_ -NotLike "*LockApp*" -AND
            $_ -NotLike "*Notepad*" -AND
            $_ -NotLike "*immersivecontrolpanel*" -AND
            $_ -NotLike "*ContentDeliveryManager*" -AND
            $_ -NotLike "*PinningConfirmationDialog*" -AND
            $_ -NotLike "*SecHealthUI*" -AND
            $_ -NotLike "*SecureAssessmentBrowser*" -AND
            $_ -NotLike "*PrintDialog*" -AND
            $_ -NotLike "*AssignedAccessLockApp*" -AND
            $_ -NotLike "*OOBENetworkConnectionFlow*" -AND
            $_ -NotLike "*Apprep.ChxApp*" -AND
            $_ -NotLike "*CBS*" -AND
            $_ -NotLike "*OOBENetworkCaptivePortal*" -AND
            $_ -NotLike "*PeopleExperienceHost*" -AND
            $_ -NotLike "*ParentalControls*" -AND
            $_ -NotLike "*Win32WebViewHost*" -AND
            $_ -NotLike "*InputApp*" -AND
            $_ -NotLike "*AccountsControl*" -AND
            $_ -NotLike "*AsyncTextService*" -AND
            $_ -NotLike "*CapturePicker*" -AND
            $_ -NotLike "*CredDialogHost*" -AND
            $_ -NotLike "*BioEnrollment*" -AND
            $_ -NotLike "*ShellExperienceHost*" -AND
            $_ -NotLike "*DesktopAppInstaller*" -AND
            $_ -NotLike "*WebMediaExtensions*" -AND
            $_ -NotLike "*WMIC*" -AND
            $_ -NotLike "*UI.XaML*" -AND
            $_ -NotLike "*Ethernet*" -AND
            $_ -NotLike "*Wifi*"
        }

        $counter = 1
        $failedCount = 0

        foreach ($pkg in $pkglist) {
            try {
                $status = "Removing $pkg"
                Write-Progress -Activity "Removing Apps" -Status $status -PercentComplete (($counter++) / $pkglist.Count * 100)
                Remove-WindowsPackage -PackageName $pkg -NoRestart -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Could not remove OS package $($pkg)"
                $failedCount += 1
                continue
            }
        }
        Write-Progress -Activity "Removing Apps" -Status "Ready" -Completed
        if ($failedCount -gt 0) {
            Write-Host "Some packages could not be removed. Do not worry: your image will still work fine. This can happen if the package is permanent or has been superseded by a newer one."
        }
    } catch {
        Write-Host "Unable to get information about the packages. Package removal will continue, but packages will not be processed" -ForegroundColor Yellow
        Write-Host "Error information: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to remove provisioned AppX packages
function Remove-ProvisionedPackages {
    <#
        .SYNOPSIS
            Removes AppX packages from a Windows image during processing

        .PARAMETER Name
            No Params

        .EXAMPLE
            Remove-ProvisionedPackages
    #>
    try {
        $appxProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {
            $_.PackageName -NotLike "*AppInstaller*" -AND
            $_.PackageName -NotLike "*Store*" -and
            $_.PackageName -NotLike "*dism*" -and
            $_.PackageName -NotLike "*Foundation*" -and
            $_.PackageName -NotLike "*FodMetadata*" -and
            $_.PackageName -NotLike "*LanguageFeatures*" -and
            $_.PackageName -NotLike "*Notepad*" -and
            $_.PackageName -NotLike "*Printing*" -and
            $_.PackageName -NotLike "*Foundation*" -and
            $_.PackageName -NotLike "*YourPhone*" -and
            $_.PackageName -NotLike "*Xbox*" -and
            $_.PackageName -NotLike "*WindowsTerminal*" -and
            $_.PackageName -NotLike "*Calculator*" -and
            $_.PackageName -NotLike "*Photos*" -and
            $_.PackageName -NotLike "*VCLibs*" -and
            $_.PackageName -NotLike "*Paint*" -and
            $_.PackageName -NotLike "*Gaming*" -and
            $_.PackageName -NotLike "*Extension*" -and
            $_.PackageName -NotLike "*SecHealthUI*" -and
            $_.PackageName -NotLike "*ScreenSketch*"
        }

        $counter = 1
        foreach ($appx in $appxProvisionedPackages) {
            $status = "Removing Provisioned $($appx.PackageName)"
            Write-Progress -Activity "Removing Provisioned Apps" -Status $status -PercentComplete (($counter++) / $appxProvisionedPackages.Count * 100)
            try {
                Remove-AppxProvisionedPackage -PackageName $appx.PackageName -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Application $($appx.PackageName) could not be removed"
                continue
            }
        }
        Write-Progress -Activity "Removing Provisioned Apps" -Status "Ready" -Completed
    } catch {
        Write-Host "Unable to get information about the AppX packages. Provisioned package removal will continue, but AppX packages will not be processed" -ForegroundColor Yellow
        Write-Host "Error information: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Main script logic
Write-Host "Starting the cleanup process..." -ForegroundColor Green

Remove-Features
Remove-Packages
Remove-ProvisionedPackages

Write-Host "Cleanup process completed. Press Enter to exit..." -ForegroundColor Green
[void][System.Console]::ReadLine()
