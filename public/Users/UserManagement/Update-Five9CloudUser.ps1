# Five9Cloud PowerShell Module
# Function: Update-Five9CloudUser
# Category: UserManagement

function Update-Five9CloudUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [string]$Username,
        [string]$Status,
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
        [datetime]$StartDate,
        [string]$Extension,
        [string]$IndiaTelecomCircleId,
        [string]$EmployeeId,
        [string]$CostCenter,
        [string]$IdpPolicyId,
        [string]$IdpFederationId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID"
    
    $body = @{
        userUID = $UserUID
    }
    
    if ($Username) { $body['username'] = $Username }
    if ($Status) { $body['status'] = $Status }
    if ($FirstName) { $body['firstName'] = $FirstName }
    if ($LastName) { $body['lastName'] = $LastName }
    if ($Email) { $body['email'] = $Email }
    if ($Initials) { $body['initials'] = $Initials }
    if ($MobileNumber) { $body['mobileNumber'] = $MobileNumber }
    if ($WorkNumber) { $body['workNumber'] = $WorkNumber }
    if ($HomeNumber) { $body['homeNumber'] = $HomeNumber }
    if ($Timezone) { $body['timezone'] = $Timezone }
    if ($Locale) { $body['locale'] = $Locale }
    if ($MfaPolicyId) { $body['mfaPolicyId'] = $MfaPolicyId }
    if ($StartDate) { $body['startDate'] = $StartDate.ToString('yyyy-MM-dd') }
    if ($Extension) { $body['extension'] = $Extension }
    if ($IndiaTelecomCircleId) { $body['indiaTelecomCircleId'] = $IndiaTelecomCircleId }
    if ($EmployeeId) { $body['employeeId'] = $EmployeeId }
    if ($CostCenter) { $body['costCenter'] = $CostCenter }
    if ($IdpPolicyId) { $body['idpPolicyId'] = $IdpPolicyId }
    if ($IdpFederationId) { $body['idpFederationId'] = $IdpFederationId }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update user: $_"
    }
}
