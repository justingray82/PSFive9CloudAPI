# Five9Cloud PowerShell Module
# Function: Get-Five9CloudPasswordPolicy
# Category: PasswordPolicies
# CONSOLIDATED VERSION - Combines Get-Five9CloudPasswordPolicy, Get-Five9CloudMyPasswordPolicy

function Get-Five9CloudPasswordPolicy {
    [CmdletBinding(DefaultParameterSetName = 'Domain')]
    param (
        
        # Get current user's password policy
        [Parameter(Mandatory = $true, ParameterSetName = 'CurrentUser')]
        [switch]$CurrentUser
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Domain' {
            # Original: Get-Five9CloudPasswordPolicy
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/password-policy"
        }
        
        'CurrentUser' {
            # Original: Get-Five9CloudMyPasswordPolicy
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-password-policy"
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve password policy: $_"
    }
}
