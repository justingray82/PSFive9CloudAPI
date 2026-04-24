function Set-Five9CloudUserDetails {
    param(
        [string]$UserUID,
        [string]$Username,
        [ValidateSet('ACTIVE','INACTIVE')][string]$Status,
        [string]$FirstName,
        [string]$LastName,
        [string]$Email,
        [string]$Initials,
        [string]$MobileNumber,
        [string]$WorkNumber,
        [string]$HomeNumber,
        [string]$Timezone,
        [string]$Locale,
        [string]$MfaPolicyId,
        [string]$StartDate,
        [string]$Extension,
        [string]$IndiaTelecomCircleId,
        [string]$EmployeeId,
        [string]$CostCenter,
        [string]$DomainUsername,
        [string]$DomainName,
        [string]$VerintLoginName,
        [string]$VerintDomainName,
        [string]$NewUsername,
        [string]$IdpPolicyId,
        [string]$IdpFederationId,
        [string]$ScimPolicyId,
        [string]$UserPrincipalName,
        [bool]$MustChangePassword
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    $newDetails = @{}
    (Get-Five9CloudUserDetails -Filter "userUID=='$($UserUID)'").items[0].PSObject.Properties | ForEach-Object { $newDetails[$_.Name] = $_.Value }
    if (-not $newDetails.Count) { return }

    if ($Status)               { $newDetails['status']               = $Status }
    if ($FirstName)            { $newDetails['firstName']            = $FirstName }
    if ($LastName)             { $newDetails['lastName']             = $LastName }
    if ($Email)                { $newDetails['email']                = $Email }
    if ($Initials)             { $newDetails['initials']             = $Initials }
    if ($PSBoundParameters.ContainsKey('MobileNumber'))        { $newDetails['mobileNumber']         = $MobileNumber }
    if ($PSBoundParameters.ContainsKey('WorkNumber'))          { $newDetails['workNumber']           = $WorkNumber }
    if ($PSBoundParameters.ContainsKey('HomeNumber'))          { $newDetails['homeNumber']           = $HomeNumber }
    if ($Timezone)             { $newDetails['timezone']             = $Timezone }
    if ($PSBoundParameters.ContainsKey('Locale'))              { $newDetails['locale']               = $Locale }
    if ($PSBoundParameters.ContainsKey('MfaPolicyId'))         { $newDetails['mfaPolicyId']          = $MfaPolicyId }
    if ($StartDate)            { $newDetails['startDate']            = $StartDate }
    if ($Extension)            { $newDetails['extension']            = $Extension }
    if ($PSBoundParameters.ContainsKey('IndiaTelecomCircleId')){ $newDetails['indiaTelecomCircleId']  = $IndiaTelecomCircleId }
    if ($PSBoundParameters.ContainsKey('EmployeeId'))          { $newDetails['employeeId']           = $EmployeeId }
    if ($PSBoundParameters.ContainsKey('CostCenter'))          { $newDetails['costCenter']           = $CostCenter }
    if ($PSBoundParameters.ContainsKey('DomainUsername'))      { $newDetails['domainUsername']       = $DomainUsername }
    if ($PSBoundParameters.ContainsKey('DomainName'))          { $newDetails['domainName']           = $DomainName }
    if ($PSBoundParameters.ContainsKey('VerintLoginName'))     { $newDetails['verintLoginName']      = $VerintLoginName }
    if ($PSBoundParameters.ContainsKey('VerintDomainName'))    { $newDetails['verintDomainName']     = $VerintDomainName }
    if ($NewUsername)          { $newDetails['username']             = $NewUsername }
    if ($PSBoundParameters.ContainsKey('IdpPolicyId'))         { $newDetails['idpPolicyId']          = $IdpPolicyId }
    if ($PSBoundParameters.ContainsKey('IdpFederationId'))     { $newDetails['idpFederationId']      = $IdpFederationId }
    if ($PSBoundParameters.ContainsKey('ScimPolicyId'))        { $newDetails['scimPolicyId']         = $ScimPolicyId }
    if ($PSBoundParameters.ContainsKey('UserPrincipalName'))   { $newDetails['userPrincipalName']    = $UserPrincipalName }
    if ($PSBoundParameters.ContainsKey('MustChangePassword'))  { $newDetails['mustChangePassword']   = $MustChangePassword }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID" -Method Put -Body $newDetails
    if ($result -ne $false) { Write-Host "User info for $UserUID updated successfully." } else { Write-Host "Unable to update user info for $UserUID." }
}