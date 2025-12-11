function Set-Five9CloudReasonCodeSet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$UserName,
        [Parameter()]
        [string]$ReasonCodeSet
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

    # If UserName is provided, resolve it to UserUID
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving user name '$ByName' to UserUID..."
        
        try {
            $UserLists = Get-Five9CloudUserList -Filter "username=='$($UserName)'"
            if ($UserLists.items.count -gt 0) {
                $UserID = $UserLists.items.userUID
                Write-Verbose "Found user with ID: $UserName"
            }
        } catch {
            Write-Verbose "No user found with name '$UserName'"
        }
        
        # If still not found, throw error
        if (-not $UserID) {
            Write-Error "User with name '$UserName' not found."
            return
        }
    }

    Write-Verbose "Resolving reason code set '$ReasonCodeSet' to reasonCodeSetId..."
        
    try {
        $SetList = Get-Five9CloudReasonCodeSets -Filter "name=='$($ReasonCodeSet)'"
        if ($SetList.items.count -gt 0) {
            $ReasonCodeSetID = $SetList.items.reasonCodeSetId
        }
    } catch {
        Write-Verbose "No Reason Code Set found with name '$ReasonCodeSet'"
    }
            
    # If still not found, throw error
    if (-not $UserID) {
        Write-Error "Reason code Set '$ReasonCodeSet' not found."
        return
    }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9CloudToken.DomainId)/reason-code-sets/$($ReasonCodeSetID)/users/$($UserID)"
    
    try {
        Invoke-RestMethod -Uri $uri -Method POST -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        } | Out-Null
    } catch {
        Write-Error "Failed to add record set to users: $_"
    }
}