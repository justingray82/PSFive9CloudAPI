function Set-Five9CloudCampaignPrioritization {
    param(
        [Parameter(Mandatory)][bool]$EnablePriority,
        [Parameter(Mandatory)][bool]$EnableDialingRatio
    )

    $body = @{
        enablePriority     = $EnablePriority
        enableDialingRatio = $EnableDialingRatio
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns-prioritization" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Campaign prioritization settings updated successfully."; return $result } else { Write-Host "Failed to update campaign prioritization settings."; return $false }
}
