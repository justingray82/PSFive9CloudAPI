# Five9Cloud PowerShell Module
# Function: Add-Five9CloudLegacyIdpPolicy
# Category: LegacyIdpPolicies

function Add-Five9CloudLegacyIdpPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Name,
        [string]$Issuer,
        [datetime]$ValidUntil,
        [string]$SsoNameIDFormat,
        [string]$SsoPostUrl,
        [string]$SsoRedirectUrl
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies"
    
    $body = @{}
    if ($Name) { $body['name'] = $Name }
    if ($Issuer) { $body['issuer'] = $Issuer }
    if ($ValidUntil) { $body['validUntil'] = $ValidUntil.ToString('yyyy-MM-ddTHH:mm:ss') }
    if ($SsoNameIDFormat) { $body['ssoNameIDFormat'] = $SsoNameIDFormat }
    if ($SsoPostUrl) { $body['ssoPostUrl'] = $SsoPostUrl }
    if ($SsoRedirectUrl) { $body['ssoRedirectUrl'] = $SsoRedirectUrl }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create legacy IDP policy: $_"
    }
}
