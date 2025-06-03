# Set your subscription ID
$subscriptionId = "SUB_ID"
Set-AzContext -SubscriptionId $subscriptionId

# Define the specific Log Analytics workspace ID
$workspaceId = "/subscriptions/SUBID/resourceGroups/RESORCEGROUP/providers/Microsoft.OperationalInsights/workspaces/WORKSPACE"

# Define the resource type for NSGs
$resourceType = "Microsoft.Network/networkSecurityGroups"

# Toggle this variable to control 'what if' mode
$whatIf = $false  # Set to $true to preview, $false to actually remove settings

# Define the output file path
$outputFilePath = "NSGsWithTargetWorkspaceDiagnosticsRemoved.csv"

# Initialize an array to hold the results
$results = @()

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    Write-Output "Processing resource group: $($rg.ResourceGroupName)"

    # Get all NSGs in the current resource group
    $nsgs = Get-AzResource -ResourceGroupName $rg.ResourceGroupName -ResourceType $resourceType

    foreach ($nsg in $nsgs) {
        $resourceId = $nsg.ResourceId
        $nsgName = $nsg.Name
        $nsgLocation = $nsg.Location

        # Retrieve diagnostic settings for the NSG
        $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resourceId

        # Check if any diagnostic setting is configured to the specified workspace
        foreach ($setting in $diagnosticSettings) {
            if ($setting.WorkspaceId -eq $workspaceId) {
                if ($whatIf) {
                    Write-Output "Would remove diagnostic setting $($setting.Name) from NSG $($nsg.Name) in resource group $($rg.ResourceGroupName)"
                } else {
                    Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $setting.Name
                    Write-Output "Removed diagnostic setting $($setting.Name) from NSG $($nsg.Name) in resource group $($rg.ResourceGroupName)"
                }

                # Record the NSG and action in results
                $results += [PSCustomObject]@{
                    ResourceGroupName = $rg.ResourceGroupName
                    NSGName           = $nsgName
                    ResourceId        = $resourceId
                    Region            = $nsgLocation
                    Action            = "Removed - Specific Workspace"
                }
            }
        }
    }
}

# Export the results to CSV
if ($results.Count -gt 0) {
    $results | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8
    Write-Output "Exported results to $outputFilePath"
}