# Five9Cloud PowerShell Module
# Function: Add-Five9CloudMFAPolicy
# Category: MfaPolicies

function Add-Five9CloudMFAPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/mfa/policy"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to create MFA policy: $_"
    }
}
