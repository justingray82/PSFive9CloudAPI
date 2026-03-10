function Add-Five9CloudPermissionSetToUser {
    param([Parameter(Mandatory = $true)][string]$UserUID,[Parameter(Mandatory = $true)][string]$PermissionSet)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$UserUID/roles/$PermissionSet" -Method Post
    if ($result -ne $false) { Write-Host "User $UserUID added to permission $PermissionSet" } else { Write-Host "Failed to add $UserUID to permission $PermissionSet" }
}

