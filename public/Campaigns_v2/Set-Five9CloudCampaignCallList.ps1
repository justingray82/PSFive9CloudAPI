function Set-Five9CloudCampaignCallList {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][string]$CallListId,
        [Parameter(Mandatory)][int]$Order,
        [Parameter(Mandatory)][ValidateRange(1,99)][int]$DialingPriority,
        [Parameter(Mandatory)][ValidateRange(1,99)][int]$DialingRatio
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $body = @{
        order           = $Order
        dialingPriority = $DialingPriority
        dialingRatio    = $DialingRatio
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/lists/$CallListId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Call list '$CallListId' updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update call list '$CallListId' for campaign '$CampaignName'."; return $false }
}
