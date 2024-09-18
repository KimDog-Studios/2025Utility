function Invoke-WPFUltimatePerformance {
    <#
    .SYNOPSIS
        Enables or disables the Ultimate Performance power scheme based on its GUID and sets display timeout to never.
    .PARAMETER State
        Specifies whether to "Enable" or "Disable" the Ultimate Performance power scheme.
    #>
    param($State)

    try {
        # GUID of the Ultimate Performance power plan
        $ultimateGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
        $ultimatePlanName = "KimDog's - Ultimate Power Plan"

        # Function to check if the plan exists by name
        function Is-UltimatePerformancePlanInstalled {
            $plans = powercfg -list
            foreach ($plan in $plans) {
                if ($plan -match $ultimatePlanName) {
                    return $true
                }
            }
            return $false
        }

        if ($State -eq "Enable") {
            if (-not (Is-UltimatePerformancePlanInstalled)) {
                # Duplicate the Ultimate Performance power plan using its GUID
                $duplicateOutput = powercfg /duplicatescheme $ultimateGUID

                $guid = $null
                $nameFromFile = "KimDog's - Ultimate Power Plan"
                $description = "Ultimate Power Plan, added via KimDog's Utility"

                # Extract the new GUID from the duplicateOutput
                foreach ($line in $duplicateOutput) {
                    if ($line -match "\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b") {
                        $guid = $matches[0]  # $matches[0] will contain the first match, which is the GUID
                        Write-Output "GUID: $guid has been extracted and stored in the variable."
                        break
                    }
                }

                if (-not $guid) {
                    Write-Output "No GUID found in the duplicateOutput. Check the output format."
                    exit 1
                }

                # Change the name of the power plan and set its description
                $changeNameOutput = powercfg /changename $guid "$nameFromFile" "$description"
                Write-Output "The power plan name and description have been changed. Output:"
                Write-Output $changeNameOutput

                # Set the duplicated Ultimate Performance plan as active
                $setActiveOutput = powercfg /setactive $guid
                Write-Output "The power plan has been set as active. Output:"
                Write-Output $setActiveOutput

                # Set the display timeout to 0 (never turn off)
                powercfg /change monitor-timeout-ac 0
                powercfg /change monitor-timeout-dc 0

                Write-Host "> Ultimate Performance plan installed and set as active."
                Write-Host "> Display timeout has been set to never turn off."
            } else {
                Write-Host "Ultimate Performance plan is already installed and active."
            }
        } elseif ($State -eq "Disable") {
            if (Is-UltimatePerformancePlanInstalled) {
                # Find the GUID of the Ultimate Performance plan
                $installedPlan = powercfg -list | Select-String -Pattern $ultimatePlanName
                if ($installedPlan) {
                    $ultimatePlanGUID = ($installedPlan.Line -split '\s+')[3]

                    # Set a different power plan as active before deleting the Ultimate Performance plan
                    $balancedPlanGUID = (powercfg -list | Select-String -Pattern "Balanced").Line.Split()[3]
                    powercfg -setactive $balancedPlanGUID

                    # Delete the Ultimate Performance plan by GUID
                    powercfg -delete $ultimatePlanGUID

                    Write-Host "Ultimate Performance plan has been uninstalled."
                    Write-Host "> Balanced plan is now active."
                } else {
                    Write-Host "Ultimate Performance plan is not installed."
                }
            } else {
                Write-Host "Ultimate Performance plan is not installed."
            }
        }
    } catch {
        Write-Error "Error occurred: $_"
    }
}

# Example usage
Invoke-WPFUltimatePerformance Enable