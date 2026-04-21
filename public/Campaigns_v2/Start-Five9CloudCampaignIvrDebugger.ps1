function Start-Five9CloudCampaignIvrDebugger {
    param(
        [string]$CampaignId,
        [string]$CampaignName,
        [Parameter(Mandatory)][ValidateSet('VOICE','VISUAL','CHAT','EMAIL','CASE')][string]$Channel,
        [Parameter(Mandatory)][string]$Variable,
        [Parameter(Mandatory)][string]$Value
    )
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    $body = @{ channel = $Channel; variable = $Variable; value = $Value }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$($CampaignId)/ivr-debugger:start" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "IVR debugger session started for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to start IVR debugger for campaign '$CampaignName'."; return $false }
}
