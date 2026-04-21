function Reset-Five9CloudCampaignDialingListPositions {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($CampaignId):reset-dialing-list-positions" -Method Put
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' dialing list positions reset successfully." } else { Write-Host "Failed to reset dialing list positions for campaign '$CampaignName'."; return $false }
}
