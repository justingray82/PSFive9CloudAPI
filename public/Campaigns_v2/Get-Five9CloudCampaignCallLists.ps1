function Get-Five9CloudCampaignCallLists {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [string]$PageCursor,
        [int]$PageLimit = 100,
        [string]$CallListId
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $q = @{}
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($CallListId) { $q.callListId = $CallListId }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/lists" $q)
}
