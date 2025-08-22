# Five9Cloud PowerShell Module
# Function: Register-Five9CloudEmailFactor
# Category: UserSettings

function Register-Five9CloudEmailFactor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Email
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/my-factors/email:enroll"
    
    $body = @{}
    if ($Email) { $body['email'] = $Email }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to enroll email factor: $_"
    }
}
