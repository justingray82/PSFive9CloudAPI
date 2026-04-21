function Remove-Five9CloudCampaignTag {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$TagId)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/tags/$TagId" -Method Delete
    if ($result -ne $false) { Write-Host "Tag $TagId removed from campaign '$CampaignName'." } else { Write-Host "Failed to remove tag $TagId from campaign '$CampaignName'."; return $false }
}
