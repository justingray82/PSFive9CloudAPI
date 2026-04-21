function Add-Five9CloudCampaignNumber {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$Number)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $cleanNumber = $Number -replace '\D', ''
    if ($cleanNumber -notmatch '^\+') { $cleanNumber = "1$cleanNumber" -replace '^1{2,}', '1' }; $Number = "+$cleanNumber"
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/numbers/$Number" -Method Post
    if ($result -ne $false) { Write-Host "Number $Number added to campaign '$CampaignName'." } else { Write-Host "Failed to add number $Number to campaign '$CampaignName'."; return $false }
}
