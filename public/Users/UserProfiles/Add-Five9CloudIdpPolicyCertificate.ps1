# Five9Cloud PowerShell Module
# Function: Add-Five9CloudIdpPolicyCertificate
# Category: UserProfiles

function Add-Five9CloudIdpPolicyCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [Parameter(Mandatory = $true)][string]$Certificate
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId/certificates"
    
    $body = @{
        certificate = $Certificate
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to add IDP policy certificate: $_"
    }
}
