function Get-Five9CloudConfigEvents {
    param([string]$Sort, 
          [datetime]$StartDate = (Get-Date).AddDays(-1),
          [datetime]$EndDate   = (Get-Date),
          [string]$TimeZoneOffset = '-04:00')

    if ($EndDate -lt $StartDate) { Write-Error "End Date can not be before Start Date."; return $null }

    $start = $StartDate.ToString("yyyy-MM-ddTHH:mm:ss") + $TimeZoneOffset
    $end   = $EndDate.ToString("yyyy-MM-ddTHH:mm:ss")   + $TimeZoneOffset

    $Filter = "timestamp>=$start;timestamp<=$end"

    $q = @{}
    if ($Sort)       { $q.sort       = $Sort }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "config-audit/v1/domains/$($global:Five9.DomainId)/logs" $q)
}