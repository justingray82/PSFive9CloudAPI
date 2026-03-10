function Set-Five9CloudCampaignHold {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$PromptName)
    if (-not $campaignId) { $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $campaignId) { return }
    $promptId = Resolve-Five9CloudPromptId $PromptName;                  if (-not $promptId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/prompts/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId/hold/prompts/$promptId" -Method Post
    if ($result -ne $false) { Write-Host "$PromptName set as $CampaignName Hold Prompt"} else { Write-Host "Failed to set $PromptName as $CampaignName Hold Prompt"; return $false }
}