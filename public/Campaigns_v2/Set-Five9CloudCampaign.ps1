function Set-Five9CloudCampaign {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][hashtable]$CampaignDetails
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId" -Method Put -Body $CampaignDetails
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' updated successfully."; return $result } else { Write-Host "Failed to update campaign '$CampaignName'."; return $false }
}
