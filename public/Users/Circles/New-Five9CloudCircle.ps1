function New-Five9CloudCircle {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$Description,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('ACTIVE', 'INACTIVE')]
        [string]$Status = 'ACTIVE'
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/circles/v1/domains/$($global:Five9CloudToken.DomainId)/circles"
    
    # Build the request body
    $body = @{
        name = $Name
        description = $Description
        status = $Status
    }
    
    # Remove null/empty values
    $body = $body.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { @{$_.Key = $_.Value} }
    $body = $body | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method POST -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to create circle: $_"
    }
}