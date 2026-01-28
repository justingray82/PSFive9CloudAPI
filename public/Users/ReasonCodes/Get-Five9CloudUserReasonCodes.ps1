function Get-Five9CloudUserReasonCodes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserUID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$userName
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving user name '$userName' to userUID..."
        
        try {
            $userLookup = Get-Five9CloudUserList -Filter "username=='$($userName)'"
            if ($userLookup.items.count -gt 0) {
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
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9CloudToken.DomainId)/users/$($UserUID)/reason-codes"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "No Reason Codes settings found for user $UserUID"
        } else {
            Write-Error "Failed to get Reason Code settings: $_"
        }
    }
}