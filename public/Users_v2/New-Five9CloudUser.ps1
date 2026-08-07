function New-Five9CloudUser {
    [CmdletBinding(DefaultParameterSetName = 'Password')]
    param(
        [Parameter(Mandatory)][string]$Username,
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,

        [ValidateSet('ACTIVE','INACTIVE')][string]$Status = 'ACTIVE',

        # SSO / auto-migration set — federation ID required, plus a policy (name or ID)
        [Parameter(Mandatory, ParameterSetName = 'SSO')][string]$FederationID,
        [Parameter(ParameterSetName = 'SSO')][string]$IdPPolicy,
        [Parameter(ParameterSetName = 'SSO')][string]$IdpPolicyId,

        # Optional profile fields (sent as empty strings when unset, matching the API)
        [string]$Extension    = '',
        [string]$StartDate    = '',
        [string]$HomeNumber   = '',
        [string]$Locale       = '',
        [string]$MobileNumber = '',
        [string]$Timezone     = '',
        [string]$WorkNumber   = ''
    )

    $sso = $PSCmdlet.ParameterSetName -eq 'SSO'

    $body = @{
        autoMigration = $sso
        status        = $Status
        email         = $Email
        extension     = $Extension
        startDate     = $StartDate
        lastName      = $LastName
        firstName     = $FirstName
        homeNumber    = $HomeNumber
        locale        = $Locale
        mobileNumber  = $MobileNumber
        timezone      = $Timezone
        username      = $Username
        workNumber    = $WorkNumber
    }

    if ($sso) {
        if (-not $IdpPolicyId -and -not $IdPPolicy) { Write-Error "SSO users require -IdPPolicy (name) or -IdpPolicyId."; return }
        if (-not $IdpPolicyId) { $IdpPolicyId = Resolve-Five9CloudIdpPolicyID $IdPPolicy } ; if (-not $IdpPolicyId) { return }
        $body.idpPolicyId     = $IdpPolicyId
        $body.idpFederationId = $FederationID
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "User '$Username' created successfully ($($result.userUID))." } else { Write-Host "Failed to create user '$Username'." }
}