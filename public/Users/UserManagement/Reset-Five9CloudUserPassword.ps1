# Five9Cloud PowerShell Module
# Function: Reset-Five9CloudUserPassword
# Category: UserManagement

function Reset-Five9CloudUserPassword {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)][bool]$SendEmail
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/password:reset"
    
    $body = @{
        sendEmail = $SendEmail
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to reset user password: $_"
    }
}
