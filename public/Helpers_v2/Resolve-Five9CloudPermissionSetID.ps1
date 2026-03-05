function Resolve-Five9CloudPermissionSetID ([string]$PermissionSet) {
    $result = Get-Five9CloudUsers -Filter "username=='$Username'" -Fields 'useruid,name'
    if ($result.items.Count -gt 0) { return $result.items.userUID }
    Write-Error "User '$Username' not found."; return $null
}