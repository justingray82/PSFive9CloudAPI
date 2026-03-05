function Set-Five9CloudCampaignWhisper {
    param([string]$CampaignId, [string]$CampaignName, [Parameter(Mandatory)][string]$PromptName)
    $campaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName; if (-not $campaignId) { return }
    $promptId = Resolve-Five9CloudPromptId $PromptName;                  if (-not $promptId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/prompts/v1/domains/$($global:Five9.DomainId)/campaigns/$campaignId/connected/prompts/$promptId" -Method Post
    if ($result) { Write-Host "$PromptName set as $CampaignName Whisper Prompt"} else { Write-Host "Failed to set $PromptName as $CampaignName Whisper Prompt"; return $false }
}