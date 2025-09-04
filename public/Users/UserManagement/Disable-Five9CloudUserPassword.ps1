# Five9Cloud PowerShell Module
# Function: Expire-Five9CloudUserPassword
# Category: UserManagement

function Disable-Five9CloudUserPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [bool]$ProvideTempPassword
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID/password:expire"
    
    if ($PSBoundParameters.ContainsKey('ProvideTempPassword')) {
        $uri += "?provideTempPassword=$ProvideTempPassword"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to expire user password: $_"
    }
}

