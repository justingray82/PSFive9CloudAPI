function Get-Five9CloudSchedules {
    param([string]$Sort, [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)

    $q = @{}
    if ($Sort)       { $q.sort       = $Sort }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "campaigns/v1/domains/$($global:Five9.DomainId)/schedules" $q)
}
