# Five9Cloud PowerShell Module
# Function: Reset-Five9CloudPasswordPolicy
# Category: PasswordPolicies

function Reset-Five9CloudPasswordPolicy {

    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/password-policy:reset"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to reset password policy: $_"
    }
}
