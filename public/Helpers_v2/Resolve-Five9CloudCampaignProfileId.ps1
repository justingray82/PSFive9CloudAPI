function Resolve-Five9CloudCampaignProfileId ([string]$ProfileName) {
    $result = Get-Five9CloudCampaignProfiles -Filter "name=='$ProfileName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.id }
    Write-Error "Campaign profile '$ProfileName' not found."; return $null
}
