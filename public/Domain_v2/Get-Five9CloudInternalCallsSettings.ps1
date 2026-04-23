function Get-Five9CloudInternalCallsSettings {
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/internal-calls-settings"
}
