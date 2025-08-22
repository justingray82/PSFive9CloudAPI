﻿# Five9Cloud PowerShell Module
# Function: Set-Five9CloudMigrationGroupFilter
# Category: MigrationGroups

function Set-Five9CloudMigrationGroupFilter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$GroupId,
        [string]$Matcher
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration-groups/$GroupId:apply-filter"
    
    $body = @{}
    if ($Matcher) { $body['matcher'] = $Matcher }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to apply filter to migration group: $_"
    }
}
