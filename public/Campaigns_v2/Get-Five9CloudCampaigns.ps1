function Get-Five9CloudCampaigns {
    param([string]$Fields, [string]$Sort, [long]$Offset, [long]$Limit,
          [string]$PageCursor, [int]$PageLimit = 1000, [string]$Filter)

    $q = @{}
    if ($Fields)     { $q.fields     = $Fields }
    if ($Sort)       { $q.sort       = $Sort }
    if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit'))  { $q.limit  = $Limit }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/campaigns" $q)
}