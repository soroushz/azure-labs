try {
    $groupId = (Get-MgGroup -Filter "displayName eq 'Finance-Team'" -ErrorAction Stop).Id
    if (-not $groupId) {
        throw "Group 'Finance-Team' not found"
    }

    $roles = Get-AzRoleAssignment -ObjectId $groupId -ErrorAction Stop |
        Select-Object DisplayName, RoleDefinitionName, Scope

    if ($roles) {
        $roles | Format-Table -AutoSize
    } else {
        Write-Host "No role assignments found for Finance-Team" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Failed to check role assignments: $_" -ForegroundColor Red
}