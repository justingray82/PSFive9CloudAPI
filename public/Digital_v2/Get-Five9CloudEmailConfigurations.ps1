function Get-Five9CloudEmailConfigurations {
    param([string]$EmailConfigurationId)

    if ($EmailConfigurationId) {
        Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)/email-configurations/$EmailConfigurationId"
    } else {
        Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "digital-config-svc/v1/domains/$($global:Five9.DomainId)/email-configurations" @{ pageLimit = 100 }) -ResultProperty 'items'
    }
}