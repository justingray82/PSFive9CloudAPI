function Add-Five9CloudCampaignSkill {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$SkillId)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/skills/$SkillId" -Method Post
    if ($result -ne $false) { Write-Host "Skill $SkillId added to campaign '$CampaignName'." } else { Write-Host "Failed to add skill $SkillId to campaign '$CampaignName'."; return $false }
}
