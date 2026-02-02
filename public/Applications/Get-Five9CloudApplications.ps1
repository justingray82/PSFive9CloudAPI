function Get-Five9CloudApplications {
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
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/applications"
    
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
            Write-Host "No Applications found for domain $($global:Five9CloudToken.DomainId)"
        } else {
            Write-Error "Failed to get Applications: $_"
        }
    }
}