# Five9Cloud PowerShell Module
# Function: Get-Five9CloudLegacyIdpCertificate
# Category: LegacyIdpPolicies

function Get-Five9CloudLegacyIdpCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [Parameter(Mandatory = $true)][string]$IdpCertificateId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies/$IdpPolicyId/certificates/$IdpCertificateId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get legacy IDP certificate: $_"
    }
}
