# Copy user-group-assignments.example.csv to user-group-assignments.csv
# and fill in your own users/groups before running this.
$assignments = Import-Csv "./user-group-assignments.csv"

foreach ($assignment in $assignments) {
    try {
        $user = Get-MgUser -UserId $assignment.UserPrincipalName -ErrorAction Stop
        $group = Get-MgGroup -Filter "displayName eq '$($assignment.GroupName)'" -ErrorAction Stop

        if (-not $group) {
            throw "Group '$($assignment.GroupName)' not found"
        }

        New-MgGroupMember `
            -GroupId $group.Id `
            -DirectoryObjectId $user.Id `
            -ErrorAction Stop

        Write-Host "$($assignment.UserPrincipalName) -> $($assignment.GroupName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to assign $($assignment.UserPrincipalName) to $($assignment.GroupName): $_" -ForegroundColor Red
    }
}

Write-Host "Bulk group assignment completed!" -ForegroundColor Cyan
