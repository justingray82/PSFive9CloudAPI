# Five9Cloud PowerShell Module
# Function: Enable-Five9CloudEmailFactor
# Category: UserSettings

function Enable-Five9CloudEmailFactor {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$EnrolledFactorId,
        [string]$PassCode
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-factors/email/$EnrolledFactorId:activate"
    
    $body = @{}
    if ($PassCode) { $body['passCode'] = $PassCode }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to activate email factor: $_"
    }
}
