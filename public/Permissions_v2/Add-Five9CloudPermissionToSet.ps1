function Add-Five9CloudPermissionToSet {
    param([Parameter(Mandatory = $true)][string]$SetID,[Parameter(Mandatory = $true)][string]$Permission)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/roles/$SetID/permissions/$Permission" -Method Post
    if ($result) { Write-Host "Permission assigned to $SetID" } else { Write-Host "Failed to assign permission to $SetID" }
}