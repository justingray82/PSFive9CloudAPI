function Set-Five9CloudUserPermission {
    param([string]$UserUID, [string]$Username, [string]$Permission)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$userUID/permissions/$Permission" -Method Post
    if ($result -ne $false) { Write-Host "$Permission assigned to $Username" } else { Write-Host "Failed to assign $Permission to $Username"; return $false }
}