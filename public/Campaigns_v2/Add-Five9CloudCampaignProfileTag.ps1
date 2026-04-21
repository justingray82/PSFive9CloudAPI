function Add-Five9CloudCampaignProfileTag {
    param([string]$ProfileId, [string]$ProfileName, [Parameter(Mandatory)][string]$TagId)
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/tags/$TagId" -Method Post
    if ($result -ne $false) { Write-Host "Tag $TagId added to campaign profile '$ProfileName'." } else { Write-Host "Failed to add tag $TagId to campaign profile '$ProfileName'."; return $false }
}
