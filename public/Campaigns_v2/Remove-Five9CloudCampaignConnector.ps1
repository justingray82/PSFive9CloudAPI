function Remove-Five9CloudCampaignConnector {
    param([string]$CampaignId, [string]$CampaignName, [string]$ConnectorName, [string]$ConnectorId)
    if (-not $campaignId) { $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $campaignId) { return }
    if (-not $connectorId) { $connectorId = Resolve-Five9CloudConnectorId $ConnectorName } ; if (-not $connectorId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId/connectors/$connectorId" -Method DELETE
    if ($result -ne $false) { Write-Host "$ConnectorName removed from $CampaignName"} else { Write-Host "Failed to remove $ConnectorName from $CampaignName"; return }
}