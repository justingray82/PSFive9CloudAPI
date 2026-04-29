function Resolve-Five9CloudIdPPolicyID ([string]$IdpPolicy) {
    $result = Get-Five9CloudIdpPolicyDetails
    $filteredResult = $result.items | ? { $_.name -eq "$($IdpPolicy)" }
    if ($filteredResult.name -ne $null) { return $filteredResult.idpPolicyId }
    Write-Host "IdP Policy '$IdpPolicy' not found." -ForegroundColor Red; return $null
}