function Remove-Five9CloudCampaign {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId" -Method Delete
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' deleted successfully." } else { Write-Host "Failed to delete campaign '$CampaignName'."; return $false }
}
