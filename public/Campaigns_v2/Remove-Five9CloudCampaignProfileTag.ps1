function Remove-Five9CloudCampaignProfileTag {
    param([string]$ProfileId, [string]$ProfileName, [Parameter(Mandatory)][string]$TagId)
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/tags/$TagId" -Method Delete
    if ($result -ne $false) { Write-Host "Tag $TagId removed from campaign profile '$ProfileName'." } else { Write-Host "Failed to remove tag $TagId from campaign profile '$ProfileName'."; return $false }
}
