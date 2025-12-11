function Get-Five9CloudReasonCodeSets {
    [CmdletBinding()]
    param (
        [string]$Filter
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Original: Get-Five9CloudVerintSettings
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9CloudToken.DomainId)/reason-code-sets"
    
    if ($Filter) {
        $uri = "$($global:Five9CloudToken.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9CloudToken.DomainId)/reason-code-sets?filter=$($Filter)"
    } else {
        $uri = "$($global:Five9CloudToken.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9CloudToken.DomainId)/reason-code-sets"
    }


    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        # Handle 404 specifically - this means no Verint settings exist for the user
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "No Reason Code Sets found"
        } else {
            Write-Error "Failed to get Reason Code Sets: $_"
        }
    }
}