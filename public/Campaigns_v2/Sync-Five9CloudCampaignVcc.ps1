function Sync-Five9CloudCampaignVcc {
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/system/domains/$($global:Five9.DomainId)/campaigns:sync-vcc" -Method Post
    if ($result -ne $false) { Write-Host "VCC campaign synchronization task initiated." } else { Write-Host "Failed to initiate VCC campaign synchronization."; return $false }
}
