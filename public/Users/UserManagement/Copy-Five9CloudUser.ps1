# Five9Cloud PowerShell Module
# Function: Copy-Five9CloudUser
# Category: UserManagement

function Copy-Five9CloudUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [bool]$Split,
        [Parameter(Mandatory = $true)][hashtable]$UserCreationData
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID:duplicate"
    
    if ($PSBoundParameters.ContainsKey('Split')) {
        $uri += "?split=$Split"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($UserCreationData | ConvertTo-Json)
    } catch {
        Write-Error "Failed to duplicate user: $_"
    }
}
