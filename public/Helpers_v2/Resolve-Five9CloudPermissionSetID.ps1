function Resolve-Five9CloudPermissionSetId ([string]$PermissionSetName) {
    $result = Get-Five9CloudPermissionSetDetails -Filter "name=='$($PermissionSetName)'"
    if ($result.items.Count -gt 0) { return $result.items.role }
    Write-Error "Permission Set '$PermissionSetName' not found."; return $null
}