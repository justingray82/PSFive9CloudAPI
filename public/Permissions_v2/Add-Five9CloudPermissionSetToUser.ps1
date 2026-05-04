function Add-Five9CloudPermissionSetToUser {
    param([Parameter(Mandatory = $true)][string]$Username,[string]$UserUID,[Parameter(Mandatory = $true)][string]$PermissionSet,[string]$SetID)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    if (-not $SetID) { $SetID = Resolve-Five9CloudPermissionSetID $PermissionSet } ; if (-not $SetID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$UserUID/roles/$SetID" -Method Post
    if ($result -ne $false) { Write-Host "User $UserUID added to permission $PermissionSet" } else { Write-Host "Failed to add $UserUID to permission $PermissionSet" }
}
