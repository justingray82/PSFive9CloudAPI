function Get-Five9CloudAniGroups {
    param([string]$Fields, [string]$Sort, [ValidateSet('ASC','DESC')][string]$Order,
          [long]$Offset, [long]$Limit,
          [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)

    $q = @{}
    if ($Fields)     { $q.fields     = $Fields }
    if ($Sort)       { $q.sort       = $Sort }
    if ($Order)      { $q.order      = $Order }
    if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit'))  { $q.limit  = $Limit }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "routes/v1/domains/$($global:Five9.DomainId)/ani-groups" $q)
}