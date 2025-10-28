function Remove-Five9CloudVerintSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserUID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$userName,
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'call-recording',
            'call-recording.quality-monitoring',
            'call-recording.quality-monitoring.analytics-driven-quality',
            'call-recording.speech-analytics',
            'workforce-management',
            'performance-management',
            'call-recording.advanced-desktop-analytics'
        )]
        [string[]]$Packages
    )
    
    if (-not (Test-Five9CloudConnection)) { return }

    # If userName is provided, resolve it to userUID
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving user name '$userName' to userUID..."
        
        try {
            $userLookup = Get-Five9CloudUser -Filter "username=='$($userName)'" -Fields "id,userUID"
            if ($userLookup.resultsCount -gt 0) {
                $UserUID = $userLookup.entities[0].userUID
                Write-Verbose "Found user with ID: $userName"
            }
        } catch {
            Write-Verbose "No user found with name '$userName'"
        }
        
        # If not found, throw error
        if (-not $UserUID) {
            Write-Error "User with name '$userName' not found."
            return
        }
    }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/verint-settings"

    # Get current packages
    Write-Verbose "Resolving user name '$userName' to userUID..."
        
    try {
        $packageLookup = Get-Five9CloudVerintSettings -UserUID "$($UserUID)"
        $filteredPackages = $packageLookup.packages.Where({ $_ -notin $Packages })
    } catch {
        Write-Verbose "Package not found with '$userUID'"
    }

    $body = @{
        packages = $filteredPackages
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to remove Verint settings: $_"
    }
}