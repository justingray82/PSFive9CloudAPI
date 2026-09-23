function Add-Five9CloudCannedReportToUser {
    param(
        [string]$Username,
        [string]$UserUID,
        [Parameter(Mandatory = $true)][string[]]$Report,
        [string]$ReportFolder
    )

    if (-not $Username -and -not $UserUID) { Write-Host "Supply -Username or -UserUID." -ForegroundColor Red; return }
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    # Pull the domain catalog once, then resolve each report against it
    $catalog = (Get-Five9CloudCannedReports).items
    if (-not $catalog) { Write-Host "No canned reports returned for this domain." -ForegroundColor Red; return }

    $label = if ($Username) { $Username } else { $UserUID }
    $uri   = "$($global:Five9.ApiBaseUrl)/report-ui/v1/domains/$($global:Five9.DomainId)/users/$UserUID/canned-reports"

    foreach ($r in $Report) {
        $item = Resolve-Five9CloudCannedReport $r $ReportFolder $catalog ; if (-not $item) { continue }

        # The POST takes the complete catalog record, one report per call
        $body = @{
            cannedReportId = $item.cannedReportId
            name           = $item.name
            description    = $item.description
            reportFolder   = if ($item.reportFolder) {
                                 @{ id = $item.reportFolder.id; name = $item.reportFolder.name; uri = $item.reportFolder.uri }
                             } else { $null }
        }

        $result = Invoke-Five9CloudApi $uri -Method Post -Body $body
        if ($result -ne $false) { Write-Host "Canned report '$($item.name)' added to user $label" }
        else { Write-Host "Failed to add canned report '$($item.name)' to $label" }
    }
}