# CONTRIBUTING

Thanks for considering a contribution! Guidelines below keep the
collection consistent and safe for others to run.

## Adding a script
- Place it in the matching subfolder (`Entra`, `NetworkSecurityGroups`)  
  Create a new folder if no category fits, and add a README table row.
- Include a comment header at the top documenting:
  - purpose (what it does and why),
  - prerequisites (modules, versions),
  - required Azure RBAC / Graph permissions,
  - an example invocation.
- Parameterise rather than hard-code: tenant IDs, subscription IDs
  and resource names should be parameters, not literals.

## Coding style
- Use approved PowerShell verbs (Get-, Set-, New-, Remove-) in function names.
- Include comment-based help for anything non-trivial.
- Prefer `Connect-AzAccount` / `Connect-MgGraph` scoped to what the script
  needs, and note the required scopes in the header.
- Idempotent is better than idempotent-ish: scripts shouldn't fail if run twice.

## Before submitting
- Test the script at least once against a real (or sandbox) tenant.
- Confirm the script fails gracefully if permissions are missing rather
  than half-completing an operation.
- Strip any sensitive data — tenant IDs, real domains, object IDs,
  log excerpts before committing.
- Add or update the relevant table row in the README.
- Descriptive commit messages, please: "Add NSG flow-log audit script",
  not "test".

## Reporting issues
Include the script name, the full error output, your PowerShell version
(`$PSVersionTable`), and what you were trying to achieve.
