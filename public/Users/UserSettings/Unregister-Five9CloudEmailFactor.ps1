# Five9Cloud PowerShell Module
# Function: Unregister-Five9CloudEmailFactor
# Category: UserSettings

function Unregister-Five9CloudEmailFactor {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$EnrolledFactorId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-factors/email/$EnrolledFactorId:un-enroll"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to unenroll email factor: $_"
    }
}
