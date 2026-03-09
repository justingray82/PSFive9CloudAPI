function Get-Five9CloudConnectors {
    param([string]$ConnectorName)

    if ($connectorName) {
        Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "events-subscription/v1/domains/$($global:Five9.DomainId)/connectors?name=$connectorName")
    } else {
        Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "events-subscription/v1/domains/$($global:Five9.DomainId)/connectors")
    }

}