# Five9Cloud PowerShell Module
# Function: Get-Five9CloudTrustedRange
# Category: TrustedRanges
# CONSOLIDATED VERSION - Single function (only one Get function exists)

function Get-Five9CloudTrustedRange {
    [CmdletBinding()]
    param (

        [string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Original: Get-Five9CloudTrustedRanges
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/trusted-ip-ranges"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve trusted IP ranges: $_"
    }
}
