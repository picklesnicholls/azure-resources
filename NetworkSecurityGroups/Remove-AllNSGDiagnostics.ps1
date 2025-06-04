# Set your subscription ID
$subscriptionId = "be509248-a046-4b38-8652-8fc63d71815f"
Set-AzContext -SubscriptionId $subscriptionId

# Define the resource type for NSGs
$resourceType = "Microsoft.Network/networkSecurityGroups"

# Toggle this variable to control 'what if' mode
$whatIf = $false  # Set to $true to preview, $false to actually remove settings

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    Write-Output "Processing resource group: $($rg.ResourceGroupName)"

    # Get all NSGs in the current resource group
    $nsgs = Get-AzResource -ResourceGroupName $rg.ResourceGroupName -ResourceType $resourceType

    foreach ($nsg in $nsgs) {
        # Get the diagnostic settings for each NSG
        $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $nsg.ResourceId

        # Loop through each diagnostic setting
        foreach ($setting in $diagnosticSettings) {
            if ($whatIf) {
                # Preview mode - display what would be done
                Write-Output "Would remove diagnostic setting $($setting.Name) from NSG $($nsg.Name) in resource group $($rg.ResourceGroupName)"
            } else {
                # Actual mode - remove the diagnostic setting
                Remove-AzDiagnosticSetting -ResourceId $nsg.ResourceId -Name $setting.Name
                Write-Output "Removed diagnostic setting $($setting.Name) from NSG $($nsg.Name) in resource group $($rg.ResourceGroupName)"
            }
        }
    }
}