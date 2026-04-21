function Add-Five9CloudCampaignTag {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$TagId)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/tags/$TagId" -Method Post
    if ($result -ne $false) { Write-Host "Tag $TagId added to campaign '$CampaignName'." } else { Write-Host "Failed to add tag $TagId to campaign '$CampaignName'."; return $false }
}
