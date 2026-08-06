function Copy-Five9CloudUser {
    param(
        [string]$UserUID,
        [string]$Username,

        [Parameter(Mandatory)][string]$NewUsername,
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,

        [ValidateSet('ACTIVE','INACTIVE')][string]$Status = 'ACTIVE',
        [switch]$AutoMigration,
        [string]$Extension,
        [string]$StartDate,
        [string]$HomeNumber,
        [string]$Locale,
        [string]$MobileNumber,
        [string]$PublicName,
        [string]$Timezone,
        [string]$WorkNumber,
        [switch]$MustChangePassword,

        # Copy toggles — everything is copied by default; pass a Skip switch to opt out
        [switch]$SkipApplications,
        [switch]$SkipPermissions,
        [switch]$SkipRoles,
        [switch]$SkipAgentGroups,
        [switch]$SkipMediaTypes,
        [switch]$SkipSkills,
        [switch]$SkipCircles,
        [switch]$SkipReasonCodes
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    $base = $global:Five9.ApiBaseUrl
    $dom  = $global:Five9.DomainId

    # 1. Duplicate the source user ------------------------------------------------
    $body = @{
        username     = $NewUsername
        firstName    = $FirstName
        lastName     = $LastName
        email        = $Email
        status       = $Status
        autoMigration      = [bool]$AutoMigration
        mustChangePassword = [bool]$MustChangePassword
        extension    = $Extension
        startDate    = $StartDate
        homeNumber   = $HomeNumber
        locale       = $Locale
        mobileNumber = $MobileNumber
        publicName   = $PublicName
        timezone     = $Timezone
        workNumber   = $WorkNumber
    }

    $dup = Invoke-Five9CloudApi "$base/users/v1/domains/$dom/users/$($UserUID):duplicate" -Method Post -Body $body
    if ($dup -eq $false) { Write-Host "Failed to duplicate user '$Username' as '$NewUsername'."; return $false }

    # Resolve the new user's UID (response first, fall back to a username lookup)
    $NewUserUID = $dup.userUID
    if (-not $NewUserUID) { $NewUserUID = Resolve-Five9CloudUserUID $NewUsername }
    if (-not $NewUserUID) { Write-Host "User '$NewUsername' created, but the new UID could not be resolved — skipping copy steps."; return $false }
    Write-Host "User '$Username' duplicated as '$NewUsername' ($NewUserUID)."

    # 2. Applications -------------------------------------------------------------
    if (-not $SkipApplications) {
        $r = Invoke-Five9CloudApi "$base/acl/v1/domains/$dom/users/$NewUserUID/applications:copy?fromUser=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Applications copied." } else { Write-Host "  Failed to copy applications." }
    }

    # 3. Permissions --------------------------------------------------------------
    if (-not $SkipPermissions) {
        $r = Invoke-Five9CloudApi "$base/acl/v1/domains/$dom/users/$NewUserUID/permissions:copy?fromUser=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Permissions copied." } else { Write-Host "  Failed to copy permissions." }
    }

    # 4. Roles (permission sets) --------------------------------------------------
    if (-not $SkipRoles) {
        $r = Invoke-Five9CloudApi "$base/acl/v1/domains/$dom/users/$NewUserUID/roles:copy?fromUser=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Roles copied." } else { Write-Host "  Failed to copy roles." }
    }

    # 5. Agent groups -------------------------------------------------------------
    if (-not $SkipAgentGroups) {
        $r = Invoke-Five9CloudApi "$base/agent-groups/v1/domains/$dom/users/$NewUserUID/agent-groups:copy?fromUserUID=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Agent groups copied." } else { Write-Host "  Failed to copy agent groups." }
    }

    # 6. Media types --------------------------------------------------------------
    if (-not $SkipMediaTypes) {
        $r = Invoke-Five9CloudApi "$base/skills/v1/domains/$dom/users/$NewUserUID/media-types:copy?fromUserUID=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Media types copied." } else { Write-Host "  Failed to copy media types." }
    }

    # 7. Skills -------------------------------------------------------------------
    if (-not $SkipSkills) {
        $r = Invoke-Five9CloudApi "$base/skills/v1/domains/$dom/users/$NewUserUID/skills:copy?fromUserUID=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Skills copied." } else { Write-Host "  Failed to copy skills." }
    }

    # 8. Circle memberships (copy each circle the source belongs to) --------------
    if (-not $SkipCircles) {
        $srcCircles = (Invoke-Five9CloudApi "$base/circles/v1/domains/$dom/circles/users/$UserUID").items
        foreach ($c in $srcCircles) {
            $cid = if ($c.id) { $c.id } else { $c.circleId }
            if (-not $cid) { continue }
            $r = Invoke-Five9CloudApi "$base/circles/v1/domains/$dom/circles/$cid/users/$NewUserUID" -Method Post
            if ($r -ne $false) { Write-Host "  Added to circle '$($c.name)'." } else { Write-Host "  Failed to add to circle '$($c.name)'." }
        }
    }

    # 9. Reason codes -------------------------------------------------------------
    if (-not $SkipReasonCodes) {
        $r = Invoke-Five9CloudApi "$base/agent-sessions/v1/domains/$dom/users/$NewUserUID/reason-codes:copy?sourceUserUID=$UserUID" -Method Post
        if ($r -ne $false) { Write-Host "  Reason codes copied." } else { Write-Host "  Failed to copy reason codes." }
    }

    Write-Host "Duplication of '$Username' -> '$NewUsername' complete."

}