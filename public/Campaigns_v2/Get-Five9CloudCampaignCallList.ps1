function Get-Five9CloudCampaignCallList {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][string]$CallListId
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/lists/$CallListId"
}
