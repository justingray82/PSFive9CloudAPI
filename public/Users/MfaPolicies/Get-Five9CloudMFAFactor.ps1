# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMFAFactor
# Category: MFAFactors
# CONSOLIDATED VERSION - Combines Get-Five9CloudMFAFactor, Get-Five9CloudMFAFactorList

function Get-Five9CloudMFAFactor {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Single MFA factor
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$FactorId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudMFAFactor
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/mfa/factors/$FactorId"
        }
        
        'List' {
            # Original: Get-Five9CloudMFAFactorList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/mfa/factors"
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve MFA factor(s): $_"
    }
}
