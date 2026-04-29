function Set-Five9CloudUserPermission {
    param([string]$UserUID, [string]$Username, [string]$PermissionID, [string]$Permission, [switch]$Remove)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    if (-not $PermissionID) { $PermissionID = Resolve-Five9CloudPermissionID $Permission } ; if (-not $PermissionID) { return }
    if ($Remove) {
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$userUID/permissions/$PermissionID" -Method Delete
        if ($result -ne $false) { Write-Host "$Permission removed from $Username" } else { Write-Host "Failed to remove $Permission from $Username"; return $false }
        } else {
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$userUID/permissions/$PermissionID" -Method Post
        if ($result -ne $false) { Write-Host "$Permission assigned to $Username" } else { Write-Host "Failed to assign $Permission to $Username"; return $false }
    }
}