function Get-Five9CloudServiceAccounts {
    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "digital-config-svc/v1/domains/$($global:Five9.DomainId)/service-accounts" @{ pageLimit = 100 }) -ResultProperty 'items'
}