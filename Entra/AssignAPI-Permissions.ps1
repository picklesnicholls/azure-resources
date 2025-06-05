# -----------------------------
# VARIABLES (update these)
# -----------------------------

# Your Azure AD Tenant ID
$TenantID = "TENANT-ID"

# The ID of the API
# (e.g. common Microsoft API's such as Microsoft Graph, DefenderATP, SharePoint)
# For a full list of API app ID's, check out https://github.com/dmb2168/o365-appids/blob/master/ids.md
$AppId = "API-APP-ID"

# Display name of your Managed Identity's Service Principal (as seen in Entra ID)
$DisplayNameOfMSI = "ENTERPRISE-APP-NAME"

# List of Microsoft Graph app-role values you want to assign to the MSI
# (e.g. "AuditLog.Read.All", "User.Read.All", etc. – must match the `Value` of AppRoles)
# For a complete list of Graph permissions, check out https://graphpermissions.merill.net
# For Defender, check out https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-list
$Permissions = @(
    "Machine.Isolate",
    "Machine.ReadWrite.All"
)


# ------------------------------------------------
# 1. Install/Import Microsoft.Graph module if needed
# ------------------------------------------------
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft.Graph module not found; installing..."
    Install-Module -Name Microsoft.Graph -Force

    # NOTE: After installing, you may need to close/reopen PowerShell or import it explicitly:
    Import-Module Microsoft.Graph
}

# -------------------------------------
# 2. Connect to Microsoft Graph
# -------------------------------------
# We request only the AppRoleAssignment.ReadWrite.All and Directory.Read.All scopes in application context.
# Adjust -Scopes or add additional scopes if you need read/write of Azure AD objects beyond app roles.
Write-Host "Connecting to Microsoft Graph (scopes: AppRoleAssignment.ReadWrite.All, Directory.Read.All) ..."
Connect-MgGraph -TenantId $TenantID -Scopes "AppRoleAssignment.ReadWrite.All", "Directory.Read.All"

# Optional: verify which profile is selected (e.g. beta vs v1.0)
# Select-MgProfile -Name "v1.0"

# ------------------------------------------------
# 3. Locate the Managed Identity’s Service Principal
# ------------------------------------------------
Write-Host "Retrieving Service Principal for managed identity '$DisplayNameOfMSI'..."
$MSI = Get-MgServicePrincipal -Filter "displayName eq '$DisplayNameOfMSI'"
if (-not $MSI) {
    Write-Error "Service principal with displayName '$DisplayNameOfMSI' not found. Exiting."
    return
}

# ---------------------------------------------------------
# 4. Locate the Microsoft Graph Service Principal (resource)
# ---------------------------------------------------------
Write-Host "Retrieving API app ID (appId = $AppId) ..."
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$AppId'"
if (-not $GraphServicePrincipal) {
    Write-Error "API app ID (appId = $AppId) not found. Exiting."
    return
}

# ----------------------------------------------------
# 5. Loop through each requested permission (AppRole)
# ----------------------------------------------------
foreach ($Permission in $Permissions) {

    # Find the AppRole object under Graph’s service principal where:
    #   • Value matches the permission string (e.g. "AuditLog.Read.All")
    #   • AllowedMemberTypes contains "Application" (i.e. application-type permission)
    $AppRole = $GraphServicePrincipal.AppRoles |
               Where-Object {
                   ($_.Value -eq $Permission) -and
                   ($_.AllowedMemberTypes -contains "Application")
               }

    if ($AppRole) {
        Write-Host "Assigning permission '$Permission' to '$DisplayNameOfMSI'..."

        # Build the body payload for the assignment
        $Body = @{
            "PrincipalId" = $MSI.Id           # The MSI’s service principal objectId
            "ResourceId"  = $GraphServicePrincipal.Id  # The Graph app’s service principal objectId
            "AppRoleId"   = $AppRole.Id       # The GUID of the specific AppRole
        }

        # Create the AppRole assignment
        New-MgServicePrincipalAppRoleAssignment `
            -ServicePrincipalId $MSI.Id `
            -BodyParameter $Body

    } else {
        Write-Warning "AppRole with Value '$Permission' (AllowedMemberTypes includes 'Application') was not found under Microsoft Graph."
    }
}

Write-Host "All requested permission assignments completed."
