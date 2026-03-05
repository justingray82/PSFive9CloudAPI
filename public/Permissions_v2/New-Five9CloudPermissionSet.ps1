function New-Five9CloudPermissionSet {
    param([Parameter(Mandatory = $true)][string]$Name,[string]$Description)
    $body = [ordered]@{name = $Name; description = $Description} | ConvertTo-Json
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/roles" -Body $body -Method Post
    if ($result) { Write-Host "Permission set $Name created"; return $result.role } else { Write-Host "Failed to create permission set $Name"; return $false }

}