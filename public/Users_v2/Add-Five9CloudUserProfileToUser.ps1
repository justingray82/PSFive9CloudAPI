function Add-Five9CloudUserProfileToUser {
    # Associates one or more users with a user profile.
    # Endpoint (from admin console HAR):
    #   POST users/v1/domains/{d}/user-profiles/{userProfileId}/users/{userUID}   body {}  -> 204
    #   400 Users--00000112 when the user is already associated with a skill set
    #
    # Usage:
    #   Add-Five9CloudUserProfileToUser -Username 'jdoe@acme.com' -UserProfileName 'userProfile A'
    #   Add-Five9CloudUserProfileToUser -Username 'agent1','agent2','agent3' -UserProfileId 1
    #   Add-Five9CloudUserProfileToUser -UserUID 'AB2LYQDCUSDBSMTZ7JV3H3MHJYR3PVY7' -UserProfileName 'userProfile A'
    param(
        [string[]]$Username,
        [string[]]$UserUID,
        [string]$UserProfileName,
        [string]$UserProfileId
    )

    if (-not $Username -and -not $UserUID) { Write-Error "Specify -Username or -UserUID."; return }
    if (-not $UserProfileId) {
        if (-not $UserProfileName) { Write-Error "Specify -UserProfileName or -UserProfileId."; return }
        $UserProfileId = Resolve-Five9CloudUserProfileId $UserProfileName ; if (-not $UserProfileId) { return }
    }
    $profileLabel = if ($UserProfileName) { $UserProfileName } else { $UserProfileId }

    # Build the target list: UIDs passed straight through, usernames resolved
    $targets = @()
    foreach ($uid in @($UserUID))   { if ($uid) { $targets += [PSCustomObject]@{ Label = $uid; UID = $uid } } }
    foreach ($name in @($Username)) {
        if (-not $name) { continue }
        $uid = Resolve-Five9CloudUserUID $name
        if ($uid) { $targets += [PSCustomObject]@{ Label = $name; UID = $uid } }
    }

    foreach ($t in $targets) {
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/user-profiles/$UserProfileId/users/$($t.UID)" -Method Post -Body @{}
        if ($result -ne $false) { Write-Host "User '$($t.Label)' added to user profile '$profileLabel'." }
        else { Write-Host "Failed to add user '$($t.Label)' to user profile '$profileLabel' (a user already assigned skills directly can't join a user profile)." -ForegroundColor Red }
    }
}