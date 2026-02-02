# Five9Cloud PowerShell Module
# Function: Unregister-Five9CloudSmsFactor
# Category: UserSettings

function Unregister-Five9CloudSmsFactor {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$EnrolledFactorId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-factors/sms/$EnrolledFactorId:un-enroll"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to unenroll SMS factor: $_"
    }
}
