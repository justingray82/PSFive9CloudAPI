function Get-Five9CloudCampaignConnectors {
    param([string]$CampaignId, [string]$CampaignName,
          [string]$Sort, [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $q = @{}
    if ($Sort)       { $q.sort       = $Sort }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/connectors" $q)
}
