function Set-Five9CloudUserMfaPolicy {
    param(
        [string]$UserUID,
        [string]$Username,
        [switch]$Remove
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    if (-not $Remove) {
        if (-not $MfaPolicyId) { $MfaPolicyId = Get-Five9CloudDomainMFAPolicies } ; if (-not $MfaPolicyId) { return }
    }

    $uri = "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID"

    # Single-user GET returns the object directly (no items[] envelope)
    $current = Invoke-Five9CloudApi $uri
    if (-not $current -or $current -eq $false) { Write-Error "Unable to retrieve user '$UserUID'."; return }

    # PSCustomObject null fields are read-only — convert to a mutable hashtable
    $body = @{}
    $current.PSObject.Properties | ForEach-Object { $body[$_.Name] = $_.Value }

    if ($Remove) { $body['mfaPolicyId'] = $null } else { $body['mfaPolicyId'] = $MfaPolicyId }

    $result = Invoke-Five9CloudApi $uri -Method Put -Body $body
    if ($result -ne $false) {
        Write-Host "MFA policy updated for '$($body.username)'."
    } else {
        Write-Host "Failed to update MFA policy for '$($body.username)'."
    }
}