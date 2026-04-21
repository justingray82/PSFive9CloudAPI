function New-Five9CloudCampaignProfile {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description
    )
    $body = @{ name = $Name }
    if ($Description) { $body.description = $Description }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaign-profiles" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Campaign profile '$Name' created successfully."; return $result } else { Write-Host "Failed to create campaign profile '$Name'."; return $false }
}
