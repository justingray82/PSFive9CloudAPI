function Resolve-Five9CloudUserUID ([string]$Username) {
    $result = Get-Five9CloudUserDetails -Filter "username=='$Username'" -Fields 'useruid,name'
    if ($result.items.Count -gt 0) { return $result.items.userUID }
    Write-Error "User '$Username' not found."; return $null
}