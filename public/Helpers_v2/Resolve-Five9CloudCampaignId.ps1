function Resolve-Five9CloudCampaignId ([string]$CampaignId, [string]$CampaignName) {
    if ($CampaignId) { return $CampaignId }
    $result = Get-Five9CloudCampaignList -Filter "name=='$CampaignName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.campaignId }
    Write-Error "Campaign '$CampaignName' not found."; return $null
}