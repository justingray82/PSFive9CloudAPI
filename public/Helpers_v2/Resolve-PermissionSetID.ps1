function Resolve-PermissionSetID ([string]$PermissionSet) {
    $result = Get-Five9CloudPermissionSetDetails -Filter "name=='$PermissionSet'" -Fields 'role,name'
    if ($result.items.Count -gt 0) { return $result.items.role }
    Write-Error "Permission Set '$PermissionSet' not found."; return $null
}