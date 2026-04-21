function Invoke-Five9CloudPhoneNumberCampaignMap {
    param([Parameter(Mandatory)][string]$PhoneNumber)
    $cleanNumber = $PhoneNumber -replace '\D', ''
    if ($cleanNumber -notmatch '^\+') { $cleanNumber = "1$cleanNumber" -replace '^1{2,}', '1' }; $PhoneNumber = "+$cleanNumber"
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/numbers/$PhoneNumber/campaigns:map" -Method Post
    if ($result -ne $false) { return $result } else { Write-Host "Failed to map phone number $PhoneNumber to campaign."; return $false }
}
