function Resolve-Five9CloudUserProfileId ([string]$UserProfileName) {
    # No RSQL name filter observed in the HAR - list (small set) and match client-side.
    foreach ($p in @((Get-Five9CloudUserProfiles).items)) {
        if ($p -and $p.name -eq $UserProfileName) { return $p.userProfileId }
    }
    Write-Host "User profile '$UserProfileName' not found." -ForegroundColor Red; return $null
}