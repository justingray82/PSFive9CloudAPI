# Five9Cloud PowerShell Module
# Function: Add-Five9CloudApiUser
# Category: UserManagement

function Add-Five9CloudApiUser {
    [CmdletBinding()]
    param (

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
        [string]$CostCenter
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/api-user"
    
    $body = @{}
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
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create API user: $_"
    }
}
