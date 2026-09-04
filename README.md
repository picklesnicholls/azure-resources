# Microsoft Azure — PowerShell Scripts

A collection of PowerShell scripts I've compiled, for Azure Resources.

## Contents

### Entra
Scripts for managing Microsoft Entra ID (formerly Azure AD). Users,
groups, app registrations and API permissions.

| Script | Description |
|--------|-------------|
| `AssignAPI-Permissions.ps1` | Assigns API permissions to the specified Enterprise App |
| `RemoveAPI-Permissions.ps1` | Removes API permissions from the specified Enterprise App |

### NetworkSecurityGroups
Scripts for creating, auditing and managing Azure NSGs.

|       Script                   |         Description              |
|--------------------------------|----------------------------------|
| `Remove-NSGDiagnostics-ForWorkspace.ps1` | Removes all NSG diagnostic settings that are configured for a specific Log Analytics workspace |
| `Remove-AllNSGDiagnostics.ps1` | Removes all NSG diagnostic settings from all NSGs across all resource groups |

## Prerequisites

- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Az module: `Install-Module -Name Az -Scope CurrentUser`
- Microsoft Graph module where noted (`Install-Module Microsoft.Graph`)
- Appropriate RBAC permissions for the operations performed  
- See each script's comment header for specifics

## Contributing  

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and PRs welcome.
