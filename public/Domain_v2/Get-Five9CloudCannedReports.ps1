function Get-Five9CloudCannedReports {
    param([string]$PageCursor, [int]$PageLimit = 100)

    $q = @{}
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "report-ui/v1/domains/$($global:Five9.DomainId)/canned-reports" $q)
}