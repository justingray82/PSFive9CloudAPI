function Remove-Five9CloudUserVerintSettings {
    param([string]$UserUID, [string]$Username)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/verint-settings" -Method Delete
    if ($result -ne $false) { Write-Host "Verint settings for $UserUID removed successfully." } else { Write-Host "Unable to remove Verint settings for $UserUID." }
}