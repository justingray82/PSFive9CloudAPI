function Get-Five9CloudCampaignDetails {
    param([string]$CampaignId, [string]$CampaignName)
    $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName; if (-not $campaignId) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId"
}