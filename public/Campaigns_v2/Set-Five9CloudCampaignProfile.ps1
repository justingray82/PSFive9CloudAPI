function Set-Five9CloudCampaignProfile {
    param(
        [string]$ProfileId,
        [string]$ProfileName,
        [string]$Name,
        [string]$Description
    )
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    $body = @{}
    if ($Name)        { $body.name        = $Name }
    if ($Description) { $body.description = $Description }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Campaign profile '$ProfileName' updated successfully."; return $result } else { Write-Host "Failed to update campaign profile '$ProfileName'."; return $false }
}
