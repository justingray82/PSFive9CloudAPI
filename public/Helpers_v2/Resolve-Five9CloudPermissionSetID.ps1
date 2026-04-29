function Resolve-Five9CloudPermissionSetID ([string]$PermissionSet) {
    $result = Get-Five9CloudPermissionSetDetails -Filter "name=='$PermissionSet'" -Fields 'role,name'
    if ($result.items.Count -gt 0) { return $result.items.role }
    Write-Host "Permission Set '$PermissionSet' not found." -ForegroundColor Red; return $null
}