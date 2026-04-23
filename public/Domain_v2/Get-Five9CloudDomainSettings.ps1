function Get-Five9CloudDomainSettings {
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/domain-settings"
}
