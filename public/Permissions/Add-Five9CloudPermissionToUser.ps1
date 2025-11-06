# Five9Cloud PowerShell Module
# Function: Add-Five9CloudPermissionToUser
# Category: Permissions
function Add-Five9CloudPermissionToUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserUID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$userName,
        [Parameter(Mandatory = $true)][string]$Permission
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

    # If userName is provided, resolve it to userUID
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving user name '$userName' to userUID..."
        
        try {
            $userLookup = Get-Five9CloudUserList -Filter "username=='$($userName)'"
            if ($userLookup.items.Count -gt 0) {
                $UserUID = $userLookup.items[0].userUID
                Write-Verbose "Found user with ID: $userName"
            }
        } catch {
            Write-Verbose "No user found with name '$userName'"
        }
        
        # If not found, throw error
        if (-not $UserUID) {
            Write-Error "User with name '$userName' not found."
            return
        }
    }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/permissions/$Permission"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body "{}"
    } catch {
        Write-Error "Failed to add permission to user: $_"
    }
}
