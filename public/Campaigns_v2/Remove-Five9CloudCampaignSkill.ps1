function Remove-Five9CloudCampaignSkill {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$SkillId)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/skills/$SkillId" -Method Delete
    if ($result -ne $false) { Write-Host "Skill $SkillId removed from campaign '$CampaignName'." } else { Write-Host "Failed to remove skill $SkillId from campaign '$CampaignName'."; return $false }
}
