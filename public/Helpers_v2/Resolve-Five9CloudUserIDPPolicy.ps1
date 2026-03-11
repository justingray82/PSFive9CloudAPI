function Resolve-Five9CloudUserIDPPolicy ([string]$Username) {
    $result = Get-Five9CloudUserDetails -Filter "username=='$Username'"
    if ($result.items.Count -gt 0) { return $result.items.idpPolicyId }
    Write-Error "User '$Username' not found."; return $null
}