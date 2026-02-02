# Five9Cloud PowerShell Module
# Function: Start-Five9CloudUserEmailVerification
# Category: EmailVerification

function Start-Five9CloudUserEmailVerification {
    [CmdletBinding()]
    param (
[string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/email-verification:initiate"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to initiate user email verification: $_"
    }
}

