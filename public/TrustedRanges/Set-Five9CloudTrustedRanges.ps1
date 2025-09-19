# Five9Cloud PowerShell Module
# Function: Set-Five9CloudTrustedRanges
# Category: TrustedRanges
function Set-Five9CloudTrustedRanges {
    [CmdletBinding()]
    param (

        [bool]$Enabled,
        [array]$IpRanges
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/trusted-ip-ranges"
    
    $body = @{}
    if ($PSBoundParameters.ContainsKey('Enabled')) { $body['enabled'] = $Enabled }
    if ($IpRanges) { $body['ipRanges'] = $IpRanges }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to modify trusted ranges: $_"
    }
}
