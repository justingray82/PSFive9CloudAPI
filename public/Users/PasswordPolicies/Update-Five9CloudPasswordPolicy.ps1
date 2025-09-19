# Five9Cloud PowerShell Module
# Function: Update-Five9CloudPasswordPolicy
# Category: PasswordPolicies

function Update-Five9CloudPasswordPolicy {
    [CmdletBinding()]
    param (

        [hashtable]$Complexity,
        [hashtable]$Lockout,
        [hashtable]$Age
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/password-policy"
    
    $body = @{}
    if ($Complexity) { $body['complexity'] = $Complexity }
    if ($Lockout) { $body['lockout'] = $Lockout }
    if ($Age) { $body['age'] = $Age }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update password policy: $_"
    }
}
