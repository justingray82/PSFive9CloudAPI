# Five9Cloud PowerShell Module
# Function: Update-Five9CloudUserAuthNDateTime
# Category: Migration

function Update-Five9CloudUserAuthNDateTime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)][string]$AuthType,
        [datetime]$LoginTime
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID/migration:log-in"
    
    $body = @{
        authType = $AuthType
    }
    if ($LoginTime) { $body['loginTime'] = $LoginTime.ToString('yyyy-MM-ddTHH:mm:ss') }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update user auth datetime: $_"
    }
}
