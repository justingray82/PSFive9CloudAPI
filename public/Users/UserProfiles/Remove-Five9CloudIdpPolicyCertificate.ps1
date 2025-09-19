﻿# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudIdpPolicyCertificate
# Category: UserProfiles

function Remove-Five9CloudIdpPolicyCertificate {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [Parameter(Mandatory = $true)][string]$IdpCertificateId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/idp-policies/$IdpPolicyId/certificates/$IdpCertificateId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to delete IDP policy certificate: $_"
    }
}
