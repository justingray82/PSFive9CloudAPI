function Set-Five9CloudUtilizationSettings {
    param(
        [Parameter(Mandatory)][ValidateRange(25,100)][int]$AutoCallsLineUtilizationPercentage
    )

    # Seed from current state to preserve read-only fields the API echoes back
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/utilization-settings"
    if (-not $current) { return }
    $body = $current

    $body.autoCallsLineUtilizationPercentage = $AutoCallsLineUtilizationPercentage

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/utilization-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Utilization settings updated successfully."; return $result } else { Write-Host "Failed to update utilization settings."; return $false }
}
