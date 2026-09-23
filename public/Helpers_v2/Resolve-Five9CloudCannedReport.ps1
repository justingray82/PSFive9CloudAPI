function Resolve-Five9CloudCannedReport ([string]$Report, [string]$ReportFolder, $Catalog) {
    # Returns the full catalog record, not just an id - the POST body requires
    # cannedReportId, name, description and reportFolder together.
    # -Catalog lets a caller pass a pre-fetched list so a loop only pulls the catalog once.
    if (-not $Catalog) { $Catalog = (Get-Five9CloudCannedReports).items }
    if (-not $Catalog) { Write-Host "No canned reports returned for this domain." -ForegroundColor Red; return $null }

    $match = @($Catalog | Where-Object { $_.cannedReportId -eq $Report -or $_.name -eq $Report })
    if ($ReportFolder) { $match = @($match | Where-Object { $_.reportFolder.name -eq $ReportFolder }) }

    if ($match.Count -eq 0) { Write-Host "Canned report '$Report' not found." -ForegroundColor Red; return $null }
    if ($match.Count -gt 1) {
        Write-Host "Canned report '$Report' matched $($match.Count) reports in folders: $(($match.reportFolder.name | Select-Object -Unique) -join ', '). Use -ReportFolder or pass the cannedReportId." -ForegroundColor Red
        return $null
    }

    return $match[0]
}