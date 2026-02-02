# Five9Cloud PowerShell Module
# Function: Add-Five9CloudMigrationGroup
# Category: MigrationGroups

function Add-Five9CloudMigrationGroup {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Name,
        [datetime]$StartDate,
        [string]$Type,
        [string]$IdpPolicyId,
        [string]$Matcher,
        [bool]$SupportFilter
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration-groups"
    
    $body = @{
        name = $Name
    }
    if ($StartDate) { $body['startDate'] = $StartDate.ToString('yyyy-MM-ddTHH:mm:ss') }
    if ($Type) { $body['type'] = $Type }
    if ($IdpPolicyId) { $body['idpPolicyId'] = $IdpPolicyId }
    if ($Matcher) { $body['matcher'] = $Matcher }
    if ($PSBoundParameters.ContainsKey('SupportFilter')) { $body['supportFilter'] = $SupportFilter }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create migration group: $_"
    }
}
