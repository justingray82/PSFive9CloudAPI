# Five9Cloud PowerShell Module
# Function: Confirm-Five9CloudEmailToken
# Category: EmailVerification

function Confirm-Five9CloudEmailToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Token
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/email-verification:verify"
    
    $body = @{
        token = $Token
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to verify email token: $_"
    }
}
