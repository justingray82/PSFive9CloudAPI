function Resolve-Five9CloudConnectorId ([string]$ConnectorName) {
    $result = Get-Five9CloudConnectors -ConnectorName "$ConnectorName"
    if ($result.items.Count -gt 0) { return $result.items.connectorId }
    Write-Host "Connector '$ConnectorName' not found." -ForegroundColor Red; return $null
}