function Get-Five9CloudUserVerintDetails {
    param([string]$UserUID, [string]$Username)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username} ; if (-not $UserUID) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/verint-settings"
}

