# Five9Cloud PowerShell Module
# Function: Set-Five9CloudDomainEmailVerification
# Category: EmailVerification
# CONSOLIDATED from Enable-Five9CloudDomainEmailVerification and Disable-Five9CloudDomainEmailVerification

function Set-Five9CloudDomainEmailVerification {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)]
        [bool]$Enable
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Determine the action based on Enable parameter
    $action = if ($Enable) { ':enable' } else { ':disable' }
    
    # Extract the base URI from the original functions
    $baseUri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId"
        $uri = "$baseUri/email-verification-feature$action"    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        $actionText = if ($Enable) { 'enable' } else { 'disable' }
        Write-Error "Failed to ${$actionText}: $_"
    }
}
