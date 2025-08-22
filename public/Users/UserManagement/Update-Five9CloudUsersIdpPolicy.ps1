# Five9Cloud PowerShell Module
# Function: Update-Five9CloudUsersIdpPolicy
# Category: UserManagement

function Update-Five9CloudUsersIdpPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$SourcePolicyId,
        [Parameter(Mandatory = $true)][string]$TargetPolicyId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users:change-idp-policy"
    
    $body = @{
        sourcePolicyId = $SourcePolicyId
        targetPolicyId = $TargetPolicyId
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to change users IDP policy: $_"
    }
}
