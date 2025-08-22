# Five9Cloud PowerShell Module
# Function: Update-Five9CloudFactorInMFAPolicy
# Category: MfaPolicies

function Update-Five9CloudFactorInMFAPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$MfaPolicyId,
        [Parameter(Mandatory = $true)][string]$FactorId,
        [string]$Enrollment
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/mfa/policy/$MfaPolicyId/factor/$FactorId"
    
    $body = @{}
    if ($Enrollment) { $body['enrollment'] = $Enrollment }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update factor in MFA policy: $_"
    }
}
