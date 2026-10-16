<#
.SYNOPSIS
    Assigns Entra ID directory roles to app service principals via Microsoft Graph.
.DESCRIPTION
    Works around a known limitation in the Entra portal, where assigning a directory
    role to an app/service principal through the UI (especially via PIM) can fail
    with a generic "role not found" error. Loops through an array of app/role pairs
    and assigns each one directly through Graph.
.NOTES
    Requires an active Microsoft Graph connection (see connect-azure.ps1) with
    RoleManagement.ReadWrite.Directory permission and admin consent granted.
#>

param()

try {
    if (-not (Get-MgContext)) {
        throw "Not connected to Microsoft Graph. Run .\connect-azure.ps1 first."
    }

    $assignments = @(
        @{
            AppDisplayName = "PowerShell-Lab"
            RoleName       = "Exchange Administrator"
        }
    )

    foreach ($assignment in $assignments) {
        $sp = Invoke-MgGraphRequest -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$($assignment.AppDisplayName)'" `
            -ErrorAction Stop

        if ($sp.value.Count -eq 0) {
            throw "No service principal found for app '$($assignment.AppDisplayName)'."
        }
        $principalId = $sp.value[0].id

        $role = Invoke-MgGraphRequest -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$filter=displayName eq '$($assignment.RoleName)'" `
            -ErrorAction Stop

        if ($role.value.Count -eq 0) {
            throw "No role definition found for '$($assignment.RoleName)'."
        }
        $roleDefinitionId = $role.value[0].id

        $body = @{
            principalId      = $principalId
            roleDefinitionId = $roleDefinitionId
            directoryScopeId = "/"
        }

        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" `
            -Body ($body | ConvertTo-Json) `
            -ErrorAction Stop | Out-Null

        Write-Host "Assigned '$($assignment.RoleName)' to '$($assignment.AppDisplayName)'" -ForegroundColor Green
    }

    Write-Host "Success!" -ForegroundColor Green
}
catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}