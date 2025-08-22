# Five9Cloud PowerShell Module
# Function: Update-Five9CloudUserIdpPolicy
# Category: UserManagement

function Update-Five9CloudUserIdpPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [string]$IdpFederationId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID/idp-policies/$IdpPolicyId"
    
    $body = @{}
    if ($IdpFederationId) { $body['idpFederationId'] = $IdpFederationId }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update user IDP policy: $_"
    }
}
