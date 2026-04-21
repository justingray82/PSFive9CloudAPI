function New-Five9CloudCampaign {
    param(
        [Parameter(Mandatory)][hashtable]$CampaignDetails
    )
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns" -Method Post -Body $CampaignDetails
    if ($result -ne $false) { Write-Host "Campaign '$($CampaignDetails.name)' created successfully."; return $result } else { Write-Host "Failed to create campaign '$($CampaignDetails.name)'."; return $false }
}
