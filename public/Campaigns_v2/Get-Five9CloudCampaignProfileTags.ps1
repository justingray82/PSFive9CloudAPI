function Get-Five9CloudCampaignProfileTags {
    param([string]$ProfileId, [string]$ProfileName,
          [string]$Sort, [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }

    $q = @{}
    if ($Sort)       { $q.sort       = $Sort }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/tags" $q)
}
