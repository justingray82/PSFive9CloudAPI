function Stop-Five9CloudCampaign {
    param([string]$CampaignId, [string]$CampaignName, [switch]$Force)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $action = if ($Force) { 'force-stop' } else { 'stop' }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($CampaignId):$action" -Method Put
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' $action request submitted." } else { Write-Host "Failed to $action campaign '$CampaignName'."; return $false }
}
