# Azure Network Security Groups

The below contains info on what each script in this repo does.

- **Remove-NSGDiagnostics-ForWorkspace.ps1**
  - Removes all NSG diagnostic settings that are configured for a specific Log Analytics workspace, within a specified Azure subscription. For example, if you have multiple NSGs configured to send diagnostic settings to a LAW of MY-LAW-01, and you specify this in the script, then the diagnostic settings for those NSGs will be removed.
    You can run this in 'WhatIf' prior, which will output the results to CSV. 
    Change the WhatIf to false to remove the settings.

- **Remove-AllNSGDiagnostics.ps1**
  - Removes all NSG diagnostic settings from all NSGs across all resource groups, within a specified Azure subscription. You can run this in 'WhatIf' prior, however there is no CSV export report. You would need to add this if you need. 
  Change the WhatIf to false to remove the settings.
