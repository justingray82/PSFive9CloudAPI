# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMFAPolicy
# Category: MFAPolicies
# CONSOLIDATED VERSION - Single function for MFA policy (only one existed)

function Get-Five9CloudMFAPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Original: Get-Five9CloudMFAPolicy
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/mfa/policy"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve MFA policy: $_"
    }
}
