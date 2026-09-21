$groupId = (Get-MgGroup -Filter "displayName eq 'Finance-Team'").Id

$roles = Get-AzRoleAssignment -ObjectId $groupId |
Select-Object DisplayName, RoleDefinitionName, Scope

if ($roles) {
    $roles | Format-Table -AutoSize
} else {
    @([PSCustomObject]@{
        DisplayName = ""
        RoleDefinitionName = ""
        Scope = ""
    }) | Format-Table -AutoSize
    Write-Host "No role assignments found for Finance-Team" -ForegroundColor Yellow
}