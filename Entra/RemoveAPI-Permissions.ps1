# -----------------------------
# VARIABLES (update these)
# -----------------------------

$TenantID = "TENANT-ID"
$AppId = "API-APP-ID"  # e.g. Microsoft Graph, DefenderATP, etc.
$DisplayNameOfMSI = "ENTERPRISE-APP-NAME"

# List of app-role permission values to remove from the MSI
$Permissions = @(
    "User.Read.All",
    "AuditLog.Read.All"
)

# ------------------------------------------------
# 1. Install/Import Microsoft.Graph module if needed
# ------------------------------------------------
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft.Graph module not found; installing..."
    Install-Module -Name Microsoft.Graph -Force
    Import-Module Microsoft.Graph
}

# -------------------------------------
# 2. Connect to Microsoft Graph
# -------------------------------------
Write-Host "Connecting to Microsoft Graph (scopes: AppRoleAssignment.ReadWrite.All, Directory.Read.All) ..."
Connect-MgGraph -TenantId $TenantID -Scopes "AppRoleAssignment.ReadWrite.All", "Directory.Read.All"

# --------------------------------------------
# 3. Locate the Managed Identity’s Service Principal
# --------------------------------------------
Write-Host "Retrieving Service Principal for managed identity '$DisplayNameOfMSI'..."
$MSI = Get-MgServicePrincipal -Filter "displayName eq '$DisplayNameOfMSI'"
if (-not $MSI) {
    Write-Error "Service principal with displayName '$DisplayNameOfMSI' not found. Exiting."
    return
}

# ---------------------------------------------------------
# 4. Locate the API’s Service Principal (by AppId)
# ---------------------------------------------------------
Write-Host "Retrieving API app ID (appId = $AppId) ..."
$ApiServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$AppId'"
if (-not $ApiServicePrincipal) {
    Write-Error "API service principal with AppId '$AppId' not found. Exiting."
    return
}

# -----------------------------------------
# 5. Get AppRole assignments on the MSI SP
# -----------------------------------------
Write-Host "Getting current app role assignments for the managed identity..."
$CurrentAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSI.Id -All

# -----------------------------------------
# 6. Loop through and remove specified roles
# -----------------------------------------
foreach ($Permission in $Permissions) {
    $AppRole = $ApiServicePrincipal.AppRoles |
               Where-Object {
                   ($_.Value -eq $Permission) -and
                   ($_.AllowedMemberTypes -contains "Application")
               }

    if (-not $AppRole) {
        Write-Warning "Permission '$Permission' not found in the API's app roles."
        continue
    }

    $AssignmentToRemove = $CurrentAssignments |
                          Where-Object {
                              $_.ResourceId -eq $ApiServicePrincipal.Id -and
                              $_.AppRoleId -eq $AppRole.Id
                          }

    if ($AssignmentToRemove) {
        Write-Host "Removing permission '$Permission' from '$DisplayNameOfMSI'..."

        # Delete the app role assignment by ID
        Remove-MgServicePrincipalAppRoleAssignment `
            -ServicePrincipalId $MSI.Id `
            -AppRoleAssignmentId $AssignmentToRemove.Id
    } else {
        Write-Warning "AppRole assignment for '$Permission' not found on '$DisplayNameOfMSI'."
    }
}

Write-Host "Permission removal process completed."