function Resolve-Five9CloudUserIDPPolicy ([string]$Username) {
    $result = Get-Five9CloudUserDetails -Filter "username=='$Username'"
    if ($result.items.Count -gt 0) { return $result.items.idpPolicyId }
    Write-Host "User '$Username' not found." -ForegroundColor Red; return $null
}