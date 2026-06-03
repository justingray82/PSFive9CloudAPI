function Remove-Five9CloudDigitalAssistance {
    param([string]$AssistanceId, [string]$AssistanceName)
    if (-not $AssistanceId) { $AssistanceId = Resolve-Five9CloudDomainAssistance $AssistanceName } ; if (-not $AssistanceId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)/assistances/$AssistanceId" -Method Delete
    if ($result -ne $false) { Write-Host "Assistance $AssistanceId removed from domain." } else { Write-Host "Failed to remove assistance $AssistanceId from domain."; return $false }

}