function Set-Five9CloudCampaignDNIS {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$DNIS)
    if (-not $campaignId) { $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $campaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId/numbers/$DNIS" -Method Post
    if ($result -ne $false) { Write-Host "$DNIS assigned to $CampaignName"} else { Write-Host "Failed to assign $DNIS to $CampaignName"; return $false }
}