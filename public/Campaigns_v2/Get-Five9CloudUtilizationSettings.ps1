function Get-Five9CloudUtilizationSettings {
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/utilization-settings"
}
