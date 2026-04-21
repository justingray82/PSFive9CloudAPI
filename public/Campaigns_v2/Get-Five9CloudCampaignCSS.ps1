function Get-Five9CloudCampaignCSS {
    param([string]$CampaignId, [string]$CampaignName, [switch]$Default)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $path = if ($Default) { 'default' } else { 'current' }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/css/$path"
}
