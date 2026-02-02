# Five9Cloud PowerShell Module
# Function: Get-Five9CloudScope
# Category: Scopes
# CONSOLIDATED VERSION - Combines Get-Five9CloudScopes, Get-Five9CloudScopesForDomain

function Get-Five9CloudScope {
    [CmdletBinding(DefaultParameterSetName = 'General')]
    param (


        
        # Domain-specific scopes
        [Parameter(Mandatory = $true, ParameterSetName = 'Domain')]
        [switch]$ForDomain,
        
        # General scopes parameter
        [Parameter(Mandatory = $false, ParameterSetName = 'General')]
        [string]$Scopes,
        
        # Domain filter parameter
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string]$Filter
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'General' {
            # Original: Get-Five9CloudScopes
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/scopes"
            
            if ($Scopes) {
                $uri += "?scopes=$Scopes"
            }
        }
        
        'Domain' {
            # Original: Get-Five9CloudScopesForDomain
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/scopes"
            
            if ($Filter) {
                $uri += "?filter=$Filter"
            }
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve scope(s): $_"
    }
}
