function Add-Five9CloudCircleMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CircleName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'User')]
        [string]$UserName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Permission')]
        [string]$PermissionName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
        [string]$ApplicationName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'SkillSet')]
        [string]$SkillSetName,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'MediaChannel')]
        [string]$MediaChannelName
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

        Write-Verbose "Resolving Circle '$CircleName' to CircleID..."
        
        try {
            $circleLookup = Get-Five9CloudCircles -Filter "name=='$($CircleName)'"
            if ($circleLookup.items.count -gt 0) {
                $CircleID = $circleLookup.items[0].id
                Write-Verbose "Found Circle with ID: $CircleName"
            }
        } catch {
            Write-Verbose "No Circle found with name '$CircleName'"
        }
        
        # If not found, throw error
        if (-not $CircleID) {
            Write-Error "Circle with name '$CircleName' not found."
            return
        }
    
    # Build URI based on parameter set
    $baseUri = "$($global:Five9CloudToken.ApiBaseUrl)/circles/v1/domains/$($global:Five9CloudToken.DomainId)/circles/$CircleID"
    
    switch ($PSCmdlet.ParameterSetName) {
        'User' {

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

            $uri = "$baseUri/users/$UserUID"
            Write-Verbose "Adding User $UserUID to Circle $CircleName"
        }
        'Permission' {

            Write-Verbose "Resolving Permission name '$PermissionName' to PermissionUID..."
        
            try {
                $PermissionLookup = Get-Five9CloudPermissionSets -Filter "name=='$($PermissionName)'"
                if ($PermissionLookup.items.count -gt 0) {
                    $PermissionID = $PermissionLookup.items[0].role
                    Write-Verbose "Found Permission Set with ID: $PermissionName"
                }
            } catch {
                Write-Verbose "No Permission Set found with name '$PermissionName'"
            }
            
            # If not found, throw error
            if (-not $PermissionID) {
                Write-Error "Permission Set with name '$PermissionName' not found."
                return
            }

            $uri = "$baseUri/roles/$PermissionID"
            Write-Verbose "Adding Permission Set $PermissionID to Circle $CircleName"
        }
        'Application' {

            Write-Verbose "Resolving Application name '$ApplicationName' to ApplicationUID..."
        
            try {
                $ApplicationLookup = Get-Five9CloudApplicationSets -Filter "name=='$($ApplicationName)'"
                if ($ApplicationLookup.items.count -gt 0) {
                    $ApplicationID = $ApplicationLookup.items[0].applicationSetId
                    Write-Verbose "Found Application Set with ID: $ApplicationName"
                }
            } catch {
                Write-Verbose "No Application Set found with name '$ApplicationName'"
            }
            
            # If not found, throw error
            if (-not $ApplicationID) {
                Write-Error "Application Set with name '$ApplicationName' not found."
                return
            }

            $uri = "$baseUri/application-sets/$ApplicationID"
            Write-Verbose "Adding Application $ApplicationID to Circle $CircleName"
        }
        'SkillSet' {

            Write-Verbose "Resolving Skill name '$SkillName' to SkillUID..."
        
            try {
                $SkillLookup = Get-Five9CloudSkillSets -Filter "name=='$($SkillSetName)'"
                if ($SkillLookup.items.count -gt 0) {
                    $SkillID = $SkillLookup.items[0].skillSetId
                    Write-Verbose "Found Skill Set with ID: $SkillName"
                }
            } catch {
                Write-Verbose "No Skill Set found with name '$SkillName'"
            }
            
            # If not found, throw error
            if (-not $SkillID) {
                Write-Error "Skill Set with name '$SkillName' not found."
                return
            }

            $uri = "$baseUri/skill-sets/$SkillID"
            Write-Verbose "Adding Skill Set $SkillSetID to Circle $CircleName"
        }
        'MediaChannel' {

            Write-Verbose "Resolving Media name '$MediaChannelName' to MediaUID..."
        
            try {
                $MediaLookup = Get-Five9CloudMediaTypeSets -Filter "name=='$($MediaChannelName)'"
                if ($MediaLookup.items.count -gt 0) {
                    $MediaID = $MediaLookup.items[0].MediaTypeSetId
                    Write-Verbose "Found Media Set with ID: $MediaName"
                }
            } catch {
                Write-Verbose "No Media Set found with name '$MediaName'"
            }
            
            # If not found, throw error
            if (-not $MediaID) {
                Write-Error "Media Set with name '$MediaName' not found."
                return
            }

            $uri = "$baseUri/media-type-sets/$MediaID"
            Write-Verbose "Adding Media Channel $MediaID to Circle $CircleName"
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method POST -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
        
        Write-Verbose "Successfully added $($PSCmdlet.ParameterSetName) to Circle $CircleName"
    } catch {
        Write-Error "Failed to add $($PSCmdlet.ParameterSetName) to circle: $_"
    }
}