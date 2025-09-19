# Five9Cloud PowerShell Module
# Function: Add-Five9CloudSpeedDial
# Category: SpeedDials

function Add-Five9CloudSpeedDial {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$DialedNumber,
        [string]$Description,
        [bool]$EmergencyNumber
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/speed-dials"
    
    $body = @{
        code = $Code
        dialedNumber = $DialedNumber
    }
    if ($Description) { $body['description'] = $Description }
    if ($PSBoundParameters.ContainsKey('EmergencyNumber')) { $body['emergencyNumber'] = $EmergencyNumber }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create speed dial: $_"
    }
}
