function Get-Five9CloudDomainVerintPackages {
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9.DomainId)/verint-packages"
    if ($result -and $result -isnot [bool]) { $result.items }
}