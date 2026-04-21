function Set-Five9CloudInternalCallsSettings {
    param([Parameter(Mandatory)][hashtable]$Settings)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/internal-calls-settings" -Method Put -Body $Settings
    if ($result -ne $false) { Write-Host "Internal calls settings updated successfully."; return $result } else { Write-Host "Failed to update internal calls settings."; return $false }
}
