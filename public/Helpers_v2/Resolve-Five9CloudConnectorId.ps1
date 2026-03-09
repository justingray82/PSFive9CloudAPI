function Resolve-Five9CloudConnectorId ([string]$ConnectorName) {
    $result = Get-Five9CloudConnectors -ConnectorName "$ConnectorName"
    if ($result.items.Count -gt 0) { return $result.items.connectorId }
    Write-Error "Connector '$ConnectorName' not found."; return $null
}