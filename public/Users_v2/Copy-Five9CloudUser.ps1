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
        [switch]$MustChangePassword
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

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

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$($UserUID):duplicate" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "User '$Username' duplicated successfully as '$NewUsername'." } else { Write-Host "Failed to duplicate user '$Username'." }
}