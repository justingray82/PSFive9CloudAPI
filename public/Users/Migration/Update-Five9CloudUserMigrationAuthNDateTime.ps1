# Five9Cloud PowerShell Module
# Function: Update-Five9CloudUserMigrationAuthNDateTime
# Category: Migration

function Update-Five9CloudUserMigrationAuthNDateTime {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/migration:logged-in"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to update user migration auth datetime: $_"
    }
}
