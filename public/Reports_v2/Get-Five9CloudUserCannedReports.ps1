function Get-Five9CloudUserCannedReports {
    param([string]$Username, [string]$UserUID, [string]$PageCursor, [int]$PageLimit = 100)

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    $q = @{}
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "report-ui/v1/domains/$($global:Five9.DomainId)/users/$UserUID/canned-reports" $q)
}