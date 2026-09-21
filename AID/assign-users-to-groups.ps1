$assignments = Import-Csv "./user-group-assignments.csv"

foreach ($assignment in $assignments) {

    $user = Get-MgUser -UserId $assignment.UserPrincipalName
    $group = Get-MgGroup -Filter "displayName eq '$($assignment.GroupName)'"

    New-MgGroupMember `
        -GroupId $group.Id `
        -DirectoryObjectId $user.Id

    Write-Host "$($assignment.UserPrincipalName) -> $($assignment.GroupName)" -ForegroundColor Green
}

Write-Host "Bulk Group assignment Completed!" -ForegroundColor Green
