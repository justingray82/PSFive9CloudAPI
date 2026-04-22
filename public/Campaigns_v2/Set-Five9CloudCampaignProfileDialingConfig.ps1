function Set-Five9CloudCampaignProfileDialingConfig {
    param(
        [string]$ProfileId,
        [string]$ProfileName,
        [Parameter(Mandatory)][ValidateRange(1,100)][int]$CallPriority,
        [Parameter(Mandatory)][string]$DialTimeout,
        [Parameter(Mandatory)][ValidateRange(0,127)][int]$NumberOfDialAttempts,
        [Parameter(Mandatory)][int]$MaxCharges
    )
    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }

    $body = @{
        callPriority          = $CallPriority
        dialTimeout           = $DialTimeout
        numberOfDialAttempts  = $NumberOfDialAttempts
        maxCharges            = $MaxCharges
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/dialing-config" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing config updated for campaign profile '$ProfileName'."; return $result } else { Write-Host "Failed to update dialing config for campaign profile '$ProfileName'."; return $false }
}
