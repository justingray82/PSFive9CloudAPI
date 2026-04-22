function Set-Five9CloudCampaignDialingSettings {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][ValidateSet('predictive','progressive','preview','power','auto')][string]$DialingMode,
        [hashtable]$DialingModeSettings
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $body = @{ dialingMode = $DialingMode }
    if ($DialingModeSettings) { $body[$DialingMode] = $DialingModeSettings }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/dialing-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing settings updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update dialing settings for campaign '$CampaignName'."; return $false }
}
