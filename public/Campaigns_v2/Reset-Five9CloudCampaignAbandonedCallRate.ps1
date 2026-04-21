function Reset-Five9CloudCampaignAbandonedCallRate {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($CampaignId):reset-abandoned-call-rate" -Method Put
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' abandoned call rate reset successfully." } else { Write-Host "Failed to reset abandoned call rate for campaign '$CampaignName'."; return $false }
}
