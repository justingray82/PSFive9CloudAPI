function Get-Five9CloudEmailNotificationSettings {
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/email-notification-settings"
}
