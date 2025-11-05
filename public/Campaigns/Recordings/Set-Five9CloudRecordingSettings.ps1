function Set-Five9CloudRecordingSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [bool]$CRMEnabled
    )
    
    if (-not (Test-Five9CloudConnection -AuthType CloudAuth -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/recordings/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$($CampaignId)/recording-settings"
    
    $headers = @{
        Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        'Content-Type' = 'application/json'
    }
    
    $body = @{}
    
    if ($CRMEnabled -ne $null) { $body['recordingSettingsEnabled'] = $CRMEnabled }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update inbound campaign: $_"
    }
}