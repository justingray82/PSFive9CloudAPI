# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMFAFactorList
# Category: MfaPolicies

function Get-Five9CloudMFAFactorList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/mfa/factors"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get MFA factors: $_"
    }
}
