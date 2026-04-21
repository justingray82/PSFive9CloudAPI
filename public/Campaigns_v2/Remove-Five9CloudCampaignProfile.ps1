function Remove-Five9CloudCampaignProfile {
    param([string]$ProfileId, [string]$ProfileName)
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId" -Method Delete
    if ($result -ne $false) { Write-Host "Campaign profile '$ProfileName' deleted successfully." } else { Write-Host "Failed to delete campaign profile '$ProfileName'."; return $false }
}
