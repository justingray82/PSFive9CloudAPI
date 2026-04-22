function Set-Five9CloudCampaignDialingConfiguration {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][bool]$OutOfNumbersAlert,
        [string]$MaxQueueTime,
        [bool]$UseTelemarketingMaxQueueTime1sec,
        [bool]$EnableTrainingMode
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    # Seed from current state so PUT doesn't clobber unspecified fields
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/configuration"
    if (-not $current) { return }
    $body = $current

    $body.outOfNumbersAlert = $OutOfNumbersAlert
    if ($PSBoundParameters.ContainsKey('MaxQueueTime'))                      { $body.maxQueueTime                      = $MaxQueueTime }
    if ($PSBoundParameters.ContainsKey('UseTelemarketingMaxQueueTime1sec'))  { $body.useTelemarketingMaxQueueTime1sec  = $UseTelemarketingMaxQueueTime1sec }
    if ($PSBoundParameters.ContainsKey('EnableTrainingMode'))                { $body.enableTrainingMode                = $EnableTrainingMode }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/configuration" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing configuration updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update dialing configuration for campaign '$CampaignName'."; return $false }
}
