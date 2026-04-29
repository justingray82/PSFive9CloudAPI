function Resolve-Five9CloudPermissionID ([string]$Permission) {
    $result = Get-Five9CloudPermissionList -Filter "name=='$Permission'" -Fields 'permission,name'
    if ($result.items.Count -gt 0) { return $result.items.permission }
    Write-Host "Permission '$Permission' not found." -ForegroundColor Red; return $null
}