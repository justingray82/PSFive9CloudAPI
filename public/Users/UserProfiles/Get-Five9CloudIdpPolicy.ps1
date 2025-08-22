# Five9Cloud PowerShell Module
# Function: Get-Five9CloudIdpPolicy
# Category: UserProfiles

function Get-Five9CloudIdpPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [bool]$GetCount
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId"
    
    if ($PSBoundParameters.ContainsKey('GetCount')) {
        $uri += "?getCount=$GetCount"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get IDP policy: $_"
    }
}
