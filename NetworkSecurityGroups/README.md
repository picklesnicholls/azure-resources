# Azure Network Security Groups

The below contains info on what each script in this repo does.

- **DisableNsgDiags-V7.ps1**
  - Removes NSG diagnostics that are configured for a specific Log Analytics workspace, within the specified subscription. For example, if you have multiple NSGs configured to send diagnostic settings to a LAW of MY-LAW-01, and you specify this in the script, then the diagnostic settings for those NSGs will be removed.
    You can run this in 'WhatIf' prior, which will output the results to CSV. Cchange the WhatIf to false to remove the settings.
