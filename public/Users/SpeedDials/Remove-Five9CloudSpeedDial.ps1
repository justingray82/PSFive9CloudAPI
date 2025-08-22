# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudSpeedDial
# Category: SpeedDials

function Remove-Five9CloudSpeedDial {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$SpeedDialId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/speed-dials/$SpeedDialId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to delete speed dial: $_"
    }
}
