function Get-Five9CloudNumberCredits {
    # Returns the domain's number credits as a single object, e.g.
    # DID_PROCURED = 5, DID_AVAILABLE = 2, TFN_PROCURED = 0, TFN_AVAILABLE = 0
    # *_AVAILABLE is the number of additional numbers that can still be claimed.

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/numbers-svc/v1/domains/$($global:Five9.DomainId)/number-credits"
    if ($result -eq $false -or -not $result) { Write-Error "Failed to retrieve number credits."; return }

    $credits = [ordered]@{}
    foreach ($item in $result.items) { $credits[$item.creditType] = [int]$item.value }
    [PSCustomObject]$credits
}