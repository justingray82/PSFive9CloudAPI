function Get-Five9CloudDigitalAssistance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
  
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9CloudToken.DomainId)/assistances?excludeResponseBody=true"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
        
        if ($Name) {
            return $response.assistances | Where-Object { $_.name -eq $Name }
        } else {
            return $response.assistances
        }
    } catch {
        Write-Error "Failed to get Digital Assistance: $_"
    }
}