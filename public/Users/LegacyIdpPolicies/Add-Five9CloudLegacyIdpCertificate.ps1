# Five9Cloud PowerShell Module
# Function: Add-Five9CloudLegacyIdpCertificate
# Category: LegacyIdpPolicies

function Add-Five9CloudLegacyIdpCertificate {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [Parameter(Mandatory = $true)][string]$Certificate
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/legacy-idp-policies/$IdpPolicyId/certificates"
    
    $body = @{
        certificate = $Certificate
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to create legacy IDP certificate: $_"
    }
}
