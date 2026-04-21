function Reset-Five9CloudCampaignDispositions {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][string[]]$DispositionIds,
        [Parameter(Mandatory)][datetime]$After,
        [Parameter(Mandatory)][datetime]$Before
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $body = @{
        dispositionIds = $DispositionIds
        after          = $After.ToString('o')
        before         = $Before.ToString('o')
    }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($CampaignId):reset-dispositions" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Campaign '$CampaignName' disposition reset request submitted." } else { Write-Host "Failed to reset dispositions for campaign '$CampaignName'."; return $false }
}
