function Get-Five9CloudCampaignProfile {
    param([string]$ProfileId, [string]$ProfileName)
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId"
}
