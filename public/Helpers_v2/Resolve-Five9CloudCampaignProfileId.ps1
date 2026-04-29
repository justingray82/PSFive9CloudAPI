function Resolve-Five9CloudCampaignProfileId ([string]$ProfileName) {
    $result = Get-Five9CloudCampaignProfiles -Filter "name=='$ProfileName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.id }
    Write-Host "Campaign profile '$ProfileName' not found." -ForegroundColor Red; return $null
}
