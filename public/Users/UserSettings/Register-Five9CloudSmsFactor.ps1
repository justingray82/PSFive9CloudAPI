# Five9Cloud PowerShell Module
# Function: Register-Five9CloudSmsFactor
# Category: UserSettings

function Register-Five9CloudSmsFactor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$PhoneNumber
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/my-factors/sms:enroll"
    
    $body = @{}
    if ($PhoneNumber) { $body['phoneNumber'] = $PhoneNumber }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to enroll SMS factor: $_"
    }
}
