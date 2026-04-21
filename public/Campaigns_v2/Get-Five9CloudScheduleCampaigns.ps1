function Get-Five9CloudScheduleCampaigns {
    param([string]$ScheduleId, [string]$ScheduleName,
          [string]$Fields, [string]$Sort, [long]$Offset, [long]$Limit,
          [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)
    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }

    $q = @{}
    if ($Fields)     { $q.fields     = $Fields }
    if ($Sort)       { $q.sort       = $Sort }
    if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit'))  { $q.limit  = $Limit }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId/campaigns" $q)
}
