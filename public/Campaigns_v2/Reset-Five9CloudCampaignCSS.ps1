function Reset-Five9CloudCampaignCSS {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/css/current:restore-default" -Method Post
    if ($result -ne $false) { Write-Host "CSS restored to default for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to restore default CSS for campaign '$CampaignName'."; return $false }
}
