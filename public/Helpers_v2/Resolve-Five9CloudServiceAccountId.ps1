function Resolve-Five9CloudServiceAccountId ([string]$ServiceAccountName) {
    $found = @(Get-Five9CloudServiceAccounts | Where-Object { $_.name -eq $ServiceAccountName })
    if ($found.Count -gt 0) { return $found[0].serviceAccountId }
    Write-Host "Service account '$ServiceAccountName' not found." -ForegroundColor Red; return $null
}