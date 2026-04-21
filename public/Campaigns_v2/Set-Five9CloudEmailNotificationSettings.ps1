function Set-Five9CloudEmailNotificationSettings {
    param([Parameter(Mandatory)][hashtable]$Settings)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/email-notification-settings" -Method Put -Body $Settings
    if ($result -ne $false) { Write-Host "Email notification settings updated successfully."; return $result } else { Write-Host "Failed to update email notification settings."; return $false }
}
