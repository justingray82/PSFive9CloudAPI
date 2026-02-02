function Get-Five9CloudCircles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Filter,
        
        [Parameter(Mandatory = $false)]
        [int]$PageSize,
        
        [Parameter(Mandatory = $false)]
        [int]$PageNumber
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/circles/v1/domains/$($global:Five9CloudToken.DomainId)/circles"
    
    # Build query parameters if provided
    $queryParams = @()
    if ($Filter) { $queryParams += "filter=$Filter" }
    if ($PageSize) { $queryParams += "pageSize=$PageSize" }
    if ($PageNumber) { $queryParams += "pageNumber=$PageNumber" }
    
    if ($queryParams.Count -gt 0) {
        $uri += "?" + ($queryParams -join "&")
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "No circles found for domain $($global:Five9CloudToken.DomainId)"
        } else {
            Write-Error "Failed to get circles: $_"
        }
    }
}