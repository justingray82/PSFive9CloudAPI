function Remove-Five9CloudCampaignSurvey {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $campaignId) { $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $campaignId) { return }
    $campaignDetails = Get-Five9CloudCampaigns -Filter "campaignId=='$campaignId'"
    $newDetails = $campaignDetails.items[0]
    $newDetails.PSObject.Properties.Remove('survey')
    $body = $newDetails
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($campaignId)" -Method Put -Body $body
    if ($result) { Write-Host "$Survey removed on $CampaignName"} else { Write-Host "Unable to remove survey for $CampaignName"; return $false }
}