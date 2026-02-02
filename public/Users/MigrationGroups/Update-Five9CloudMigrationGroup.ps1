# Five9Cloud PowerShell Module
# Function: Update-Five9CloudMigrationGroup
# Category: MigrationGroups

function Update-Five9CloudMigrationGroup {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$GroupId,
        [string]$Name,
        [datetime]$StartDate,
        [string]$Status,
        [string]$IdpPolicyId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration-groups/$GroupId"
    
    $body = @{}
    if ($Name) { $body['name'] = $Name }
    if ($StartDate) { $body['startDate'] = $StartDate.ToString('yyyy-MM-ddTHH:mm:ss') }
    if ($Status) { $body['status'] = $Status }
    if ($IdpPolicyId) { $body['idpPolicyId'] = $IdpPolicyId }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update migration group: $_"
    }
}
