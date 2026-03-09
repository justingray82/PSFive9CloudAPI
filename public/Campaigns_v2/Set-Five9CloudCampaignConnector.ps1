function Set-Five9CloudCampaignConnector {
    param([string]$CampaignId, [string]$CampaignName, [string]$ConnectorName, [string]$ConnectorId)
    if (-not $campaignId) { $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $campaignId) { return }
    if (-not $connectorId) { $connectorId = Resolve-Five9CloudConnectorId $ConnectorName } ; if (-not $connectorId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId/connectors/$connectorId" -Method Post
    if ($result) { Write-Host "$ConnectorName assigned to $CampaignName" } else { Write-Host "Failed to assign $ConnectorName to $CampaignName"; return $false }
}