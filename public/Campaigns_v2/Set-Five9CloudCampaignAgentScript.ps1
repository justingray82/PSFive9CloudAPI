function Set-Five9CloudCampaignAgentScript {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$Script)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $body = @{ script = $Script }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/agent-script" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Agent script updated for campaign '$CampaignName'." } else { Write-Host "Failed to update agent script for campaign '$CampaignName'."; return $false }
}
