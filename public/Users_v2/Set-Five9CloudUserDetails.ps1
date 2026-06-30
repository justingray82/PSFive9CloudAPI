function Set-Five9CloudUserDetails {
    param(
        [string]$UserUID,
        [string]$Username,        # lookup key — used to resolve the UID, not changed

        # Identity / contact
        [string]$FirstName,
        [string]$LastName,
        [string]$Email,
        [string]$Initials,
        [string]$MobileNumber,
        [string]$WorkNumber,
        [string]$HomeNumber,

        # Locale / scheduling
        [string]$Timezone,
        [string]$Locale,
        [string]$StartDate,
        [string]$Extension,

        # Auth / policy
        [ValidateSet('on','off')][string]$Mfa,  # MIGRATED users only; on -> domain policy id, off -> null
        [string]$IdpFederationId,

        # Org / directory
        [string]$EmployeeId,
        [string]$CostCenter,

        # Misc
        [string]$Status,          # plain string on purpose — exact enum set not validated here
        [string]$AvatarUrl,
        [bool]$MustChangePassword
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    # GET current state — the PUT requires the full user payload, not a partial.
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID"
    if (-not $current) { return }

    # Single-user GET returns a flat object; unwrap a paged envelope just in case.
    $user = if ($current.PSObject.Properties.Name -contains 'items') { $current.items[0] } else { $current }
    if (-not $user) { Write-Error "User '$UserUID' not found."; return }

    # EXCLUDED users are excluded from migration and can't be edited via this
    # endpoint (the API returns a misleading "user isn't migrated"). FIT and
    # MIGRATED are both editable, so only block the known-bad state.
    if ($user.fitnessStatus -eq 'EXCLUDED') {
        Write-Host "User '$UserUID' has fitnessStatus 'EXCLUDED' — excluded from migration and not editable here."
        return $false
    }

    # MFA can only be changed on MIGRATED users — fail fast before the PUT.
    if ($PSBoundParameters.ContainsKey('Mfa') -and $user.fitnessStatus -ne 'MIGRATED') {
        Write-Host "MFA can only be changed on MIGRATED users — '$UserUID' is '$($user.fitnessStatus)'."
        return $false
    }

    # Convert the deserialized PSCustomObject to a mutable hashtable.
    # Null fields on a PSCustomObject are read-only and throw on assignment;
    # a hashtable lets us set anything (including clearing a value to '').
    $body = @{}
    $user.PSObject.Properties | ForEach-Object { $body[$_.Name] = $_.Value }

    # Plain string fields: param name -> JSON key. ContainsKey lets an empty
    # string through, so a field can be deliberately cleared (e.g. -MobileNumber '').
    $fieldMap = [ordered]@{
        FirstName            = 'firstName'
        LastName             = 'lastName'
        Email                = 'email'
        Initials             = 'initials'
        MobileNumber         = 'mobileNumber'
        WorkNumber           = 'workNumber'
        HomeNumber           = 'homeNumber'
        Timezone             = 'timezone'
        Locale               = 'locale'
        StartDate            = 'startDate'
        Extension            = 'extension'
        IdpFederationId      = 'idpFederationId'
        EmployeeId           = 'employeeId'
        CostCenter           = 'costCenter'
        Status               = 'status'
        AvatarUrl            = 'avatarUrl'
    }
    foreach ($p in $fieldMap.Keys) {
        if ($PSBoundParameters.ContainsKey($p)) { $body[$fieldMap[$p]] = $PSBoundParameters[$p] }
    }

    # MFA: 'on' resolves the domain MFA policy id; 'off' sends a literal null.
    if ($PSBoundParameters.ContainsKey('Mfa')) {
        if ($Mfa -eq 'on') {
            $policyId = Get-Five9CloudDomainMFAPolicies
            if (-not $policyId) { Write-Host "No domain MFA policy found — cannot enable MFA for '$UserUID'."; return $false }
            $body.mfaPolicyId = $policyId
        }
        else {
            $body.mfaPolicyId = $null
        }
    }

    # Other non-string fields
    if ($PSBoundParameters.ContainsKey('MustChangePassword')) { $body.mustChangePassword = [bool]$MustChangePassword }

    # The single-user GET expands read-only relations and computed fields that the
    # PUT schema rejects (causes a 400). Drop them before resubmitting.
    $readOnlyFields = @('vcc','security','links','idp','okta','useTags','emailVerified','language')
    foreach ($f in $readOnlyFields) {
        if ($body.ContainsKey($f)) { $body.Remove($f) }
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "User '$UserUID' updated successfully." } else { Write-Host "Failed to update user '$UserUID'."; return $false }
}