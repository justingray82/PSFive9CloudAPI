# Five9Cloud PowerShell Module
# Function: Get-Five9CloudCallCenterMeta
# Category: General

function Get-Five9CloudCallCenterMeta {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Standard', 'Lightning')]
        [string]$Type
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp/$IdpPolicyId/call-center-meta?type=$Type"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        }
    } catch {
        Write-Error "Failed to get call center meta: $_"
    }
}
