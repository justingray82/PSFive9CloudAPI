function Set-Five9CloudCampaignCSS {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][string]$Content
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $body = @{ content = $Content }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/css/current" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "CSS updated for campaign '$CampaignName'." } else { Write-Host "Failed to update CSS for campaign '$CampaignName'."; return $false }
}
