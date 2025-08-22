# Five9Cloud PowerShell Module
# Function: Update-Five9CloudSpeedDial
# Category: SpeedDials

function Update-Five9CloudSpeedDial {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$SpeedDialId,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$DialedNumber,
        [string]$Description,
        [bool]$EmergencyNumber
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/speed-dials/$SpeedDialId"
    
    $body = @{
        code = $Code
        dialedNumber = $DialedNumber
    }
    if ($Description) { $body['description'] = $Description }
    if ($PSBoundParameters.ContainsKey('EmergencyNumber')) { $body['emergencyNumber'] = $EmergencyNumber }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update speed dial: $_"
    }
}
