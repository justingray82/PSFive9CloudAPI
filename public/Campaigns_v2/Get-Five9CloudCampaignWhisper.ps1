function Get-Five9CloudCampaignWhisper {
    param([string]$CampaignId, [string]$CampaignName)
    $id = Resolve-Five9CloudCampaignId $CampaignId $CampaignName; if (-not $id) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/prompts/v1/domains/$($global:Five9.DomainId)/campaigns/$id/connected"
}