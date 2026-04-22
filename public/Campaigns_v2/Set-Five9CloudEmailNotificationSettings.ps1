function Set-Five9CloudEmailNotificationSettings {
    param(
        [string[]]$LineUtilizationNotificationEmails,
        [string[]]$MaintenanceNotificationEmails,
        [string[]]$PstnLoginNotificationEmails
    )
    $body = @{}
    if ($LineUtilizationNotificationEmails) { $body.lineUtilizationNotificationEmails = $LineUtilizationNotificationEmails }
    if ($MaintenanceNotificationEmails)     { $body.maintenanceNotificationEmails      = $MaintenanceNotificationEmails }
    if ($PstnLoginNotificationEmails)       { $body.pstnLoginNotificationEmails        = $PstnLoginNotificationEmails }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/email-notification-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Email notification settings updated successfully."; return $result } else { Write-Host "Failed to update email notification settings."; return $false }
}
