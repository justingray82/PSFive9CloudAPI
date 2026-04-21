function Get-Five9CloudCampaignNumbers {
    param([string]$CampaignId, [string]$CampaignName,
          [string]$Fields, [string]$Sort, [long]$Offset, [long]$Limit,
          [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $q = @{}
    if ($Fields)     { $q.fields     = $Fields }
    if ($Sort)       { $q.sort       = $Sort }
    if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit'))  { $q.limit  = $Limit }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/numbers" $q)
}
